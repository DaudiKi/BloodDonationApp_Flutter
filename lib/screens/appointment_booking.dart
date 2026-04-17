import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/hospital.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';


class AppointmentBooking extends StatefulWidget {
  final int streak;

  const AppointmentBooking({
    super.key,
    required this.streak,
  });

  @override
  State<AppointmentBooking> createState() => _AppointmentBookingState();
}

class _AppointmentBookingState extends State<AppointmentBooking> {
  late int _streak;
  Hospital? _selectedHospital;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Hardcoded hospitals matching Swift
  final List<Hospital> _hospitals = [
    Hospital(id: 'hospital1', name: 'City Hospital', address: '123 Main St, Nairobi'),
    Hospital(id: 'hospital2', name: 'General Medical Center', address: '456 Health Ave, Mombasa'),
    Hospital(id: 'hospital3', name: 'Hope Clinic', address: '789 Wellness Rd, Kisumu'),
  ];

  // Colors matching Swift: Color(red: 0.8, green: 0.1, blue: 0.1) for appointment view
  static const Color _deepRed = Color.fromRGBO(204, 26, 26, 1);
  static const Color _cream = Color.fromRGBO(250, 245, 230, 1);
  static const Color _lightRed = Color.fromRGBO(242, 204, 204, 1);

  @override
  void initState() {
    super.initState();
    _streak = widget.streak;
  }

  Future<void> _bookAppointment() async {
    final authService = context.read<AuthService>();
    final dbService = context.read<DatabaseService>();
    final userId = authService.user?.id;

    if (userId == null || _selectedHospital == null) {
      _showAlertDialog(
        'Error',
        'Please select a hospital and ensure you are logged in.',
      );
      return;
    }

    if (_streak < 1) {
      _showAlertDialog(
        'Insufficient Streaks',
        'You need at least one streak to book an appointment. Current streaks: $_streak',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        donorId: userId,
        hospitalId: _selectedHospital!.id,
        hospitalName: _selectedHospital!.name,
        hospitalAddress: _selectedHospital!.address,
        date: _selectedDate,
        status: 'booked',
      );

      await dbService.addAppointment(appointment);

      setState(() {
        _streak -= 1;
        _isLoading = false;
      });

      if (mounted) {
        _showAlertDialog(
          'Success!',
          'Your appointment has been booked successfully at ${_selectedHospital!.name} on ${DateFormat.yMMMMd().format(_selectedDate)}.',
          onDismiss: () {
            setState(() {
              _selectedHospital = null;
            });
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showAlertDialog(
          'Booking Failed',
          'Failed to book appointment: $e',
        );
      }
    }
  }

  void _showAlertDialog(String title, String message, {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        centerTitle: true,
        backgroundColor: _deepRed,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  // Streak info view
                  _buildStreakInfo(),
                  const SizedBox(height: 20),
                  // Hospital selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildHospitalSelection(),
                  ),
                  const SizedBox(height: 20),
                  // Date selection
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDateSelection(),
                  ),
                  const SizedBox(height: 30),
                  // Book button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildBookButton(),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 100,
      decoration: BoxDecoration(
        color: _lightRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: _deepRed, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Your Donation Streaks',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You have $_streak streak${_streak == 1 ? '' : 's'} available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  if (_streak < 1)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'You need at least 1 streak to book an appointment',
                        style: TextStyle(
                          fontSize: 12,
                          color: _deepRed,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Hospital',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _deepRed,
          ),
        ),
        const SizedBox(height: 10),
        ...(_hospitals.map((hospital) => _buildHospitalCard(hospital))),
        if (_selectedHospital != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _selectedHospital = null);
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _deepRed),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text(
                  'Clear Selection',
                  style: TextStyle(
                    fontSize: 14,
                    color: _deepRed,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    final isSelected = _selectedHospital?.id == hospital.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedHospital = hospital);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _deepRed : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _deepRed.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
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
                    hospital.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hospital.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected ? _deepRed : Colors.grey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _deepRed,
          ),
        ),
        const SizedBox(height: 10),
        Container(
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
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) {
              setState(() => _selectedDate = date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    final isDisabled = _streak < 1 || _selectedHospital == null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled || _isLoading ? null : _bookAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey : _deepRed,
          disabledBackgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white.withOpacity(0.7),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isDisabled ? 0 : 5,
          shadowColor: isDisabled ? Colors.transparent : _deepRed.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Book Appointment',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
