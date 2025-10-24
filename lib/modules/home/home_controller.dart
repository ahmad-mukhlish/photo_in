import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/post.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../routes/app_routes.dart';
import 'widgets/post_photo_dialog.dart';

class HomeController extends GetxController {
  HomeController(
    this._authRepository,
    this._postRepository,
  );

  final AuthRepository _authRepository;
  final PostRepository _postRepository;
  final isProcessing = false.obs;
  final isPosting = false.obs;
  final posts = <Post>[].obs;
  final isFeedLoading = false.obs;
  final feedError = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadFeed();
  }

  Future<void> loadFeed({bool force = false}) async {
    if (isFeedLoading.value) {
      if (!force) {
        return;
      }

      while (isFeedLoading.value) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }

    isFeedLoading.value = true;
    feedError.value = null;

    try {
      final fetchedPosts = await _postRepository.fetchPosts();
      posts.assignAll(fetchedPosts);
    } on FeedException catch (error) {
      feedError.value = error.message;
      if (posts.isNotEmpty) {
        Get.snackbar(
          'Feed unavailable',
          error.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      const message = 'Unexpected error occurred while loading posts.';
      feedError.value = message;
      if (posts.isNotEmpty) {
        Get.snackbar(
          'Feed unavailable',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isFeedLoading.value = false;
    }
  }

  Future<void> postPhoto() async {
    if (isPosting.value) {
      return;
    }

    await Get.dialog<void>(
      PostPhotoDialog(controller: this),
      barrierDismissible: true,
    );
  }

  Future<bool> submitPost({
    required XFile photo,
    required String caption,
  }) async {
    if (isPosting.value) {
      return false;
    }

    isPosting.value = true;
    try {
      final createdPost = await _postRepository.createPost(
        photo: photo,
        caption: caption,
      );
      posts.insert(0, createdPost);
      Get.snackbar(
        'Photo posted',
        'Your photo has been shared.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on FeedException catch (error) {
      Get.snackbar(
        'Upload failed',
        error.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Upload failed',
        'Unexpected error occurred while uploading photo.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> logout() async {
    if (isProcessing.value) {
      return;
    }

    isProcessing.value = true;
    try {
      await _authRepository.logout();
      Get.offAllNamed(Routes.login);
    } catch (_) {
      Get.snackbar(
        'Logout failed',
        'Unable to log out. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
