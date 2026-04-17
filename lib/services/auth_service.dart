import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  AppUser? _user;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isDonor => _user?.isDonor ?? false;

  AuthService() {
    // Listen for auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _fetchUserData(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });

    // Check initial session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _fetchUserData(session.user.id);
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        _user = AppUser.fromMap(response);
      } else {
        // User exists in auth but not in users table yet
        // This can happen during sign-up flow
        _user = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      _user = null;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _fetchUserData(response.user!.id);
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'donor',
  }) async {
    // Create auth user
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Sign up failed: No user returned');
    }

    // Create user profile in users table
    final userData = AppUser(
      id: response.user!.id,
      email: email,
      name: name,
      role: role,
    );

    await _supabase
        .from('users')
        .insert(userData.toMap());

    await _fetchUserData(response.user!.id);
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    const webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID'; // TODO: replace with actual client ID

    final googleSignIn = GoogleSignIn(
      serverClientId: webClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw Exception('No ID token received from Google');
    }

    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    if (response.user == null) {
      throw Exception('Google Sign-In failed');
    }

    // Check if user profile exists
    final existing = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .maybeSingle();

    if (existing == null) {
      // New user — create profile
      final userData = AppUser(
        id: response.user!.id,
        email: googleUser.email,
        name: googleUser.displayName ?? googleUser.email.split('@')[0],
        role: 'donor',
      );

      await _supabase
          .from('users')
          .insert(userData.toMap());
    }

    await _fetchUserData(response.user!.id);
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _user = null;
    notifyListeners();
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _fetchUserData(session.user.id);
    }
  }
}
