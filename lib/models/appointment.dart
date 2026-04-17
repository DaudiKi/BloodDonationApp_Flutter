class Appointment {
  final String id;
  final String donorId;
  final String hospitalId;
  final String hospitalName;
  final String hospitalAddress;
  final DateTime date;
  final String status; // 'booked', 'completed', 'cancelled'
  final DateTime? createdAt;

  Appointment({
    required this.id,
    required this.donorId,
    required this.hospitalId,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.date,
    this.status = 'booked',
    this.createdAt,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      hospitalId: map['hospital_id'] as String,
      hospitalName: map['hospital_name'] as String,
      hospitalAddress: map['hospital_address'] as String,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String? ?? 'booked',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donor_id': donorId,
      'hospital_id': hospitalId,
      'hospital_name': hospitalName,
      'hospital_address': hospitalAddress,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
