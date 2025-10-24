import 'package:get/get.dart';

import '../../data/models/post.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/post_repository.dart';
import '../../routes/app_routes.dart';

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

    isPosting.value = true;
    try {
      Get.snackbar(
        'Post photo',
        'Photo upload is not available yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
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
