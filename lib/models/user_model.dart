class UserModel {
  final int id;
  final String name;
  final String email;
  final String role; // 'masyarakat' | 'pemerintah'
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
  });

  bool get isMasyarakat => role == 'masyarakat';
  bool get isPemerintah => role == 'pemerintah';

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token: token ?? json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (token != null) 'token': token,
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, role: $role)';
}
