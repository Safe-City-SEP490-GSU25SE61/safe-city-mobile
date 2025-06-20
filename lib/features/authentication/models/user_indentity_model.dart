class UserIdentityModel {
  String? fullName;
  String? idNumber;
  String? dateOfBirth;
  bool? gender;
  String? issueDate;
  String? placeOfIssue;
  String? expiryDate;
  String? address;
  String? cardSideType;
  String? email;
  String? password;
  String? phone;

  UserIdentityModel({
    this.fullName,
    this.idNumber,
    this.dateOfBirth,
    this.gender,
    this.issueDate,
    this.placeOfIssue,
    this.expiryDate,
    this.address,
    this.cardSideType,
    this.email,
    this.password,
    this.phone,
  });

  factory UserIdentityModel.fromJson(Map<String, dynamic> json) {
    return UserIdentityModel(
      fullName: json['fullName'],
      idNumber: json['idNumber'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      issueDate: json['issueDate'],
      placeOfIssue: json['placeOfIssue'],
      expiryDate: json['expiryDate'],
      address: json['address'],
      cardSideType: json['cardSideType'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
    );
  }
}
