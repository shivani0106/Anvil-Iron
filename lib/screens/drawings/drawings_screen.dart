import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/drawings/drawings_cubit.dart';
import '../../cubits/drawings/drawings_state.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../models/drawing.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/search_bar_field.dart';

class DrawingsScreen extends StatelessWidget {
  const DrawingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingsCubit, DrawingsState>(
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: ctx.colors.background,
          appBar: const ScreenAppBar(title: 'Drawings', showBack: false),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColorScheme.accent,
            foregroundColor: Colors.white,
            tooltip: 'Upload drawing',
            onPressed: () => _showUploadSheet(ctx),
            child: state.isUploading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Icon(Icons.upload_file),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: SearchBarField(
                  hint: 'Search drawings…',
                  value: state.searchQuery,
                  onChanged: (q) => ctx.read<DrawingsCubit>().setSearch(q),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(ctx, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DrawingsState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColorScheme.accent),
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Failed to load drawings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.error,
                style: TextStyle(
                    fontSize: 13, color: context.colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context.read<DrawingsCubit>().loadData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final drawings = state.filteredDrawings;

    if (drawings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined,
                  size: 56, color: context.colors.textMuted),
              const SizedBox(height: 14),
              Text(
                state.searchQuery.isEmpty
                    ? 'No drawings yet'
                    : 'No results for "${state.searchQuery}"',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              if (state.searchQuery.isEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Tap the upload button to add a drawing.',
                  style: TextStyle(
                      fontSize: 14, color: context.colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
      itemCount: drawings.length,
      separatorBuilder: (ctx2, i) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _DrawingTile(drawing: drawings[i]),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<DrawingsCubit>(),
        child: BlocProvider.value(
          value: context.read<NavigationCubit>(),
          child: const _UploadSheet(),
        ),
      ),
    );
  }
}

class _DrawingTile extends StatelessWidget {
  final Drawing drawing;

  const _DrawingTile({required this.drawing});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: () => context
          .read<NavigationCubit>()
          .navigateTo(AppScreen.drawingViewer, drawingId: drawing.id),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colors.tagBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Center(
              child: Text(
                drawing.extension,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: context.colors.tagText,
                  letterSpacing: 0.04,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  drawing.fileName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  drawing.customer.isEmpty ? 'No customer' : drawing.customer,
                  style: TextStyle(
                      fontSize: 12, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (drawing.formattedSize.isNotEmpty)
                Text(
                  drawing.formattedSize,
                  style: TextStyle(
                      fontSize: 11, color: context.colors.textMuted),
                ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.tagBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  drawing.rev,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colors.tagText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadSheet extends StatefulWidget {
  const _UploadSheet();

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _customerCtrl = TextEditingController();
  final _revCtrl = TextEditingController();

  @override
  void dispose() {
    _customerCtrl.dispose();
    _revCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upload Drawing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(Icons.close, color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _customerCtrl,
            decoration: const InputDecoration(labelText: 'Customer'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _revCtrl,
            decoration:
                const InputDecoration(labelText: 'Revision (e.g. rev 2)'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.folder_open_outlined),
              label: const Text('Choose file & upload'),
              onPressed: () async {
                final nav = context.read<NavigationCubit>();
                final cubit = context.read<DrawingsCubit>();
                Navigator.of(context).pop();
                final drawing = await cubit.pickAndUpload(
                  customer: _customerCtrl.text.trim(),
                  rev: _revCtrl.text.trim(),
                );
                if (drawing != null) {
                  nav.showToast('Uploaded ${drawing.fileName}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
