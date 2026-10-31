import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../../core/utils/formatters.dart';
import '../widgets/local_image.dart';

typedef ViewerImage = ({String id, String path});

/// Full-screen, zoomable, swipeable image viewer.
///
/// Stateful only to own the [PageController] / page notifier lifecycles;
/// the page counter updates through a [ValueNotifier] (no `setState`).
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  final List<ViewerImage> images;
  final int initialIndex;

  static Future<void> open(
    BuildContext context, {
    required List<ViewerImage> images,
    required int initialIndex,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: AppColors.black,
        pageBuilder: (_, _, _) =>
            ImageViewerScreen(images: images, initialIndex: initialIndex),
        transitionsBuilder: (_, Animation<double> animation, _, Widget child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late final ValueNotifier<int> _page = ValueNotifier<int>(widget.initialIndex);

  @override
  void dispose() {
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .round();
    final int total = widget.images.length;
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        foregroundColor: AppColors.white,
        title: total > 1
            ? ValueListenableBuilder<int>(
                valueListenable: _page,
                builder: (BuildContext context, int page, _) => Text(
                  '${Formatters.number(page + 1)} / ${Formatters.number(total)}',
                  style: const TextStyle(color: AppColors.white),
                ),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: total,
        onPageChanged: (int index) => _page.value = index,
        itemBuilder: (BuildContext context, int index) {
          final ViewerImage image = widget.images[index];
          return InteractiveViewer(
            maxScale: 5,
            child: Center(
              child: Hero(
                tag: image.id,
                child: LocalImage(
                  path: image.path,
                  fit: BoxFit.contain,
                  cacheWidth: cacheWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
