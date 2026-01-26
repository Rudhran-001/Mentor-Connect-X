class StudentProfile {
  final String goals;
  final int xp;
  final List<String> badges;

  StudentProfile({
    required this.goals,
    required this.xp,
    required this.badges,
  });

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    return StudentProfile(
      goals: map['goals'] ?? '',
      xp: map['xp'] ?? 0,
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goals': goals,
      'xp': xp,
      'badges': badges,
    };
  }
}
