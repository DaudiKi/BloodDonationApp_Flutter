import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/donation.dart';
import '../models/hospital.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

import 'donation_form.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<AppUser> _users = [];
  List<Donation> _donations = [];
  List<Hospital> _hospitals = [];
  int _selectedTab = 0;
  String? _togglingUserId;
  bool _isLoading = true;

  // Colors matching Swift: Color(red: 0.8, green: 0.1, blue: 0.1)
  static const Color _deepRed = Color.fromRGBO(204, 26, 26, 1);
  static const Color _cream = Color.fromRGBO(250, 245, 230, 1);
  static const Color _lightRed = Color.fromRGBO(242, 204, 204, 1);

  final DateFormat _dateFormatter = DateFormat.yMMMd().add_jm();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final dbService = context.read<DatabaseService>();
    setState(() => _isLoading = true);

    try {
      final users = await dbService.getUsers();
      final donations = await dbService.getAllDonations();
      final hospitals = await dbService.getHospitals();

      if (mounted) {
        setState(() {
          _users = users;
          _donations = donations;
          _hospitals = hospitals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showAlert('Error', 'Failed to load data: $e');
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(AppUser user) async {
    final authService = context.read<AuthService>();
    final dbService = context.read<DatabaseService>();
    final currentUser = authService.user;

    if (currentUser?.role != 'admin') {
      _showAlert('Error', 'You do not have permission to toggle user status');
      return;
    }

    if (user.id == currentUser?.id) {
      _showAlert('Error', 'You cannot toggle your own account status');
      return;
    }

    setState(() => _togglingUserId = user.id);

    try {
      await dbService.toggleUserActive(user.id, !user.isActive);
      _showAlert(
        'Success',
        'User status ${user.isActive ? "disabled" : "enabled"} successfully.',
      );
      await _fetchData();
    } catch (e) {
      _showAlert('Error', 'Failed to toggle user status: $e');
    }

    setState(() => _togglingUserId = null);
  }

  Future<void> _approveDonation(Donation donation) async {
    final dbService = context.read<DatabaseService>();

    if (donation.id.isEmpty) {
      _showAlert('Error', 'Invalid donation ID');
      return;
    }

    try {
      await dbService.updateDonationStatus(donation.id, 'approved');
      _showAlert('Success', 'Donation approved successfully.');
      await _fetchData();
    } catch (e) {
      _showAlert('Error', 'Failed to approve donation: $e');
    }
  }

  Future<void> _rejectDonation(Donation donation) async {
    final dbService = context.read<DatabaseService>();

    if (donation.id.isEmpty) {
      _showAlert('Error', 'Invalid donation ID');
      return;
    }

    try {
      await dbService.updateDonationStatus(donation.id, 'rejected');
      _showAlert('Success', 'Donation rejected successfully.');
      await _fetchData();
    } catch (e) {
      _showAlert('Error', 'Failed to reject donation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: _deepRed,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => authService.signOut(),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented control
          _buildSegmentedControl(),
          // Tab content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _deepRed),
                  )
                : IndexedStack(
                    index: _selectedTab,
                    children: [
                      _buildUsersListView(),
                      _buildDonationsListView(),
                      _buildActiveDonorsListView(),
                    ],
                  ),
          ),
          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      color: _deepRed,
      child: Row(
        children: [
          _buildSegmentButton('Users', 0),
          _buildSegmentButton('Donations', 1),
          _buildSegmentButton('Active Donors', 2),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: isSelected ? _cream : _deepRed,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? _deepRed : _cream,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersListView() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      color: _deepRed,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) => _buildUserCard(_users[index]),
      ),
    );
  }

  Widget _buildActiveDonorsListView() {
    final activeDonors =
        _users.where((u) => u.isActive && u.role != 'admin').toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: _deepRed,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeDonors.length,
        itemBuilder: (context, index) =>
            _buildUserCard(activeDonors[index]),
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    final isToggling = _togglingUserId == user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: user.isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isToggling ? null : () => _toggleUserStatus(user),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: user.isActive
                    ? Colors.red.withOpacity(0.2)
                    : _deepRed,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isToggling
                    ? 'Toggling...'
                    : (user.isActive ? 'Disable' : 'Enable'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: user.isActive ? Colors.red : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationsListView() {
    final pendingDonations =
        _donations.where((d) => d.status == 'pending').toList();

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: _deepRed,
      child: pendingDonations.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Text(
                    'No pending donations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingDonations.length,
              itemBuilder: (context, index) =>
                  _buildDonationCard(pendingDonations[index]),
            ),
    );
  }

  Widget _buildDonationCard(Donation donation) {
    final donorName = _users
        .where((u) => u.id == donation.donorId)
        .map((u) => u.name)
        .firstOrNull ?? donation.donorId;

    final matchingHospital =
        _hospitals.where((h) => h.name == donation.hospital).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
          // Header: Donor name + status
          Row(
            children: [
              Expanded(
                child: Text(
                  'Donor: $donorName',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _lightRed,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  donation.status[0].toUpperCase() +
                      donation.status.substring(1),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _deepRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Date
          Text(
            'Date: ${_dateFormatter.format(donation.date)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          // Hospital
          Text(
            'Hospital: ${donation.hospital}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Hospital address
          if (matchingHospital.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Address: ${matchingHospital.first.address}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          const SizedBox(height: 12),
          // Approve / Reject buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveDonation(donation),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _deepRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectDonation(donation),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
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
            child: ElevatedButton.icon(
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.95,
                    minChildSize: 0.5,
                    maxChildSize: 0.95,
                    builder: (context, scrollController) => DonationForm(
                      users: _users.where((u) => u.role != 'admin').toList(),
                      hospitals: _hospitals,
                    ),
                  ),
                );
                _fetchData();
              },
              icon: const Icon(Icons.add),
              label: const Text('Log Donation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _deepRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
