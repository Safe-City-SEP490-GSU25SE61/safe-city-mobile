class UserProfileModel {
  final String fullName;
  final String email;
  final DateTime dateOfBirth;
  String imageUrl;
  final bool gender;
  final String phone;
  final String idNumber;
  final String address;
  final DateTime issueDate;
  final DateTime expiryDate;
  final String placeOfIssue;
  final String placeOfBirth;
  final int totalPoint;
  final bool isBiometricEnabled;
  final String achievementName;
  final CurrentSubscription currentSubscription;

  UserProfileModel({
    required this.fullName,
    required this.email,
    required this.dateOfBirth,
    required this.imageUrl,
    required this.gender,
    required this.phone,
    required this.idNumber,
    required this.address,
    required this.issueDate,
    required this.expiryDate,
    required this.placeOfIssue,
    required this.placeOfBirth,
    required this.totalPoint,
    required this.isBiometricEnabled,
    required this.achievementName,
    required this.currentSubscription,
  });

  static UserProfileModel empty() => UserProfileModel(
    fullName: '',
    email: '',
    dateOfBirth: DateTime(2000, 1, 1),
    imageUrl: '',
    gender: false,
    phone: '',
    idNumber: '',
    address: '',
    issueDate: DateTime(2000, 1, 1),
    expiryDate: DateTime(2000, 1, 1),
    placeOfIssue: '',
    placeOfBirth: '',
    totalPoint: 0,
    isBiometricEnabled: false,
    achievementName: '',
    currentSubscription: CurrentSubscription.empty(),
  );

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['fullName'],
      email: json['email'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      imageUrl: json['imageUrl'] ?? '',
      gender: json['gender'],
      phone: json['phone'],
      idNumber: json['idNumber'] ?? '',
      address: json['address'] ?? '',
      issueDate: DateTime.parse(json['issueDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      placeOfIssue: json['placeOfIssue'] ?? '',
      placeOfBirth: json['placeOfBirth'] ?? '',
      totalPoint: json['totalPoint'] ?? 0,
      isBiometricEnabled: json['isBiometricEnabled'] ?? false,
      achievementName: json['achievementName'] ?? '',
      currentSubscription: CurrentSubscription.fromJson(
        json['currentSubscription'],
      ),
    );
  }
}

class CurrentSubscription {
  final String packageName;
  final String remainingTime;

  CurrentSubscription({required this.packageName, required this.remainingTime});

  static CurrentSubscription empty() =>
      CurrentSubscription(packageName: '', remainingTime: '');

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      packageName: json['packageName'] ?? '',
      remainingTime: json['remainingTime'] ?? '',
    );
  }
}
