/// Custom exception class to handle various format-related errors.
class TFormatException implements Exception {
  /// The associated error message.
  final String message;

  /// Default constructor with a generic error message.
  const TFormatException([this.message = 'Đã xảy ra lỗi định dạng không mong muốn. Vui lòng kiểm tra lại dữ liệu đầu vào.']);

  /// Create a format exception from a specific error message.
  factory TFormatException.fromMessage(String message) {
    return TFormatException(message);
  }

  /// Get the corresponding error message.
  String get formattedMessage => message;

  /// Create a format exception from a specific error code.
  factory TFormatException.fromCode(String code) {
    switch (code) {
      case 'invalid-email-format':
        return const TFormatException('Định dạng địa chỉ email không hợp lệ. Vui lòng nhập email hợp lệ.');
      case 'invalid-phone-number-format':
        return const TFormatException('Định dạng số điện thoại không hợp lệ. Vui lòng nhập số hợp lệ.');
      case 'invalid-date-format':
        return const TFormatException('Định dạng ngày tháng không hợp lệ. Vui lòng nhập ngày hợp lệ.');
      case 'invalid-url-format':
        return const TFormatException('Định dạng URL không hợp lệ. Vui lòng nhập URL hợp lệ.');
      case 'invalid-credit-card-format':
        return const TFormatException('Định dạng thẻ tín dụng không hợp lệ. Vui lòng nhập số thẻ tín dụng hợp lệ.');
      case 'invalid-numeric-format':
        return const TFormatException('Dữ liệu đầu vào phải là định dạng số hợp lệ.');
    // Add more cases as needed...
      default:
        return const TFormatException();
    }
  }
}
