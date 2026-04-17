class Hospital {
  final String id;
  final String name;
  final String address;
  final DateTime? createdAt;

  Hospital({
    required this.id,
    required this.name,
    required this.address,
    this.createdAt,
  });

  factory Hospital.fromMap(Map<String, dynamic> map) {
    return Hospital(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
    };
  }
}
