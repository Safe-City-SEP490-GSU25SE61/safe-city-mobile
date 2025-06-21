/// Exception class for handling various platform-related errors.
class TPlatformException implements Exception {
  final String code;

  TPlatformException(this.code);

  String get message {
    switch (code) {
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Thông tin đăng nhập không hợp lệ. Vui lòng kiểm tra lại thông tin của bạn.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'invalid-argument':
        return 'Đối số không hợp lệ được cung cấp cho phương thức xác thực.';
      case 'invalid-password':
        return 'Mật khẩu không chính xác. Vui lòng thử lại.';
      case 'invalid-phone-number':
        return 'Số điện thoại không hợp lệ.';
      case 'operation-not-allowed':
        return 'Nhà cung cấp đăng nhập đã bị vô hiệu hóa cho dự án Firebase của bạn.';
      case 'session-cookie-expired':
        return 'Cookie phiên Firebase đã hết hạn. Vui lòng đăng nhập lại.';
      case 'uid-already-exists':
        return 'ID người dùng đã được sử dụng bởi người dùng khác.';
      case 'sign_in_failed':
        return 'Đăng nhập thất bại. Vui lòng thử lại.';
      case 'network-request-failed':
        return 'Yêu cầu mạng thất bại. Vui lòng kiểm tra kết nối internet.';
      case 'internal-error':
        return 'Lỗi nội bộ. Vui lòng thử lại sau.';
      case 'invalid-verification-code':
        return 'Mã xác minh không hợp lệ. Vui lòng nhập mã hợp lệ.';
      case 'invalid-verification-id':
        return 'ID xác minh không hợp lệ. Vui lòng yêu cầu mã xác minh mới.';
      case 'quota-exceeded':
        return 'Đã vượt quá hạn mức. Vui lòng thử lại sau.';
    // Add more cases as needed...
      default:
        return 'Đã xảy ra lỗi nền tảng không mong muốn. Vui lòng thử lại.';
    }
  }
}
