import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-screen, pinch-to-zoom photo viewer — retailers zoom a product photo
/// to read the pack label before ordering in bulk. `InteractiveViewer` gives
/// pinch + pan; closing is the ✕ button or the system back gesture.
Future<void> showImageViewer(BuildContext context, String imageUrl) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    useSafeArea: false,
    builder: (_) => _ImageViewer(imageUrl: imageUrl),
  );
}

class _ImageViewer extends StatelessWidget {
  final String imageUrl;

  const _ImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
