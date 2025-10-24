import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/post.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.photo_library_outlined),
                text: 'Feed',
              ),
              Tab(
                icon: Icon(Icons.person_outline),
                text: 'Account',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _FeedTab(controller: controller),
            _AccountTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  const _FeedTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final isLoading = controller.isFeedLoading.value;
      final posts = controller.posts;
      final error = controller.feedError.value;

      if (isLoading && posts.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (error != null && posts.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.loadFeed(force: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load feed',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => controller.loadFeed(force: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadFeed(force: true),
        child: posts.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No posts yet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh the feed.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: posts.length + (isLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  if (index >= posts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final post = posts[index];
                  return _FeedCard(post: post);
                },
              ),
      );
    });
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCaption = post.caption.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: post.photoUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, _) => const _FeedImagePlaceholder(),
            errorWidget: (context, _, __) => const _FeedImageError(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasCaption) ...[
                  Text(
                    post.caption,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  'by ${post.authorUsername}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.formattedCreatedAt,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedImagePlaceholder extends StatelessWidget {
  const _FeedImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _FeedImageError extends StatelessWidget {
  const _FeedImageError();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Welcome to Photo In App'),
          const SizedBox(height: 24),
          Obx(
            () => FilledButton.icon(
              onPressed: controller.isProcessing.value ? null : controller.logout,
              icon: controller.isProcessing.value
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: Text(
                controller.isProcessing.value ? 'Logging out...' : 'Log out',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
