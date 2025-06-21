/// Custom exception class to handle various Firebase-related errors.
class TFirebaseException implements Exception {
  /// The error code associated with the exception.
  final String code;

  /// Constructor that takes an error code.
  TFirebaseException(this.code);

  /// Get the corresponding error message based on the error code.
  String get message {
    switch (code) {
      case 'unknown':
        return 'Đã xảy ra lỗi Firebase không xác định. Vui lòng thử lại.';
      case 'invalid-custom-token':
        return 'Định dạng token tùy chỉnh không chính xác. Vui lòng kiểm tra lại token tùy chỉnh của bạn.';
      case 'custom-token-mismatch':
        return 'Token tùy chỉnh này thuộc về một đối tượng khác.';
      case 'user-disabled':
        return 'Tài khoản người dùng đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy người dùng cho email hoặc UID đã cho.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ. Vui lòng nhập email hợp lệ.';
      case 'email-already-in-use':
        return 'Địa chỉ email này đã được đăng ký. Vui lòng sử dụng một email khác.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác. Vui lòng kiểm tra lại mật khẩu và thử lại.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'provider-already-linked':
        return 'Tài khoản đã được liên kết với nhà cung cấp khác.';
      case 'operation-not-allowed':
        return 'Hoạt động này không được phép. Vui lòng liên hệ hỗ trợ để được trợ giúp.';
      case 'invalid-credential':
        return 'Thông tin xác thực không hợp lệ hoặc đã hết hạn.';
      case 'invalid-verification-code':
        return 'Mã xác minh không hợp lệ. Vui lòng nhập mã hợp lệ.';
      case 'invalid-verification-id':
        return 'ID xác minh không hợp lệ. Vui lòng yêu cầu mã xác minh mới.';
      case 'captcha-check-failed':
        return 'Phản hồi reCAPTCHA không hợp lệ. Vui lòng thử lại.';
      case 'app-not-authorized':
        return 'Ứng dụng không được phép sử dụng Firebase Authentication với khóa API cung cấp.';
      case 'keychain-error':
        return 'Đã xảy ra lỗi keychain. Vui lòng kiểm tra keychain và thử lại.';
      case 'internal-error':
        return 'Đã xảy ra lỗi xác thực nội bộ. Vui lòng thử lại sau.';
      case 'invalid-app-credential':
        return 'Thông tin xác thực của ứng dụng không hợp lệ. Vui lòng cung cấp thông tin hợp lệ.';
      case 'user-mismatch':
        return 'Thông tin xác thực không khớp với người dùng đã đăng nhập trước đó.';
      case 'requires-recent-login':
        return 'Hoạt động này nhạy cảm và yêu cầu đăng nhập gần đây. Vui lòng đăng nhập lại.';
      case 'quota-exceeded':
        return 'Đã vượt quá hạn mức. Vui lòng thử lại sau.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với cùng email nhưng với thông tin đăng nhập khác.';
      case 'missing-iframe-start':
        return 'Thiếu thẻ mở iframe trong mẫu email.';
      case 'missing-iframe-end':
        return 'Thiếu thẻ đóng iframe trong mẫu email.';
      case 'missing-iframe-src':
        return 'Thiếu thuộc tính src trong iframe của mẫu email.';
      case 'auth-domain-config-required':
        return 'Cần cấu hình authDomain cho liên kết xác minh mã hành động.';
      case 'missing-app-credential':
        return 'Thiếu thông tin xác thực của ứng dụng. Vui lòng cung cấp thông tin hợp lệ.';
      case 'session-cookie-expired':
        return 'Cookie phiên của Firebase đã hết hạn. Vui lòng đăng nhập lại.';
      case 'uid-already-exists':
        return 'ID người dùng đã được sử dụng bởi người dùng khác.';
      case 'web-storage-unsupported':
        return 'Trình duyệt không hỗ trợ hoặc đã tắt lưu trữ web.';
      case 'app-deleted':
        return 'Phiên bản FirebaseApp này đã bị xóa.';
      case 'user-token-mismatch':
        return 'Token của người dùng không khớp với ID người dùng đã xác thực.';
      case 'invalid-message-payload':
        return 'Nội dung email xác minh không hợp lệ.';
      case 'invalid-sender':
        return 'Người gửi email không hợp lệ. Vui lòng kiểm tra email của người gửi.';
      case 'invalid-recipient-email':
        return 'Địa chỉ email của người nhận không hợp lệ. Vui lòng cung cấp email hợp lệ.';
      case 'missing-action-code':
        return 'Thiếu mã hành động. Vui lòng cung cấp mã hành động hợp lệ.';
      case 'user-token-expired':
        return 'Token của người dùng đã hết hạn, cần xác thực lại. Vui lòng đăng nhập lại.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Thông tin đăng nhập không hợp lệ.';
      case 'expired-action-code':
        return 'Mã hành động đã hết hạn. Vui lòng yêu cầu mã hành động mới.';
      case 'invalid-action-code':
        return 'Mã hành động không hợp lệ. Vui lòng kiểm tra lại mã và thử lại.';
      case 'credential-already-in-use':
        return 'Thông tin xác thực này đã được liên kết với một tài khoản người dùng khác.';
      default:
        return 'Đã xảy ra lỗi Firebase không mong muốn. Vui lòng thử lại.';
    }
  }
}
