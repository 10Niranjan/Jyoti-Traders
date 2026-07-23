import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Square image preview + "choose/change image" action. Handles all three
/// shapes an image can take: a freshly-picked local file, an already-saved
/// value (a real Storage URL, or — in simulation mode, where no bucket
/// exists — a local path), or nothing at all.
///
/// Generic on purpose — reused for product photos, category icons, and UPI
/// payment screenshots, none of which need different picker behavior.
class ImagePickerField extends StatelessWidget {
  final String? pickedPath;
  final String? existingUrl;
  final VoidCallback? onPick;

  const ImagePickerField({
    super.key,
    required this.pickedPath,
    required this.existingUrl,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = isDark ? Colors.white12 : Colors.black12;

    Widget preview;
    if (pickedPath != null) {
      preview = Image.file(File(pickedPath!), fit: BoxFit.cover);
    } else if (existingUrl != null && existingUrl!.isNotEmpty) {
      preview = existingUrl!.startsWith('http')
          ? CachedNetworkImage(imageUrl: existingUrl!, fit: BoxFit.cover)
          : Image.file(File(existingUrl!), fit: BoxFit.cover);
    } else {
      preview = Container(
        color: placeholderColor,
        child: const Center(child: Icon(Icons.add_photo_alternate_outlined, size: 36)),
      );
    }

    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 140,
              height: 140,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
              ),
              child: preview,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(
              pickedPath != null || (existingUrl?.isNotEmpty ?? false) ? 'Change image' : 'Choose image',
            ),
          ),
        ],
      ),
    );
  }
}
