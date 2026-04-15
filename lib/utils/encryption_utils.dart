import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  // AES-256 encryption key (in production, this should come from secure env)
  static final _key = encrypt.Key.fromLength(32);
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  /// Encrypt sensitive data like Aadhar number
  static String encryptData(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt encrypted data
  static String decryptData(String encryptedText) {
    final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }

  /// Mask Aadhar number for display (show last 4 digits)
  static String maskAadhar(String aadhar) {
    if (aadhar.length < 4) return '****';
    return 'XXXX-XXXX-${aadhar.substring(aadhar.length - 4)}';
  }

  /// Generate a random user ID in JPXXXXXXXX format
  static String generateUserId() {
    final random = Random();
    final digits = List.generate(8, (_) => random.nextInt(10)).join();
    return 'JP$digits';
  }

  /// Generate a random prescription ID in JP-RX-XXXXX format
  static String generatePrescriptionId() {
    final random = Random();
    final digits = List.generate(5, (_) => random.nextInt(10)).join();
    return 'JP-RX-$digits';
  }
}
