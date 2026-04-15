import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Provider;

import 'package:jeevanpatra/models/user_model.dart';
import 'package:jeevanpatra/services/auth_service.dart';
import 'package:jeevanpatra/services/user_service.dart';

// ── Service providers ──────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((_) => AuthService());
final userServiceProvider = Provider<UserService>((_) => UserService());

// ── Auth state stream ──────────────────────────────────────────────────
/// Emits the Supabase [AuthState] whenever it changes.
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.read(authServiceProvider).onAuthStateChange();
});

// ── Current user profile ───────────────────────────────────────────────
/// Fetches the [UserModel] for the currently authenticated user.
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.read(authServiceProvider);
  final user = authService.getCurrentUser();
  if (user == null) return null;

  final userService = ref.read(userServiceProvider);
  final result = await userService.getUserProfile(user.id);
  return result.user;
});

// ── Auth state notifier ────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier(this._authService, this._userService) : super(null) {
    _init();
  }

  final AuthService _authService;
  final UserService _userService;
  StreamSubscription<AuthState>? _sub;

  void _init() {
    _sub = _authService.onAuthStateChange().listen((authState) async {
      if (authState.session != null) {
        final uid = authState.session!.user.id;
        final result = await _userService.getUserProfile(uid);
        state = result.user;
      } else {
        state = null;
      }
    });
  }

  Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    final result = await _authService.signIn(
      identifier: identifier,
      password: password,
    );
    if (result.error != null) return result.error;
    state = result.user;
    return null;
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String mobileNumber,
    required UserType userType,
  }) async {
    final result = await _authService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      mobileNumber: mobileNumber,
      userType: userType,
    );
    if (result.error != null) return result.error;
    state = result.user;
    return null;
  }

  Future<String?> signOut() async {
    final error = await _authService.signOut();
    if (error != null) return error;
    state = null;
    return null;
  }

  Future<String?> resetPassword(String email) async {
    return _authService.resetPassword(email);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(userServiceProvider),
  );
});
