class AppUser {
  final String id;
  final String email;
  final String name;
  final String role; // 'donor' or 'admin'
  final bool isActive;
  final int streaks;
  final bool hasNotifiedFourDonations;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'donor',
    this.isActive = true,
    this.streaks = 0,
    this.hasNotifiedFourDonations = false,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String? ?? 'donor',
      isActive: map['is_active'] as bool? ?? true,
      streaks: map['streaks'] as int? ?? 0,
      hasNotifiedFourDonations: map['has_notified_four_donations'] as bool? ?? false,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'is_active': isActive,
      'streaks': streaks,
      'has_notified_four_donations': hasNotifiedFourDonations,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    int? streaks,
    bool? hasNotifiedFourDonations,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      streaks: streaks ?? this.streaks,
      hasNotifiedFourDonations: hasNotifiedFourDonations ?? this.hasNotifiedFourDonations,
      createdAt: createdAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isDonor => role == 'donor';
}
