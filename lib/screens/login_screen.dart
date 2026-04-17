import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUpMode = false;
  bool _isGoogleSignIn = false;
  bool _isGoogleButtonPressed = false;
  String _errorMessage = '';
  bool _isLoading = false;

  // Colors matching Swift exactly: Color(red: 0.7, green: 0.1, blue: 0.1)
  static const Color _deepRed = Color.fromRGBO(179, 26, 26, 1);
  // Color(red: 0.98, green: 0.96, blue: 0.9)
  static const Color _cream = Color.fromRGBO(250, 245, 230, 1);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_isSignUpMode) {
      if (_isGoogleSignIn) {
        return name.isNotEmpty && email.isNotEmpty && email.contains('@');
      } else {
        return name.isNotEmpty &&
            email.isNotEmpty &&
            email.contains('@') &&
            password.length >= 6;
      }
    } else {
      if (_isGoogleSignIn) {
        return email.isNotEmpty && email.contains('@');
      } else {
        return email.isNotEmpty &&
            email.contains('@') &&
            password.length >= 6;
      }
    }
  }

  Future<void> _validateAndLogin() async {
    if (!_isFormValid) {
      setState(() {
        _errorMessage =
            'Please enter a valid email and a password with at least 6 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = context.read<AuthService>();
      await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _validateAndSignUp() async {
    if (!_isFormValid) {
      setState(() {
        _errorMessage =
            'Please fill all fields correctly. Ensure name is not empty, email is valid, and password is at least 6 characters.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = context.read<AuthService>();
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleSignIn = true;
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      final authService = context.read<AuthService>();
      await authService.signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isGoogleSignIn = false;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _errorMessage = '';
      _isGoogleSignIn = false;
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Widget _buildCustomTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _deepRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(icon, color: _deepRed, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              autocorrect: false,
              enableSuggestions: !obscureText,
              style: const TextStyle(color: Colors.black),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Blood drop icon
              Icon(
                Icons.water_drop,
                size: 80,
                color: _deepRed,
              ),
              const SizedBox(height: 25),
              // Title
              const Text(
                'Blood Donation',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _deepRed,
                ),
              ),
              const SizedBox(height: 8),
              // Subtitle
              Text(
                'Save Lives',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: _deepRed.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
              // Form card
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 15),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    // Name field (sign up only)
                    if (_isSignUpMode)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildCustomTextField(
                          hint: 'Name',
                          icon: Icons.person,
                          controller: _nameController,
                        ),
                      ),
                    // Email field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: _buildCustomTextField(
                        hint: 'Email',
                        icon: Icons.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    // Password field (hidden during Google sign-in)
                    if (!_isGoogleSignIn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: _buildCustomTextField(
                          hint: 'Password',
                          icon: Icons.lock,
                          controller: _passwordController,
                          obscureText: true,
                        ),
                      ),
                    // Error message
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 10),
                    // Sign In / Create Account button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isFormValid && !_isLoading
                              ? () {
                                  if (_isSignUpMode) {
                                    _validateAndSignUp();
                                  } else {
                                    _validateAndLogin();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFormValid
                                ? _deepRed
                                : _deepRed.withOpacity(0.4),
                            disabledBackgroundColor:
                                _deepRed.withOpacity(0.4),
                            foregroundColor: Colors.white,
                            disabledForegroundColor:
                                Colors.white.withOpacity(0.7),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading && !_isGoogleSignIn
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isSignUpMode
                                      ? 'Create Account'
                                      : 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Google Sign-In button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _isGoogleButtonPressed = true),
                        onTapUp: (_) =>
                            setState(() => _isGoogleButtonPressed = false),
                        onTapCancel: () =>
                            setState(() => _isGoogleButtonPressed = false),
                        onTap: _isLoading ? null : _handleGoogleSignIn,
                        child: AnimatedScale(
                          scale: _isGoogleButtonPressed ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _deepRed.withOpacity(0.5),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.grey.withOpacity(0.2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.g_mobiledata,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Toggle mode
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isSignUpMode
                            ? 'Already have an account? Sign In'
                            : 'New user? Create Account',
                        style: const TextStyle(
                          color: _deepRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: _deepRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
