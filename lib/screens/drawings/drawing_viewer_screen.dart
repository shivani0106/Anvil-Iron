import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../models/drawing.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../cubits/navigation/navigation_cubit.dart';

class DrawingViewerScreen extends StatefulWidget {
  final Drawing drawing;

  const DrawingViewerScreen({super.key, required this.drawing});

  @override
  State<DrawingViewerScreen> createState() => _DrawingViewerScreenState();
}

class _DrawingViewerScreenState extends State<DrawingViewerScreen> {
  late final WebViewController? _webController;

  @override
  void initState() {
    super.initState();
    _webController = _needsWebView ? _buildWebController() : null;
  }

  bool get _needsWebView {
    final t = widget.drawing.fileType.toLowerCase();
    return t == 'dwg' || t == 'dxf' || t == 'step' || t == 'sldprt';
  }

  WebViewController _buildWebController() {
    final url = widget.drawing.signedUrl ?? '';
    final viewerUrl =
        'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}&embedded=true';
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(viewerUrl));
  }

  Future<void> _openExternal() async {
    final url = widget.drawing.signedUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawing = widget.drawing;
    final url = drawing.signedUrl ?? '';
    final fileType = drawing.fileType.toLowerCase();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: ScreenAppBar(
        title: drawing.fileName,
        action: IconButton(
          icon: Icon(Icons.download_outlined, color: context.colors.textPrimary),
          onPressed: _openExternal,
          tooltip: 'Open / Download',
        ),
      ),
      body: url.isEmpty
          ? _buildNoUrl(context)
          : _buildViewer(context, fileType, url),
    );
  }

  Widget _buildViewer(BuildContext context, String fileType, String url) {
    if (fileType == 'pdf') {
      return SfPdfViewer.network(url);
    }

    if (fileType == 'jpg' || fileType == 'jpeg' || fileType == 'png') {
      return PhotoView(
        imageProvider: NetworkImage(url),
        backgroundDecoration:
            BoxDecoration(color: context.colors.background),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
      );
    }

    if (_webController != null) {
      return WebViewWidget(controller: _webController);
    }

    return _buildNoUrl(context);
  }

  Widget _buildNoUrl(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined,
                size: 56, color: context.colors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Preview unavailable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No signed URL found for this file.',
              style: TextStyle(
                  fontSize: 14, color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => context.read<NavigationCubit>().back(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
