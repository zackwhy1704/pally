import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';

const _baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://pallybackend-production.up.railway.app',
);

class AuthResult {
  const AuthResult({
    required this.userId,
    required this.token,
    this.isNewUser = false,
    this.setupComplete = false,
    this.accountType,
  });

  final String userId;
  final String token;
  final bool isNewUser;
  final bool setupComplete;

  /// "PARENT" or "STUDENT" — returned from login/register.
  final String? accountType;
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  static const _storage = FlutterSecureStorage();

  final _http = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final res = await _http.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      return _parseAuthResponse(res.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResult> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      // 13+-only app: no DOB collected, no role (everyone is a student). Age is
      // self-attested at the self-consent gate. Backend treats absent birthYear
      // as 13+, so nothing extra is sent here.
      final res = await _http.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': name,
        },
      );
      return _parseAuthResponse(res.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> signOut() async {
    await AuthNotifier.instance.signOut();
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _http.post<void>(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResult> verifyBiometric({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final res = await _http.post<Map<String, dynamic>>(
        '/api/v1/auth/biometric/verify',
        data: {
          'userId': userId,
          'deviceId': deviceId,
        },
      );
      return _parseAuthResponse(res.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> registerBiometricDevice({
    required String deviceId,
    required String deviceName,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _http.post<void>(
        '/api/v1/auth/biometric/register',
        data: {'deviceId': deviceId, 'deviceName': deviceName},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (_) {}
  }

  AuthResult _parseAuthResponse(Map<String, dynamic> data) {
    final inner = (data['data'] as Map<String, dynamic>?) ?? data;
    return AuthResult(
      userId: inner['userId'] as String,
      token: inner['token'] as String? ?? '',
      isNewUser: inner['isNewUser'] as bool? ?? false,
      setupComplete: inner['setupComplete'] as bool? ?? false,
      accountType: inner['accountType'] as String?,
    );
  }

  AuthException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map ? body['error'] as String? : null;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const AuthException('No internet connection — check your WiFi');
    }

    switch (status) {
      case 401:
        if (serverMsg?.contains('password') == true) {
          return const AuthException('Incorrect password — try again');
        }
        return const AuthException('Incorrect email or password');
      case 404:
        return const AuthException('No account found for this email');
      case 409:
        return const AuthException(
            'An account with this email already exists');
      case 422:
        return AuthException(serverMsg ?? 'Please check your details');
      case 423:
        return AuthException(
            serverMsg ?? 'Account temporarily locked — try again later');
      default:
        appLog.e('[Auth] Unexpected error $status: $serverMsg');
        return AuthException(serverMsg ?? 'Something went wrong');
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
