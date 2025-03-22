class UserDTO {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? photoURL;

  UserDTO({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photoURL,
  });

  // Factory constructor to create a UserDTO from JSON data
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      photoURL: json['photoURL'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'photoURL': photoURL,
    };
  }

  // Get full name
  String get fullName => '$firstName $lastName';
}