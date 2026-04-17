import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/app_user.dart';
import '../models/donation.dart';
import '../models/hospital.dart';
import '../services/database_service.dart';

class DonationForm extends StatefulWidget {
  final List<AppUser> users;
  final List<Hospital> hospitals;

  const DonationForm({
    super.key,
    required this.users,
    required this.hospitals,
  });

  @override
  State<DonationForm> createState() => _DonationFormState();
}

class _DonationFormState extends State<DonationForm> {
  AppUser? _selectedDonor;
  Hospital? _selectedHospital;
  final _customHospitalController = TextEditingController();
  String _bloodType = '';
  DateTime _date = DateTime.now();
  bool _showLoading = false;
  bool _donationLimitReached = false;
  String _remainingTimeMessage = '';

  // Colors matching Swift: Color(red: 0.7, green: 0.1, blue: 0.1)
  static const Color _deepRed = Color.fromRGBO(179, 26, 26, 1);
  static const Color _cream = Color.fromRGBO(250, 245, 230, 1);

  static const List<String> _validBloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];

  @override
  void dispose() {
    _customHospitalController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedDonor != null &&
        (_customHospitalController.text.isNotEmpty ||
            _selectedHospital != null) &&
        _bloodType.isNotEmpty &&
        _validBloodTypes.contains(_bloodType) &&
        !_date.isAfter(DateTime.now());
  }

  Future<void> _checkDonationLimit(String userId) async {
    final dbService = context.read<DatabaseService>();
    final now = DateTime.now();
    final currentYear = now.year;

    try {
      final donations = await dbService.getDonations(userId);
      final startOfYear = DateTime(currentYear, 1, 1);
      final endOfYear = DateTime(currentYear, 12, 31, 23, 59, 59);

      final approvedCount = donations.where((d) =>
          (d.status == 'approved' || d.status == 'used') &&
          d.date.isAfter(startOfYear.subtract(const Duration(seconds: 1))) &&
          d.date.isBefore(endOfYear.add(const Duration(seconds: 1)))).length;

      setState(() {
        _donationLimitReached = approvedCount >= 4;

        if (_donationLimitReached) {
          final nextYear = DateTime(currentYear + 1, 1, 1);
          final diff = nextYear.difference(now);
          final months = diff.inDays ~/ 30;
          final days = diff.inDays % 30;
          final hours = diff.inHours % 24;

          final parts = <String>[];
          if (months > 0) parts.add('$months month${months == 1 ? '' : 's'}');
          if (days > 0) parts.add('$days day${days == 1 ? '' : 's'}');
          if (hours > 0) parts.add('$hours hour${hours == 1 ? '' : 's'}');

          final timeRemaining =
              parts.isEmpty ? 'less than a minute' : parts.join(', ');
          _remainingTimeMessage =
              '${_selectedDonor?.name ?? "User"} has donated 4 times in $currentYear. They can donate again in $timeRemaining on January 1st, ${currentYear + 1}.';
        } else {
          _remainingTimeMessage = '';
        }
      });
    } catch (e) {
      setState(() {
        _donationLimitReached = true;
      });
      _showMessage('Error checking donation limit. Please try again later.');
    }
  }

  Future<void> _submitDonation() async {
    if (_selectedDonor == null) {
      _showMessage('Please select a donor.');
      return;
    }

    if (_customHospitalController.text.isEmpty && _selectedHospital == null) {
      _showMessage('Please select a hospital or enter a hospital name.');
      return;
    }

    if (_donationLimitReached) {
      _showMessage(_remainingTimeMessage);
      return;
    }

    setState(() => _showLoading = true);

    try {
      final dbService = context.read<DatabaseService>();
      final hospitalName = _customHospitalController.text.isNotEmpty
          ? _customHospitalController.text
          : _selectedHospital!.name;

      final donation = Donation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        donorId: _selectedDonor!.id,
        hospital: hospitalName,
        bloodType: _bloodType,
        date: _date,
        status: 'pending',
      );

      await dbService.addDonation(donation);

      setState(() => _showLoading = false);
      _showMessage('Donation submitted successfully for ${_selectedDonor!.name}.');

      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      setState(() => _showLoading = false);
      _showMessage('Failed to submit donation: $e');
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Message'),
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

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: _deepRed, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _deepRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _deepRed, fontSize: 14),
            ),
          ),
          leadingWidth: 80,
          actions: [
            TextButton(
              onPressed:
                  _isFormValid && !_donationLimitReached && !_showLoading
                      ? _submitDonation
                      : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _isFormValid && !_donationLimitReached
                      ? _deepRed
                      : _deepRed.withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_deepRed, Color.fromRGBO(179, 26, 26, 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.water_drop, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Log Donation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Record a blood donation for a donor',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: _showLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: _deepRed),
                          SizedBox(height: 16),
                          Text('Submitting donation...'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          // Donation limit warning
                          if (_donationLimitReached)
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _remainingTimeMessage,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (_donationLimitReached)
                            const SizedBox(height: 20),

                          // Donor picker
                          _buildFormSection(
                            title: 'Donor',
                            icon: Icons.person,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonFormField<AppUser>(
                                value: _selectedDonor,
                                hint: const Text('Select a donor'),
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: widget.users.map((user) {
                                  return DropdownMenuItem<AppUser>(
                                    value: user,
                                    child:
                                        Text('${user.name} (${user.email})'),
                                  );
                                }).toList(),
                                onChanged: (donor) {
                                  setState(() => _selectedDonor = donor);
                                  if (donor != null) {
                                    _checkDonationLimit(donor.id);
                                  } else {
                                    setState(() {
                                      _donationLimitReached = false;
                                      _remainingTimeMessage = '';
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Hospital picker
                          _buildFormSection(
                            title: 'Where did they donate?',
                            icon: Icons.business,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child:
                                      DropdownButtonFormField<Hospital>(
                                    value: _selectedHospital,
                                    hint: const Text('Select a hospital'),
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    items:
                                        widget.hospitals.map((hospital) {
                                      return DropdownMenuItem<Hospital>(
                                        value: hospital,
                                        child: Text(hospital.name),
                                      );
                                    }).toList(),
                                    onChanged: (hospital) {
                                      setState(() =>
                                          _selectedHospital = hospital);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.add_circle,
                                          color: _deepRed, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color:
                                                  _deepRed.withOpacity(0.3),
                                            ),
                                          ),
                                          child: TextField(
                                            controller:
                                                _customHospitalController,
                                            decoration:
                                                const InputDecoration(
                                              hintText:
                                                  'Or enter a hospital name',
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                            ),
                                            onChanged: (val) {
                                              if (val.isNotEmpty) {
                                                setState(() =>
                                                    _selectedHospital =
                                                        null);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Blood type picker
                          _buildFormSection(
                            title: "What's their blood type?",
                            icon: Icons.water_drop,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _validBloodTypes.map((type) {
                                  final isSelected = _bloodType == type;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _bloodType = type);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _deepRed
                                            : Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Date picker
                          _buildFormSection(
                            title: 'When did they donate?',
                            icon: Icons.calendar_today,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              child: Row(
                                children: [
                                  const Text('Donation Date'),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () async {
                                      final picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: _date,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now(),
                                        builder: (context, child) {
                                          return Theme(
                                            data:
                                                Theme.of(context).copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                primary: _deepRed,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null) {
                                        setState(() => _date = picked);
                                      }
                                    },
                                    child: Text(
                                      DateFormat.yMMMd().format(_date),
                                      style: const TextStyle(
                                        color: _deepRed,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Submit button
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isFormValid &&
                                        !_donationLimitReached
                                    ? _submitDonation
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _isFormValid && !_donationLimitReached
                                          ? _deepRed
                                          : _deepRed.withOpacity(0.4),
                                  disabledBackgroundColor:
                                      _deepRed.withOpacity(0.4),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor:
                                      Colors.white.withOpacity(0.7),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Submit Donation',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
