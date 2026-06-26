import 'package:flutter/material.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';

class AgentInputBar extends StatefulWidget {
  final bool isLoading;
  final void Function(String) onSend;

  const AgentInputBar({
    super.key,
    required this.isLoading,
    required this.onSend,
  });

  @override
  State<AgentInputBar> createState() => _AgentInputBarState();
}

class _AgentInputBarState extends State<AgentInputBar> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isLoading,
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.send,
              maxLines: 3,
              minLines: 1,
              style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Ask anything about your business…',
                hintStyle: TextStyle(fontSize: 14, color: context.colors.textSecondary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(color: AppColorScheme.accent, width: 1.5),
                ),
                filled: true,
                fillColor: context.colors.background,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.isLoading ? null : _submit,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.isLoading ? context.colors.textSecondary : AppColorScheme.accent,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: widget.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
