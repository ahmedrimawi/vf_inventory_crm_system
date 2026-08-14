class User {
  final String id;
  final String username;
  final String? fullName;
  final String role;
  final String isActive;

  User({
    required this.id,
    required this.username,
    this.fullName,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      username: json['username'],
      fullName: json['full_name'],
      role: json['role'],
      isActive: json['is_active'],
    );
  }
}
