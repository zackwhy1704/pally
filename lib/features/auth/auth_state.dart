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
    this.childName,
  });

  final String? userId;
  final String? token;
  final bool isSetupComplete;
  final bool isOnboardingComplete;
  final String? childName;

  bool get isSignedIn => userId != null && token != null;

  AuthState copyWith({
    String? userId,
    String? token,
    bool? isSetupComplete,
    bool? isOnboardingComplete,
    String? childName,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      childName: childName ?? this.childName,
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
  static const _keySetupComplete = 'auth_setup_complete';
  static const _keyOnboardingComplete = 'auth_onboarding_complete';
  static const _keyChildName = 'auth_child_name';

  AuthState _state = const AuthState();
  AuthState get state => _state;

  Future<void> load() async {
    final userId = await _storage.read(key: _keyUserId);
    final token = await _storage.read(key: _keyToken);
    final setupRaw = await _storage.read(key: _keySetupComplete);
    final onboardingRaw = await _storage.read(key: _keyOnboardingComplete);
    final childName = await _storage.read(key: _keyChildName);
    _state = AuthState(
      userId: userId,
      token: token,
      isSetupComplete: setupRaw == 'true',
      isOnboardingComplete: onboardingRaw == 'true',
      childName: childName,
    );
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
    await _storage.write(
      key: _keySetupComplete,
      value: setupComplete.toString(),
    );
    await _storage.write(
      key: _keyOnboardingComplete,
      value: onboardingComplete.toString(),
    );
    _state = AuthState(
      userId: userId,
      token: token,
      isSetupComplete: setupComplete,
      isOnboardingComplete: onboardingComplete,
    );
    notifyListeners();
  }

  Future<void> markSetupComplete() async {
    await _storage.write(key: _keySetupComplete, value: 'true');
    _state = _state.copyWith(isSetupComplete: true);
    notifyListeners();
  }

  Future<void> markOnboardingComplete() async {
    await _storage.write(key: _keyOnboardingComplete, value: 'true');
    _state = _state.copyWith(isOnboardingComplete: true);
    notifyListeners();
  }

  Future<void> setChildName(String name) async {
    await _storage.write(key: _keyChildName, value: name);
    _state = _state.copyWith(childName: name);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keySetupComplete);
    await _storage.delete(key: _keyOnboardingComplete);
    await _storage.delete(key: _keyChildName);
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
