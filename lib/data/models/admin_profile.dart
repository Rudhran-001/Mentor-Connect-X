class AdminProfile {
  final String level;

  AdminProfile({required this.level});

  factory AdminProfile.fromMap(Map<String, dynamic> map) {
    return AdminProfile(level: map['level'] ?? 'normal');
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
    };
  }
}
