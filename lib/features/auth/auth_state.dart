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
    this.accountType,
    this.awaitingConsent = false,
    this.maskedParentEmail,
  });

  final String? userId;
  final String? token;
  final bool isSetupComplete;
  final bool isOnboardingComplete;
  final String? childName;

  /// Account role: "PARENT" or "STUDENT" (null = unknown / legacy).
  final String? accountType;

  /// True when this account is waiting for parental consent (under-13 flow).
  /// Persisted so the app reopens on the waiting screen, not the main app.
  final bool awaitingConsent;

  /// Masked parent email shown on the consent-pending screen (e.g. "j***@gmail.com").
  final String? maskedParentEmail;

  bool get isSignedIn => userId != null && token != null;

  /// True when this account was registered as a parent/guardian.
  bool get isParentAccount => accountType == 'PARENT';

  AuthState copyWith({
    String? userId,
    String? token,
    bool? isSetupComplete,
    bool? isOnboardingComplete,
    String? childName,
    Object? accountType = _authSentinel,
    bool? awaitingConsent,
    Object? maskedParentEmail = _authSentinel,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      childName: childName ?? this.childName,
      accountType: accountType == _authSentinel
          ? this.accountType
          : accountType as String?,
      awaitingConsent: awaitingConsent ?? this.awaitingConsent,
      maskedParentEmail: maskedParentEmail == _authSentinel
          ? this.maskedParentEmail
          : maskedParentEmail as String?,
    );
  }
}

const _authSentinel = Object();

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
  static const _keyAccountType = 'auth_account_type';
  static const _keyBiometricRegistered = 'biometric_registered';
  static const _keyLastUserId = 'auth_last_user_id';
  static const _keyAwaitingConsent = 'auth_awaiting_consent';
  static const _keyMaskedParentEmail = 'auth_masked_parent_email';

  AuthState _state = const AuthState();
  AuthState get state => _state;

  Future<void> load() async {
    final userId = await _storage.read(key: _keyUserId);
    final token = await _storage.read(key: _keyToken);
    final setupRaw = await _storage.read(key: _keySetupComplete);
    final onboardingRaw = await _storage.read(key: _keyOnboardingComplete);
    final childName = await _storage.read(key: _keyChildName);
    final accountType = await _storage.read(key: _keyAccountType);
    final awaitingConsentRaw = await _storage.read(key: _keyAwaitingConsent);
    final maskedParentEmail = await _storage.read(key: _keyMaskedParentEmail);
    _state = AuthState(
      userId: userId,
      token: token,
      isSetupComplete: setupRaw == 'true',
      isOnboardingComplete: onboardingRaw == 'true',
      childName: childName,
      accountType: accountType,
      awaitingConsent: awaitingConsentRaw == 'true',
      maskedParentEmail: maskedParentEmail,
    );
    notifyListeners();
  }

  Future<void> signIn({
    required String userId,
    required String token,
    bool setupComplete = false,
    bool onboardingComplete = false,
    String? accountType,
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
    if (accountType != null) {
      await _storage.write(key: _keyAccountType, value: accountType);
    }
    _state = AuthState(
      userId: userId,
      token: token,
      isSetupComplete: setupComplete,
      isOnboardingComplete: onboardingComplete,
      accountType: accountType,
    );
    notifyListeners();
  }

  Future<void> setAccountType(String accountType) async {
    await _storage.write(key: _keyAccountType, value: accountType);
    _state = _state.copyWith(accountType: accountType);
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

  Future<void> setAwaitingConsent({required String maskedParentEmail}) async {
    await _storage.write(key: _keyAwaitingConsent, value: 'true');
    await _storage.write(key: _keyMaskedParentEmail, value: maskedParentEmail);
    _state = _state.copyWith(
      awaitingConsent: true,
      maskedParentEmail: maskedParentEmail,
    );
    notifyListeners();
  }

  Future<void> clearAwaitingConsent() async {
    await _storage.delete(key: _keyAwaitingConsent);
    await _storage.delete(key: _keyMaskedParentEmail);
    _state = _state.copyWith(
      awaitingConsent: false,
      maskedParentEmail: null,
    );
    notifyListeners();
  }

  Future<void> markBiometricRegistered() async {
    await _storage.write(key: _keyBiometricRegistered, value: 'true');
  }

  Future<bool> isBiometricRegistered() async {
    return await _storage.read(key: _keyBiometricRegistered) == 'true';
  }

  Future<String?> getLastUserId() async {
    return _storage.read(key: _keyLastUserId);
  }

  Future<void> clearBiometricRegistration() async {
    await _storage.delete(key: _keyBiometricRegistered);
    await _storage.delete(key: _keyLastUserId);
  }

  Future<void> signOut() async {
    if (_state.userId != null) {
      await _storage.write(key: _keyLastUserId, value: _state.userId);
    }
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keySetupComplete);
    await _storage.delete(key: _keyOnboardingComplete);
    await _storage.delete(key: _keyChildName);
    await _storage.delete(key: _keyAccountType);
    await _storage.delete(key: _keyAwaitingConsent);
    await _storage.delete(key: _keyMaskedParentEmail);
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
