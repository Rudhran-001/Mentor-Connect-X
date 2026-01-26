class MentorProfile {
  final String experience;
  final bool available;
  final double rating;

  MentorProfile({
    required this.experience,
    required this.available,
    required this.rating,
  });

  factory MentorProfile.fromMap(Map<String, dynamic> map) {
    return MentorProfile(
      experience: map['experience'] ?? '',
      available: map['available'] ?? false,
      rating: (map['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'experience': experience,
      'available': available,
      'rating': rating,
    };
  }
}
