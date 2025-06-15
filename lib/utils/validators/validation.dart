class TValidator {
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName bắt buộc';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email bắt buộc';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegExp.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu bắt buộc';
    }
    if (value.length < 8) {
      return 'Mật khẩu có độ dài 8 kí tự trở lên';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu chứa một chữ viết hoa';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu chứa một chữ số';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Điện thoại bắt buộc';
    }
    final phoneRegExp = RegExp(r'(84|0[3|5|7|8|9])[0-9]{8}\b');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

// static String? validateUsername(String? value) {
//   if (value == null || value.isEmpty) {
//     return 'Username is required';
//   }
//   final usernameRegExp =
//       RegExp(r'(?=.{8,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])');
//   if (!usernameRegExp.hasMatch(value)) {
//     return 'Invalid username, ensure it contains a number and does not include special characters';
//   }
//   return null;
// }
}
