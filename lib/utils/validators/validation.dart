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
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
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

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mã xác minh là bắt buộc';
    }

    // Check if it has exactly 6 digits
    final otpRegExp = RegExp(r'^\d{6}$');
    if (!otpRegExp.hasMatch(value)) {
      return 'Mã xác minh phải gồm 6 chữ số';
    }

    return null;
  }

  static String? validateDropdown(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng chọn $fieldName';
    }
    return null;
  }

  static String? validateDateTime(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Hãy chọn $fieldName';
    }
    return null;
  }

  static String? validateComment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bình luận không được để trống';
    }
    if (value.length > 100) {
      return 'Bình luận không được vượt quá 100 ký tự';
    }
    return null;
  }

  static String? validateBlogTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tiêu đề không được để trống';
    }

    if (value.trim().length < 5) {
      return 'Tiêu đề phải có ít nhất 5 ký tự';
    }

    return null;
  }

  static String? validateVirtualEscortNameField(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName bắt buộc';
    }
    if (value.length < 3) {
      return '$fieldName phải có ít nhất 3 ký tự';
    }
    if (value.length > 100) {
      return '$fieldName không được vượt quá 100 ký tự';
    }
    return null;
  }

  static String? validateGroupCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mã nhóm là bắt buộc';
    }

    final code = value.toUpperCase();

    final codeRegExp = RegExp(r'^[A-Z0-9]{6}$');
    if (!codeRegExp.hasMatch(code)) {
      return 'Mã nhóm phải gồm 6 ký tự chữ hoặc số';
    }

    return null;
  }
}
