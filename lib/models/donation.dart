class Donation {
  final String id;
  final String donorId;
  final String hospital;
  final String bloodType;
  final DateTime date;
  final String status; // 'pending', 'approved', 'rejected', 'used'
  final DateTime? createdAt;

  Donation({
    required this.id,
    required this.donorId,
    required this.hospital,
    required this.bloodType,
    required this.date,
    this.status = 'pending',
    this.createdAt,
  });

  factory Donation.fromMap(Map<String, dynamic> map) {
    return Donation(
      id: map['id'] as String,
      donorId: map['donor_id'] as String,
      hospital: map['hospital'] as String,
      bloodType: map['blood_type'] as String,
      date: DateTime.parse(map['date'] as String),
      status: map['status'] as String? ?? 'pending',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donor_id': donorId,
      'hospital': hospital,
      'blood_type': bloodType,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
    };
  }
}
