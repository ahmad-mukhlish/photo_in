import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class PostRemoteDataSource {
  PostRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<dynamic>> fetchPosts() async {
    final response = await _dio.get<dynamic>('/posts');

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const PostApiException('Unexpected response from server.');
    }

    if (data['ok'] != true) {
      final message = data['message'] as String?;
      throw PostApiException(message ?? 'Unable to load posts.');
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const PostApiException('Missing feed data in response.');
    }

    final posts = payload['posts'];
    if (posts is! List) {
      throw const PostApiException('Posts are missing from the response.');
    }

    return posts;
  }

  Future<String> requestUploadUrl() async {
    final response = await _dio.post<dynamic>('/photo-urls');
    final data = response.data;

    if (data is! Map<String, dynamic>) {
      throw const PostApiException('Unexpected response from server.');
    }

    if (data['ok'] != true) {
      final message = data['message'] as String?;
      throw PostApiException(message ?? 'Unable to request photo URL.');
    }

    final payload = data['data'];
    if (payload is! Map<String, dynamic>) {
      throw const PostApiException('photo_url missing from response.');
    }

    final photoUrl = payload['photo_url'];
    if (photoUrl is! String || photoUrl.isEmpty) {
      throw const PostApiException('photo_url missing from response.');
    }

    return photoUrl;
  }

  Future<void> uploadPhotoToUrl({
    required String uploadUrl,
    required XFile file,
  }) async {
    final mimeType = _resolveMimeType(file.path);
    final fileHandle = File(file.path);
    final length = await fileHandle.length();

    final response = await _dio.put<dynamic>(
      uploadUrl,
      data: fileHandle.openRead(),
      options: Options(
        headers: {
          'Content-Type': mimeType,
          'Content-Length': length,
          'x-amz-acl': 'public-read',
        },
        extra: const {
          'skip_auth': true,
        },
        contentType: mimeType,
        responseType: ResponseType.bytes,
      ),
    );

    final statusCode = response.statusCode ?? 0;
    if (statusCode < 200 || statusCode >= 300) {
      throw const PostApiException('Failed to upload photo.');
    }
  }

  Future<Map<String, dynamic>> submitPost({
    required String photoUrl,
    required String caption,
  }) async {
    final response = await _dio.post<dynamic>(
      '/posts',
      data: {
        'photo_url': photoUrl,
        'caption': caption,
      },
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const PostApiException('Unexpected response from server.');
    }

    if (data['ok'] != true) {
      final message = data['message'] as String?;
      throw PostApiException(message ?? 'Unable to submit post.');
    }

    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      return payload;
    }

    throw const PostApiException('Post data missing from response.');
  }

  String _resolveMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}

class PostApiException implements Exception {
  const PostApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
