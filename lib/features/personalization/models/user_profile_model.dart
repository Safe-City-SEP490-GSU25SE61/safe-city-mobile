class UserProfileModel {
  final int id;
  final String fullName;
  final String email;
  final DateTime dateOfBirth;
  String imageUrl;
  final bool gender;
  final String phone;
  final String status;
  final bool isLoggedIn;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.imageUrl,
    required this.gender,
    required this.phone,
    required this.status,
    required this.isLoggedIn,
  });

  static UserProfileModel empty() => UserProfileModel(
        id: 0,
        fullName: '',
        email: '',
        dateOfBirth: DateTime(2000, 1, 1),
        imageUrl: '',
        gender: false,
        phone: '',
        status: '',
        isLoggedIn: false,
      );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      imageUrl: json['imageUrl'] ?? '',
      gender: json['gender'],
      phone: json['phone'],
      status: json['status'],
      isLoggedIn: json['isLoggedIn'],
    );
  }
}
