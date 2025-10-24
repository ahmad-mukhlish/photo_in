import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/storage_keys.dart';

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<void> login({
    required String username,
    required String password,
  }) async {
    final payload = jsonEncode({
      'username': username,
      'password': password,
    });

    try {
      final response = await _dio.post<dynamic>(
        '/session',
        data: payload,
        options: Options(
          headers: const {
            Headers.contentTypeHeader: Headers.textPlainContentType,
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AuthException('Unexpected response from server.');
      }

      if (data['ok'] != true) {
        final message = data['message'] as String?;
        throw AuthException(message ?? 'Login failed. Please try again.');
      }

      final tokenPayload = data['data'];
      if (tokenPayload is! Map<String, dynamic>) {
        throw const AuthException('Unable to read authentication tokens.');
      }

      final accessToken = tokenPayload['access_token'] as String?;
      final refreshToken = tokenPayload['refresh_token'] as String?;

      if (accessToken == null || refreshToken == null) {
        throw const AuthException('Authentication tokens missing in response.');
      }

      await _persistTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (error) {
      throw AuthException(_extractDioErrorMessage(error));
    }
  }

  Future<void> _persistTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.accessToken, accessToken);

    if (refreshToken == null) return;

    await prefs.setString(StorageKeys.refreshToken, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.accessToken);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.refreshToken);
  }

  Future<void> refreshSession() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokens();
      throw const AuthException('No refresh token available.');
    }

    try {
      final response = await _dio.put<dynamic>(
        '/session',
        options: Options(
          headers: {
            Headers.contentTypeHeader: Headers.textPlainContentType,
            'Authorization': 'Bearer $refreshToken',
          },
          extra: const {
            'skip_auth': true,
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const AuthException('Unexpected response from server.');
      }

      if (data['ok'] != true) {
        final message = data['message'] as String?;
        throw AuthException(message ?? 'Unable to refresh session. Please log in again.');
      }

      final tokenPayload = data['data'];
      if (tokenPayload is! Map<String, dynamic>) {
        throw const AuthException('Unable to read authentication tokens.');
      }

      final accessToken = tokenPayload['access_token'] as String?;

      if (accessToken == null) {
        throw const AuthException('Authentication tokens missing in response.');
      }

      await _persistTokens(
        accessToken: accessToken,
      );

    } on DioException catch (error) {
      await _clearTokens();
      throw AuthException(_extractDioErrorMessage(error));
    }
  }

  Future<void> logout() async {
    await _clearTokens();
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.accessToken);
    await prefs.remove(StorageKeys.refreshToken);
  }

  String _extractDioErrorMessage(DioException error) {
    const fallbackMessage = 'Unable to log in. Please try again.';
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      return responseData;
    }

    if (error.message != null && error.message!.isNotEmpty) {
      return error.message!;
    }

    return fallbackMessage;
  }
}
