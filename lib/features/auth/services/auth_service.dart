import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pally/core/utils/logger.dart';
import 'package:pally/features/auth/auth_state.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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
  });

  final String userId;
  final String token;
  final bool isNewUser;
  final bool setupComplete;
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _http = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

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
      String email, String password, String name) async {
    try {
      final res = await _http.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {'email': email, 'password': password, 'displayName': name},
      );
      return _parseAuthResponse(res.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResult> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw const AuthException('Google sign-in cancelled');

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw const AuthException('Failed to get Google ID token');
      }

      final res = await _http.post<Map<String, dynamic>>(
        '/api/v1/auth/google',
        data: {'idToken': idToken},
      );
      return _parseAuthResponse(res.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<AuthResult> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw const AuthException('Apple Sign In is only available on iOS');
    }
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final res = await _http.post<Map<String, dynamic>>(
        '/api/v1/auth/apple',
        data: {
          'identityToken': credential.identityToken,
          'authCode': credential.authorizationCode,
        },
      );
      return _parseAuthResponse(res.data!);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
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

  AuthResult _parseAuthResponse(Map<String, dynamic> data) {
    final inner = (data['data'] as Map<String, dynamic>?) ?? data;
    return AuthResult(
      userId: inner['userId'] as String,
      token: inner['token'] as String? ?? '',
      isNewUser: inner['isNewUser'] as bool? ?? false,
      setupComplete: inner['setupComplete'] as bool? ?? false,
    );
  }

  AuthException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map ? body['error'] as String? : null;

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const AuthException(
          'No internet connection — check your WiFi');
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
        return const AuthException('An account with this email already exists');
      case 422:
        return AuthException(serverMsg ?? 'Please check your details');
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
