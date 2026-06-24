import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
        final teams = state.filtered;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(
            title: 'Teams',
            action: GestureDetector(
              onTap: () => _showTeamSheet(ctx, null),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(999)),
                child: const Text('+ New',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: SearchBarField(
                  hint: 'Search teams…',
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
                        color: AppColors.errorSoft,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm)),
                    child: Text(state.error!,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 13)),
                  ),
                ),
              if (state.isLoading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accent)))
              else if (teams.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.groups_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No teams yet'
                              : 'No results found',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          const Text('Tap + New to add your first team',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textMuted)),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: teams.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _TeamCard(
                      team: teams[i],
                      onEdit: () => _showTeamSheet(ctx, teams[i]),
                      onDelete: () => _confirmDelete(ctx, teams[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showTeamSheet(BuildContext ctx, Team? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<TeamsMgmtCubit>(),
        child: _TeamSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, Team team) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete team?'),
        content: Text('Remove "${team.teamName}" from your teams?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<TeamsMgmtCubit>().delete(team.id);
    }
  }
}

// ── Team Card ─────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final Team team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeamCard(
      {required this.team, required this.onEdit, required this.onDelete});

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
                    color: AppColors.accentSoft, shape: BoxShape.circle),
                child: Center(
                  child: Text(team.initials,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(team.teamName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    if (team.leader.isNotEmpty)
                      Text('Leader: ${team.leader}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(999)),
                child: Text('${team.membersCount} members',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tagText)),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textMuted),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete',
                          style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          if (team.contact.isNotEmpty || team.email.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            if (team.contact.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(team.contact,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary))),
                  CallButton(number: team.contact, size: 32),
                ],
              ),
            if (team.email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(team.email,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary))),
                ],
              ),
            ],
          ],
          if (team.skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: team.skills
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.tagBg,
                            borderRadius: BorderRadius.circular(999)),
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.tagText)),
                      ))
                  .toList(),
            ),
          ],
          if (team.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(team.notes,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

// ── Team Form Sheet ───────────────────────────────────────────────────────────

class _TeamSheet extends StatefulWidget {
  final Team? existing;
  const _TeamSheet({this.existing});

  @override
  State<_TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends State<_TeamSheet> {
  late final TextEditingController _teamName;
  late final TextEditingController _leader;
  late final TextEditingController _contact;
  late final TextEditingController _email;
  late final TextEditingController _membersCount;
  late final TextEditingController _skills;
  late final TextEditingController _notes;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _teamName = TextEditingController(text: t?.teamName ?? '');
    _leader = TextEditingController(text: t?.leader ?? '');
    _contact = TextEditingController(text: t?.contact ?? '');
    _email = TextEditingController(text: t?.email ?? '');
    _membersCount =
        TextEditingController(text: t != null ? t.membersCount.toString() : '1');
    _skills = TextEditingController(text: t?.skills ?? '');
    _notes = TextEditingController(text: t?.notes ?? '');
  }

  @override
  void dispose() {
    _teamName.dispose();
    _leader.dispose();
    _contact.dispose();
    _email.dispose();
    _membersCount.dispose();
    _skills.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_teamName.text.trim().isEmpty) {
      setState(() => _error = 'Team name is required');
      return;
    }
    final count = int.tryParse(_membersCount.text.trim()) ?? 1;

    setState(() {
      _saving = true;
      _error = null;
    });

    final cubit = context.read<TeamsMgmtCubit>();
    bool success;

    if (widget.existing == null) {
      success = await cubit.create(Team(
        id: 0,
        teamName: _teamName.text.trim(),
        leader: _leader.text.trim(),
        contact: _contact.text.trim(),
        email: _email.text.trim(),
        membersCount: count,
        skills: _skills.text.trim(),
        notes: _notes.text.trim(),
      ));
    } else {
      success = await cubit.update(widget.existing!.copyWith(
        teamName: _teamName.text.trim(),
        leader: _leader.text.trim(),
        contact: _contact.text.trim(),
        email: _email.text.trim(),
        membersCount: count,
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
        _error = 'Failed to save. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.existing == null ? 'New Team' : 'Edit Team',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Spacer(),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field(_teamName, 'Team Name *', 'e.g. Welding Team A'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_leader, 'Leader', 'Leader name')),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(_membersCount, 'No. of Members', '1',
                        type: TextInputType.number)),
              ]),
              const SizedBox(height: 12),
              _field(_contact, 'Contact Number', '+91 98765 43210',
                  type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_email, 'Email', 'team@example.com',
                  type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_skills, 'Skills / Expertise',
                  'e.g. Welding, CNC, Assembly (comma-separated)'),
              const SizedBox(height: 12),
              _field(_notes, 'Notes', 'Optional notes', maxLines: 3),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm)),
                  child: Text(_error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint,
      {TextInputType? type, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          style:
              const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
