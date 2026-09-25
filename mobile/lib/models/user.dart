class User {
  final int id;
  final String email;
  final String login;

  User({required this.id, required this.email, required this.login});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], email: json['email'], login: json['login']);
  }
}
