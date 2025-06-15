/// Exception class for handling various errors.
class TExceptions implements Exception {
  /// The associated error message.
  final String message;

  /// Default constructor with a generic error message.
  const TExceptions([this.message = 'An unexpected error occurred. Please try again.']);

  /// Create an authentication exception from a Firebase authentication exception code.
  factory TExceptions.fromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const TExceptions('Email đã được dùng để đăng kí tài khoản này. Vui lòng sử dụng email khác.');
      case 'invalid-email':
        return const TExceptions('Địa chỉ email không hợp lệ. Vui lòng sử dụng email khác.');
      case 'weak-password':
        return const TExceptions('Mật khẩu quá yếu. Vui lòng cung cấp mật khẩu khác.');
      case 'user-disabled':
        return const TExceptions('Tài khoản đã bị vô hiệu hóa. Vui lòng liên hệ CSKH để được hỗ trợ.');
      case 'user-not-found':
        return const TExceptions('Thông tin đăng nhập không hợp lệ. Không tìm thấy tài khoản.');
      case 'wrong-password':
        return const TExceptions('Mật khẩu cung cấp không chính xác');
      case 'INVALID_LOGIN_CREDENTIALS':
        return const TExceptions('Thông tin đăng nhập không chính xác vui lòng thử lại.');
      case 'too-many-requests':
        return const TExceptions('Quá nhiều yêu cầu, vui lòng thử lại sau.');
      case 'invalid-argument':
        return const TExceptions('Đối số được cung cấp cho phương thức xác thực không hợp lệ.');
      case 'invalid-password':
        return const TExceptions('Incorrect password. Please try again.');
      case 'invalid-phone-number':
        return const TExceptions('Mật khẩu không chính xác. Vui lòng thử lại.');
      case 'operation-not-allowed':
        return const TExceptions('Nhà cung cấp đăng nhập đã bị vô hiệu hóa đối với dự án Firebase.');
      case 'session-cookie-expired':
        return const TExceptions('Cookie phiên đăng nhập Firebase đã hết hạn. Vui lòng đăng nhập lại.');
      case 'uid-already-exists':
        return const TExceptions('ID người dùng được cung cấp đã được người dùng khác sử dụng.');
      case 'sign_in_failed':
        return const TExceptions('Đăng nhập không thành công. Vui lòng thử lại sau.');
      case 'network-request-failed':
        return const TExceptions('Yêu cầu kết nối mạng không thành công. Vui lòng kiểm tra kết nối internet của bạn.');
      case 'internal-error':
        return const TExceptions('Lỗi nội bộ. Vui lòng thử lại sau.');
      case 'invalid-verification-code':
        return const TExceptions('Mã xác minh không hợp lệ. Vui lòng nhập mã hợp lệ.');
      case 'invalid-verification-id':
        return const TExceptions('ID xác minh không hợp lệ. Vui lòng yêu cầu mã xác minh mới.');
      case 'quota-exceeded':
        return const TExceptions('Đã vượt quá hạn ngạch. Vui lòng thử lại sau.');
      default:
        return const TExceptions();
    }
  }
}
