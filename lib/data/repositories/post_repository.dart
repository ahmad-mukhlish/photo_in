import 'package:dio/dio.dart';

import '../models/post.dart';
import '../network/dio_extra_keys.dart';

class FeedException implements Exception {
  const FeedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PostRepository {
  PostRepository(this._dio);

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get<dynamic>(
        '/posts',
        options: Options(
          extra: const {
            DioExtraKeys.retryAttempted: false,
          },
        ),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FeedException('Unexpected response from server.');
      }

      if (data['ok'] != true) {
        final message = data['message'] as String?;
        throw FeedException(message ?? 'Unable to load posts.');
      }

      final payload = data['data'];
      if (payload is! Map<String, dynamic>) {
        throw const FeedException('Missing feed data in response.');
      }

      final posts = payload['posts'];
      if (posts is! List) {
        throw const FeedException('Posts are missing from the response.');
      }

      return posts
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList(growable: false);
    } on DioException catch (error) {
      throw FeedException(_extractDioErrorMessage(error));
    }
  }

  String _extractDioErrorMessage(DioException error) {
    const fallbackMessage = 'Unable to load posts. Please try again.';
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

