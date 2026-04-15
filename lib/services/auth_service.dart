import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jeevanpatra/config/supabase_config.dart';
import 'package:jeevanpatra/models/user_model.dart';

class AuthService {
  final _client = SupabaseConfig.client;

  /// Creates a new user account and inserts a row into the users table.
  /// A JPXXXXXXXX userId is auto-generated.
  Future<({UserModel? user, String? error})> signUp({
    required String email,
    required String password,
    required String fullName,
    required String mobileNumber,
    required UserType userType,
  }) async {
    try {
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final authUser = authResponse.user;
      if (authUser == null) {
        return (user: null, error: 'Sign up failed. No user returned.');
      }

      final jpUserId = _generateUserId();

      final data = {
        'id': authUser.id,
        'user_id': jpUserId,
        'full_name': fullName,
        'mobile_number': mobileNumber,
        'email': email,
        'user_type': userType.name,
      };

      final response =
          await _client.from('users').insert(data).select().single();

      return (user: UserModel.fromJson(response), error: null);
    } on AuthException catch (e) {
      return (user: null, error: e.message);
    } catch (e) {
      return (user: null, error: e.toString());
    }
  }

  /// Signs in using email, mobile number, or Aadhar as the identifier.
  Future<({UserModel? user, String? error})> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      String email;

      if (_isEmail(identifier)) {
        email = identifier;
      } else {
        // Look up the email from the users table using mobile or aadhar.
        final column =
            _isMobileNumber(identifier) ? 'mobile_number' : 'encrypted_aadhar';
        final result = await _client
            .from('users')
            .select('email')
            .eq(column, identifier)
            .maybeSingle();

        if (result == null || result['email'] == null) {
          return (user: null, error: 'No account found for this identifier.');
        }
        email = result['email'] as String;
      }

      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return (user: null, error: 'Sign in failed.');
      }

      final userData =
          await _client.from('users').select().eq('id', userId).single();

      return (user: UserModel.fromJson(userData), error: null);
    } on AuthException catch (e) {
      return (user: null, error: e.message);
    } catch (e) {
      return (user: null, error: e.toString());
    }
  }

  /// Signs out the current user.
  Future<String?> signOut() async {
    try {
      await _client.auth.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Sends a password-reset email.
  Future<String?> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Verifies an OTP token for 2FA.
  Future<({bool success, String? error})> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );
      return (success: true, error: null);
    } on AuthException catch (e) {
      return (success: false, error: e.message);
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  /// Returns the currently authenticated Supabase user, or `null`.
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Updates the password for the current user.
  Future<String?> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Returns the current auth session, or `null`.
  Session? getSession() {
    return _client.auth.currentSession;
  }

  /// Listens to auth-state changes.
  Stream<AuthState> onAuthStateChange() {
    return _client.auth.onAuthStateChange;
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  String _generateUserId() {
    final random = Random();
    final digits = List.generate(8, (_) => random.nextInt(10)).join();
    return 'JP$digits';
  }

  bool _isEmail(String value) => value.contains('@');

  bool _isMobileNumber(String value) => RegExp(r'^\+?\d{10,13}$').hasMatch(value);
}
