import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ── Auth state ────────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.userId,
    this.token,
    this.isSetupComplete = false,
    this.isOnboardingComplete = false,
  });

  final String? userId;
  final String? token;
  final bool isSetupComplete;
  final bool isOnboardingComplete;

  bool get isSignedIn => userId != null && token != null;

  AuthState copyWith({
    String? userId,
    String? token,
    bool? isSetupComplete,
    bool? isOnboardingComplete,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}

// ── AuthNotifier ──────────────────────────────────────────────────────────────

class AuthNotifier extends ChangeNotifier {
  AuthNotifier._();

  static final instance = AuthNotifier._();

  static const _storage = FlutterSecureStorage();
  static const _keyUserId = 'auth_user_id';
  static const _keyToken = 'auth_token';

  AuthState _state = const AuthState();
  AuthState get state => _state;

  Future<void> load() async {
    final userId = await _storage.read(key: _keyUserId);
    final token = await _storage.read(key: _keyToken);
    _state = AuthState(userId: userId, token: token);
    notifyListeners();
  }

  Future<void> signIn({
    required String userId,
    required String token,
    bool setupComplete = false,
    bool onboardingComplete = false,
  }) async {
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyToken, value: token);
    _state = AuthState(
      userId: userId,
      token: token,
      isSetupComplete: setupComplete,
      isOnboardingComplete: onboardingComplete,
    );
    notifyListeners();
  }

  void markSetupComplete() {
    _state = _state.copyWith(isSetupComplete: true);
    notifyListeners();
  }

  void markOnboardingComplete() {
    _state = _state.copyWith(isOnboardingComplete: true);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyToken);
    _state = const AuthState();
    notifyListeners();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>(
  (_) => AuthNotifier.instance,
);

final authStateProvider = Provider<AuthState>(
  (ref) => ref.watch(authNotifierProvider).state,
);
