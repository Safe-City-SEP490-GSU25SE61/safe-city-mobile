import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TEncryptionUtils {
  final String? encryptionKey;
  late final Key key;

  TEncryptionUtils() : encryptionKey = dotenv.env['ENCRYPTION_KEY'] {
    if (encryptionKey == null) {
      throw Exception('ENCRYPTION_KEY is not defined in ..env');
    }
    key = Key.fromUtf8(encryptionKey!);
  }

  String encryptDeviceId(String deviceId) {
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromLength(16);
    final encrypted = encrypter.encrypt(deviceId, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptDeviceId(String encryptedDeviceId) {
    final encrypter = Encrypter(AES(key));
    final parts = encryptedDeviceId.split(
        ':'); // Split the IV and encrypted data.

    if (parts.length != 2) {
      throw Exception('Invalid encrypted data format');
    }

    try {
      final iv = IV.fromBase64(parts[0]);
      final encryptedData = parts[1];

      // Decrypt the data
      final decrypted = encrypter.decrypt64(encryptedData, iv: iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
