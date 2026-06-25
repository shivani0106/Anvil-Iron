import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/machines/machines_cubit.dart';
import '../../cubits/machines/machines_state.dart';
import '../../models/machine.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/progress_bar.dart';

class MachinesScreen extends StatelessWidget {
  const MachinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MachinesCubit, MachinesState>(
      builder: (ctx, state) {
        final machines = state.filtered;
        final running =
            machines.where((m) => m.status == MachineStatus.running).length;
        final idle =
            machines.where((m) => m.status == MachineStatus.idle).length;
        final maintenance =
            machines.where((m) => m.status == MachineStatus.maintenance).length;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(
            title: 'Machines',
            action: GestureDetector(
              onTap: () => _showMachineSheet(ctx, null),
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
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  children: [
                    _MiniStat(
                        label: 'Running',
                        value: '$running',
                        color: AppColors.machineRunning),
                    const SizedBox(width: 10),
                    _MiniStat(
                        label: 'Idle',
                        value: '$idle',
                        color: AppColors.machineIdle),
                    const SizedBox(width: 10),
                    _MiniStat(
                        label: 'Maintenance',
                        value: '$maintenance',
                        color: AppColors.machineMaintenance),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                child: SearchBarField(
                  hint: 'Search machines…',
                  onChanged: (q) => ctx.read<MachinesCubit>().setSearch(q),
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
              else if (machines.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.precision_manufacturing_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No machines yet'
                              : 'No results found',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          const Text('Tap + New to add your first machine',
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
                    itemCount: machines.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) => _MachineCard(
                      machine: machines[i],
                      onEdit: () => _showMachineSheet(ctx, machines[i]),
                      onDelete: () => _confirmDelete(ctx, machines[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMachineSheet(BuildContext ctx, Machine? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<MachinesCubit>(),
        child: _MachineSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, Machine machine) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete machine?'),
        content: Text('Remove "${machine.name}" from your machines?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<MachinesCubit>().delete(machine.id);
    }
  }
}

// ── Machine Card ──────────────────────────────────────────────────────────────

Color _statusColor(MachineStatus s) {
  switch (s) {
    case MachineStatus.running:
      return AppColors.machineRunning;
    case MachineStatus.idle:
      return AppColors.machineIdle;
    case MachineStatus.maintenance:
      return AppColors.machineMaintenance;
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MachineCard(
      {required this.machine, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(machine.status);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration:
                    BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                child: Center(
                  child: Text(machine.initials,
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
                    Text(machine.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    if (machine.machineNumber.isNotEmpty)
                      Text('ID: ${machine.machineNumber}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(machine.statusLabel,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ],
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
          if (machine.status == MachineStatus.running) ...[
            const SizedBox(height: 9),
            AppProgressBar(value: machine.utilization, color: color, height: 6),
            const SizedBox(height: 4),
            Text('${(machine.utilization * 100).toInt()}% utilization',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
          if (machine.type.isNotEmpty ||
              machine.manufacturer.isNotEmpty ||
              machine.capacity.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (machine.type.isNotEmpty)
                  _DetailChip(label: machine.type, icon: Icons.category_outlined),
                if (machine.manufacturer.isNotEmpty)
                  _DetailChip(
                      label: machine.manufacturer,
                      icon: Icons.factory_outlined),
                if (machine.capacity.isNotEmpty)
                  _DetailChip(
                      label: machine.capacity,
                      icon: Icons.speed_outlined),
              ],
            ),
          ],
          if (machine.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(machine.note,
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

class _DetailChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _DetailChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.tagBg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Machine Form Sheet ────────────────────────────────────────────────────────

class _MachineSheet extends StatefulWidget {
  final Machine? existing;
  const _MachineSheet({this.existing});

  @override
  State<_MachineSheet> createState() => _MachineSheetState();
}

class _MachineSheetState extends State<_MachineSheet> {
  late final TextEditingController _name;
  late final TextEditingController _machineNumber;
  late final TextEditingController _type;
  late final TextEditingController _manufacturer;
  late final TextEditingController _modelNumber;
  late final TextEditingController _capacity;
  late final TextEditingController _purchaseDate;
  late final TextEditingController _utilization;
  late final TextEditingController _note;
  late MachineStatus _status;
  Map<String, String> _fieldErrors = {};
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _name = TextEditingController(text: m?.name ?? '');
    _machineNumber = TextEditingController(text: m?.machineNumber ?? '');
    _type = TextEditingController(text: m?.type ?? '');
    _manufacturer = TextEditingController(text: m?.manufacturer ?? '');
    _modelNumber = TextEditingController(text: m?.modelNumber ?? '');
    _capacity = TextEditingController(text: m?.capacity ?? '');
    _purchaseDate = TextEditingController(text: m?.purchaseDate ?? '');
    _utilization = TextEditingController(
        text: m != null ? (m.utilization * 100).toInt().toString() : '0');
    _note = TextEditingController(text: m?.note ?? '');
    _status = m?.status ?? MachineStatus.idle;
  }

  @override
  void dispose() {
    _name.dispose();
    _machineNumber.dispose();
    _type.dispose();
    _manufacturer.dispose();
    _modelNumber.dispose();
    _capacity.dispose();
    _purchaseDate.dispose();
    _utilization.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = <String, String>{};

    final nameErr = AppValidators.required(_name.text, 'Machine name');
    if (nameErr != null) errors['name'] = nameErr;

    final utilErr = AppValidators.percentage(_utilization.text);
    if (utilErr != null) errors['utilization'] = utilErr;

    if (errors.isNotEmpty) {
      setState(() { _fieldErrors = errors; _saveError = null; });
      return;
    }

    final utilPct = int.tryParse(_utilization.text.trim()) ?? 0;

    setState(() { _saving = true; _fieldErrors = {}; _saveError = null; });

    final cubit = context.read<MachinesCubit>();
    bool success;

    if (widget.existing == null) {
      success = await cubit.create(Machine(
        id: 0,
        name: _name.text.trim(),
        status: _status,
        utilization: utilPct / 100,
        note: _note.text.trim(),
        machineNumber: _machineNumber.text.trim(),
        type: _type.text.trim(),
        manufacturer: _manufacturer.text.trim(),
        modelNumber: _modelNumber.text.trim(),
        capacity: _capacity.text.trim(),
        purchaseDate: _purchaseDate.text.trim(),
      ));
    } else {
      success = await cubit.update(widget.existing!.copyWith(
        name: _name.text.trim(),
        status: _status,
        utilization: utilPct / 100,
        note: _note.text.trim(),
        machineNumber: _machineNumber.text.trim(),
        type: _type.text.trim(),
        manufacturer: _manufacturer.text.trim(),
        modelNumber: _modelNumber.text.trim(),
        capacity: _capacity.text.trim(),
        purchaseDate: _purchaseDate.text.trim(),
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
                  Text(
                      widget.existing == null ? 'New Machine' : 'Edit Machine',
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
              _field(_name, 'Machine Name *', 'e.g. CNC Lathe', fieldKey: 'name'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_machineNumber, 'Machine ID', 'e.g. MCH-001')),
                const SizedBox(width: 12),
                Expanded(child: _field(_type, 'Type', 'e.g. Lathe, Mill')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_manufacturer, 'Manufacturer', 'e.g. Mazak')),
                const SizedBox(width: 12),
                Expanded(child: _field(_modelNumber, 'Model Number', 'e.g. QT-250')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_capacity, 'Capacity', 'e.g. 500 kg')),
                const SizedBox(width: 12),
                Expanded(child: _field(_purchaseDate, 'Purchase Date', 'e.g. 2023-01-15')),
              ]),
              const SizedBox(height: 12),
              const Text('Status',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              SegmentedButton<MachineStatus>(
                segments: const [
                  ButtonSegment(value: MachineStatus.running, label: Text('Running')),
                  ButtonSegment(value: MachineStatus.idle, label: Text('Idle')),
                  ButtonSegment(value: MachineStatus.maintenance, label: Text('Maintenance')),
                ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(height: 12),
              _field(_utilization, 'Utilization %', '0',
                  fieldKey: 'utilization', type: TextInputType.number),
              const SizedBox(height: 12),
              _field(_note, 'Notes', 'Optional notes', maxLines: 3),
              if (_saveError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_outlined, size: 14, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_saveError!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
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
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
