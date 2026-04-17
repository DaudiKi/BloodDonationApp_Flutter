import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import '../models/donation.dart';
import '../models/hospital.dart';
import '../models/appointment.dart';

class DatabaseService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ─── USERS ────────────────────────────────────────────

  /// Get all users (admin only)
  Future<List<AppUser>> getUsers() async {
    final response = await _supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => AppUser.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Toggle user active status (admin only)
  Future<void> toggleUserActive(String userId, bool isActive) async {
    await _supabase
        .from('users')
        .update({'is_active': isActive})
        .eq('id', userId);
  }

  /// Update user streaks
  Future<void> updateUserStreaks(String userId, int streaks) async {
    await _supabase
        .from('users')
        .update({'streaks': streaks})
        .eq('id', userId);
  }

  /// Update four donation notification flag
  Future<void> updateNotifiedFourDonations(String userId, bool notified) async {
    await _supabase
        .from('users')
        .update({'has_notified_four_donations': notified})
        .eq('id', userId);
  }

  // ─── DONATIONS ────────────────────────────────────────

  /// Get donations for a specific donor
  Future<List<Donation>> getDonations(String donorId) async {
    final response = await _supabase
        .from('donations')
        .select()
        .eq('donor_id', donorId)
        .order('date', ascending: false);

    return (response as List)
        .map((e) => Donation.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all donations (admin only)
  Future<List<Donation>> getAllDonations() async {
    final response = await _supabase
        .from('donations')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => Donation.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Add a new donation (admin only)
  Future<void> addDonation(Donation donation) async {
    await _supabase
        .from('donations')
        .insert(donation.toMap());
  }

  /// Update donation status (admin only)
  Future<void> updateDonationStatus(String donationId, String status) async {
    await _supabase
        .from('donations')
        .update({'status': status})
        .eq('id', donationId);
  }

  /// Get the most recent donation date for a donor (for 56-day limit check)
  Future<DateTime?> getLastDonationDate(String donorId) async {
    final response = await _supabase
        .from('donations')
        .select('date')
        .eq('donor_id', donorId)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      return DateTime.parse(response['date'] as String);
    }
    return null;
  }

  // ─── HOSPITALS ────────────────────────────────────────

  /// Get all hospitals
  Future<List<Hospital>> getHospitals() async {
    final response = await _supabase
        .from('hospitals')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((e) => Hospital.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Add a new hospital (admin only)
  Future<void> addHospital(Hospital hospital) async {
    await _supabase
        .from('hospitals')
        .insert(hospital.toMap());
  }

  // ─── APPOINTMENTS ─────────────────────────────────────

  /// Get appointments for a specific donor
  Future<List<Appointment>> getAppointments(String donorId) async {
    final response = await _supabase
        .from('appointments')
        .select()
        .eq('donor_id', donorId)
        .order('date', ascending: false);

    return (response as List)
        .map((e) => Appointment.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Get all appointments (admin only)
  Future<List<Appointment>> getAllAppointments() async {
    final response = await _supabase
        .from('appointments')
        .select()
        .order('date', ascending: false);

    return (response as List)
        .map((e) => Appointment.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Add a new appointment
  Future<void> addAppointment(Appointment appointment) async {
    await _supabase
        .from('appointments')
        .insert(appointment.toMap());
  }

  /// Update appointment status
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _supabase
        .from('appointments')
        .update({'status': status})
        .eq('id', appointmentId);
  }

  // ─── STREAK CALCULATION ───────────────────────────────

  /// Calculate streak (approved donation count) for a donor
  Future<int> calcStreak(String donorId) async {
    final response = await _supabase
        .from('donations')
        .select()
        .eq('donor_id', donorId)
        .eq('status', 'approved');

    return (response as List).length;
  }
}
