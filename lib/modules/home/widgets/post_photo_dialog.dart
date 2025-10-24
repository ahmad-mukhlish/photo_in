import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../home_controller.dart';

class PostPhotoDialog extends StatefulWidget {
  const PostPhotoDialog({super.key, required this.controller});

  final HomeController controller;

  @override
  State<PostPhotoDialog> createState() => _PostPhotoDialogState();
}

class _PostPhotoDialogState extends State<PostPhotoDialog> {
  final captionController = TextEditingController();
  final picker = ImagePicker();
  XFile? selectedImage;
  bool isSubmitting = false;

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          selectedImage = file;
        });
      }
    } catch (_) {
      Get.snackbar(
        'Photo selection failed',
        'Unable to access the ${source == ImageSource.camera ? 'camera' : 'gallery'}.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _submit() async {
    if (isSubmitting) {
      return;
    }
    final image = selectedImage;
    if (image == null) {
      Get.snackbar(
        'No photo',
        'Please choose a photo before posting.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final success = await widget.controller.submitPost(
      photo: image,
      caption: captionController.text.trim(),
    );

    if (success && mounted) {
      Get.back<void>();
    }

    if (mounted) {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create post',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: selectedImage == null
                      ? Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSubmitting ? null : () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isSubmitting ? null : () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: captionController,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

