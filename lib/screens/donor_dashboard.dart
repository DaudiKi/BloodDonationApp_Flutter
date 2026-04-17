import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/donation.dart';
import '../models/appointment.dart';
import '../models/hospital.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

import '../widgets/notification_sheet.dart';
import 'appointment_booking.dart';

class DonorDashboard extends StatefulWidget {
  const DonorDashboard({super.key});

  @override
  State<DonorDashboard> createState() => _DonorDashboardState();
}

class _DonorDashboardState extends State<DonorDashboard> {
  List<Donation> _donations = [];
  List<Appointment> _appointments = [];
  List<Hospital> _hospitals = [];
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  // Colors matching Swift: Color(red: 0.7, green: 0.1, blue: 0.1)
  static const Color _deepRed = Color.fromRGBO(179, 26, 26, 1);
  static const Color _cream = Color.fromRGBO(250, 245, 230, 1);


  final DateFormat _dateFormatter = DateFormat.yMMMd();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final authService = context.read<AuthService>();
    final dbService = context.read<DatabaseService>();
    final userId = authService.user?.id;

    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final donations = await dbService.getDonations(userId);
      final appointments = await dbService.getAppointments(userId);
      final hospitals = await dbService.getHospitals();

      if (mounted) {
        setState(() {
          _donations = donations;
          _appointments = appointments;
          _hospitals = hospitals;
          _isLoading = false;
        });
        _checkForDonationMilestone();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Failed to load data: $e');
      }
    }
  }

  int _calcStreak() {
    return _donations.where((d) => d.status == 'approved').length;
  }

  void _checkForDonationMilestone() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    final approvedDonations = _donations.where((d) =>
        d.status == 'approved' &&
        d.date.isAfter(startOfYear.subtract(const Duration(seconds: 1))) &&
        d.date.isBefore(endOfYear.add(const Duration(seconds: 1)))).toList();

    if (approvedDonations.length >= 4) {
      final donationDetails = approvedDonations.map((d) {
        return 'Date: ${_dateFormatter.format(d.date)}, Hospital: ${d.hospital}, Blood Type: ${d.bloodType}';
      }).join('\n');

      final message =
          'Congratulations! You\'ve reached 4 donations in ${now.year}!\nYour donations:\n$donationDetails\nThank you for your life-saving contributions!';

      // Only add if not already notified
      if (!_notifications.any((n) => n.message.contains('reached 4 donations'))) {
        _notifications.add(NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: message,
        ));
        setState(() {});
      }
    }
  }

  void _clearNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      setState(() {
        _notifications[index].isRead = true;
      });
    }

    // If all read, reset flag
    if (!_notifications.any((n) => !n.isRead)) {
      final authService = context.read<AuthService>();
      final dbService = context.read<DatabaseService>();
      final userId = authService.user?.id;
      if (userId != null) {
        dbService.updateNotifiedFourDonations(userId, false);
      }
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.user;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text('My Dashboard'),
        centerTitle: true,
        backgroundColor: _deepRed,
        foregroundColor: Colors.white,
        leading: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: NotificationSheet(
                      notifications: _notifications,
                      onMarkRead: _clearNotification,
                    ),
                  ),
                );
              },
            ),
            if (_unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User info card
                _buildUserInfoCard(user, _calcStreak()),
                // Scrollable content
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: _deepRed,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchData,
                          color: _deepRed,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Your Donations
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: Text(
                                    'Your Donations',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: _deepRed,
                                    ),
                                  ),
                                ),
                                if (_donations.isEmpty)
                                  _buildEmptyDonationsView()
                                else
                                  _buildDonationsList(),
                                // Your Appointments
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: Text(
                                    'Your Appointments',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: _deepRed,
                                    ),
                                  ),
                                ),
                                if (_appointments.isEmpty)
                                  _buildEmptyAppointmentsView()
                                else
                                  _buildAppointmentsList(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                ),
                // Action buttons
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildUserInfoCard(AppUser user, int streaks) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_deepRed, Color.fromRGBO(179, 26, 26, 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _deepRed.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user.name}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$streaks',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  streaks == 1 ? 'Streak' : 'Streaks',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDonationsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.water_drop,
              size: 60,
              color: _deepRed.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No donations yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _deepRed,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Your donations will appear here once logged by an admin.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentsView() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 60,
              color: _deepRed.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No appointments yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _deepRed,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Book your first appointment to donate blood!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: _donations
            .map((donation) => _buildDonationCard(donation))
            .toList(),
      ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    final matchingHospital = _hospitals
        .where((h) => h.name == donation.hospital)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row with status
          Row(
            children: [
              const Icon(Icons.calendar_today, color: _deepRed, size: 18),
              const SizedBox(width: 8),
              Text(
                _dateFormatter.format(donation.date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(donation.status),
            ],
          ),
          const Divider(color: Color.fromRGBO(179, 26, 26, 0.3)),
          // Hospital and blood type row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.business, color: _deepRed, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            donation.hospital,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    if (matchingHospital.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: _deepRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                matchingHospital.first.address,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.water_drop, color: _deepRed, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    donation.bloodType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _deepRed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: _appointments
            .map((appointment) => _buildAppointmentCard(appointment))
            .toList(),
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date row with status
          Row(
            children: [
              const Icon(Icons.calendar_today, color: _deepRed, size: 18),
              const SizedBox(width: 8),
              Text(
                _dateFormatter.format(appointment.date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(appointment.status),
            ],
          ),
          const Divider(color: Color.fromRGBO(179, 26, 26, 0.3)),
          // Hospital
          Row(
            children: [
              const Icon(Icons.business, color: _deepRed, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appointment.hospitalName,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          // Address
          Row(
            children: [
              const Icon(Icons.location_on, color: _deepRed, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  appointment.hospitalAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    if (status == 'approved' || status == 'booked') {
      bgColor = Colors.green.withOpacity(0.2);
      textColor = Colors.green;
    } else if (status == 'pending') {
      bgColor = Colors.orange.withOpacity(0.2);
      textColor = Colors.orange;
    } else {
      bgColor = Colors.red.withOpacity(0.2);
      textColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AppointmentBooking(
                      streak: _calcStreak(),
                    ),
                  ),
                );
                _fetchData();
              },
              icon: const Icon(Icons.calendar_month, color: _deepRed),
              label: const Text(
                'Book Appointment',
                style: TextStyle(color: _deepRed),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: _deepRed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
