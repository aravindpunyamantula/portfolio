class ReviewModel {
  final String name;
  final String role;
  final String company;
  final String message;
  final String avatarUrl;

  /// 1–5 stars; 0 hides the star row.
  final int rating;

  ReviewModel({
    required this.name,
    required this.role,
    required this.company,
    required this.message,
    this.avatarUrl = '',
    this.rating = 5,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      company: json['company'] as String? ?? '',
      message: json['message'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt().clamp(0, 5) ?? 5,
    );
  }

  String get subtitle =>
      [role, company].where((s) => s.isNotEmpty).join(' · ');

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
