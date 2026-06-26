import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/teams_mgmt/teams_mgmt_cubit.dart';
import '../../cubits/teams_mgmt/teams_mgmt_state.dart';
import '../../models/team.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/call_button.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeamsMgmtCubit, TeamsMgmtState>(
      builder: (ctx, state) {
        final teammates = state.filtered;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: ScreenAppBar(
            title: 'Team',
            action: GestureDetector(
              onTap: () => _showSheet(ctx, null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColorScheme.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '+ Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: SearchBarField(
                  hint: 'Search teammates…',
                  onChanged: (q) => ctx.read<TeamsMgmtCubit>().setSearch(q),
                  value: state.searchQuery,
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.colors.errorSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Text(state.error!,
                        style: const TextStyle(color: AppColorScheme.error, fontSize: 13)),
                  ),
                ),
              if (state.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColorScheme.accent),
                  ),
                )
              else if (teammates.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_outlined,
                            size: 48, color: context.colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No teammates yet'
                              : 'No results found',
                          style: TextStyle(
                              fontSize: 14, color: context.colors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Tap + Add to add your first teammate',
                            style: TextStyle(
                                fontSize: 12, color: context.colors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: teammates.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _TeammateCard(
                      teammate: teammates[i],
                      onEdit: () => _showSheet(ctx, teammates[i]),
                      onDelete: () => _confirmDelete(ctx, teammates[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSheet(BuildContext ctx, Teammate? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<TeamsMgmtCubit>(),
        child: _TeammateSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, Teammate teammate) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Remove teammate?'),
        content: Text('Remove "${teammate.name}" from your team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Remove',
                style: TextStyle(color: AppColorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<TeamsMgmtCubit>().delete(teammate.id);
    }
  }
}

class _TeammateCard extends StatelessWidget {
  final Teammate teammate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeammateCard({
    required this.teammate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    teammate.initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColorScheme.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  teammate.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    size: 18, color: context.colors.textMuted),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Remove',
                        style: TextStyle(color: AppColorScheme.error)),
                  ),
                ],
              ),
            ],
          ),
          if (teammate.contact.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: context.colors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.phone_outlined,
                    size: 14, color: context.colors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    teammate.contact,
                    style: TextStyle(
                        fontSize: 13, color: context.colors.textSecondary),
                  ),
                ),
                CallButton(number: teammate.contact, size: 32),
              ],
            ),
          ],
          if (teammate.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: teammate.skills
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: context.colors.tagBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 11, color: context.colors.tagText)),
                      ))
                  .toList(),
            ),
          ],
          if (teammate.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              teammate.notes,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeammateSheet extends StatefulWidget {
  final Teammate? existing;
  const _TeammateSheet({this.existing});

  @override
  State<_TeammateSheet> createState() => _TeammateSheetState();
}

class _TeammateSheetState extends State<_TeammateSheet> {
  late final TextEditingController _name;
  late final TextEditingController _contact;
  late final TextEditingController _skills;
  late final TextEditingController _notes;
  Map<String, String> _fieldErrors = {};
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _name = TextEditingController(text: t?.name ?? '');
    _contact = TextEditingController(text: t?.contact ?? '');
    _skills = TextEditingController(text: t?.skills ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _skills.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = <String, String>{};

    final nameErr = AppValidators.required(_name.text, 'Name');
    if (nameErr != null) errors['name'] = nameErr;

    final contactErr = AppValidators.phone(_contact.text);
    if (contactErr != null) errors['contact'] = contactErr;

    if (errors.isNotEmpty) {
      setState(() { _fieldErrors = errors; _saveError = null; });
      return;
    }

    setState(() { _saving = true; _fieldErrors = {}; _saveError = null; });

    final cubit = context.read<TeamsMgmtCubit>();
    final bool success;

    if (widget.existing == null) {
      success = await cubit.create(Teammate(
        id: 0,
        name: _name.text.trim(),
        contact: _contact.text.trim(),
        skills: _skills.text.trim(),
        notes: _notes.text.trim(),
      ));
    } else {
      success = await cubit.update(widget.existing!.copyWith(
        name: _name.text.trim(),
        contact: _contact.text.trim(),
        skills: _skills.text.trim(),
        notes: _notes.text.trim(),
      ));
    }

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _saveError = 'Unable to save data. Please check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.existing == null ? 'Add Teammate' : 'Edit Teammate',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _field(_name, 'Name *', 'e.g. Ramesh Patel', fieldKey: 'name'),
            const SizedBox(height: 12),
            _field(_contact, 'Contact Number', '+91 98765 43210',
                fieldKey: 'contact', type: TextInputType.phone),
            const SizedBox(height: 12),
            _field(_skills, 'Skills', 'e.g. Welding, CNC, Assembly (comma-separated)'),
            const SizedBox(height: 12),
            _field(_notes, 'Notes', 'Optional notes', maxLines: 3),
            if (_saveError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colors.errorSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 14, color: AppColorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_saveError!, style: const TextStyle(color: AppColorScheme.error, fontSize: 13))),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label,
    String hint, {
    String? fieldKey,
    TextInputType? type,
    int maxLines = 1,
  }) {
    final error = fieldKey != null ? _fieldErrors[fieldKey] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.textSecondary,
            )),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          onChanged: fieldKey != null
              ? (_) {
                  if (_fieldErrors.containsKey(fieldKey)) {
                    setState(() => _fieldErrors.remove(fieldKey));
                  }
                }
              : null,
          decoration: InputDecoration(hintText: hint, errorText: error),
          style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
        ),
      ],
    );
  }
}
