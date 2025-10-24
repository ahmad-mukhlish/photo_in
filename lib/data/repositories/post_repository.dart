import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../data_sources/post_remote_data_source.dart';
import '../models/post.dart';
class PostRepository {
  PostRepository(this._dio)
      : _remoteDataSource = PostRemoteDataSource(_dio);

  final Dio _dio;
  final PostRemoteDataSource _remoteDataSource;

  Future<List<Post>> fetchPosts() async {
    try {
      final posts = await _remoteDataSource.fetchPosts();
      return posts
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList(growable: false);
    } on PostApiException catch (error) {
      throw FeedException(error.message);
    } on DioException catch (error) {
      throw FeedException(_extractDioErrorMessage(error));
    }
  }

  Future<Post> createPost({
    required XFile photo,
    required String caption,
  }) async {
    try {
      final uploadUrl = await _remoteDataSource.requestUploadUrl();
      await _remoteDataSource.uploadPhotoToUrl(
        uploadUrl: uploadUrl,
        file: photo,
      );
      final response = await _remoteDataSource.submitPost(
        photoUrl: uploadUrl,
        caption: caption,
      );
      return Post.fromJson(response);
    } on PostApiException catch (error) {
      throw FeedException(error.message);
    } on DioException catch (error) {
      throw FeedException(
        _extractDioErrorMessage(
          error,
          fallbackMessage: 'Unable to upload photo. Please try again.',
        ),
      );
    }
  }

  String _extractDioErrorMessage(
    DioException error, {
    String fallbackMessage = 'Unable to load posts. Please try again.',
  }) {
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

class FeedException implements Exception {
  const FeedException(this.message);

  final String message;

  @override
  String toString() => message;
}
