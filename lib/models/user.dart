class User {
  String id;
  String email;
  String password;
  String role;
  String name;
  String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.name,
    this.profileImage,
  });

  //Conversion d'un User en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'role': role,
      'name': name,
      'profileImage': profileImage,
    };
  }

  // creation d'un User aprtir d'une Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      name: map['name'],
      profileImage: map['profileImage'],
    );
  }

  // Methode pour copier un user avec certaines valeurs modifies
  User copyWith({
    String? id,
    String? email,
    String? password,
    String? role,
    String? name,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, password: $password, role: $role, name: $name, profileImage: $profileImage}';
  }
}
