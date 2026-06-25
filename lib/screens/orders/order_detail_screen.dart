import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/job_details/job_details_cubit.dart';
import '../../cubits/job_details/job_details_state.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../cubits/customers/customers_cubit.dart';
import '../../cubits/suppliers/suppliers_cubit.dart';
import '../../models/job_material.dart';
import '../../models/job_team.dart';
import '../../models/order.dart';
import '../../models/customer.dart';
import '../../models/supplier.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/status_chip.dart';
import '../../widgets/common/call_button.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, ordersState) {
        final order = ctx.read<OrdersCubit>().getOrderById(orderId);
        if (order == null) {
          return Scaffold(appBar: ScreenAppBar(title: 'Order'), body: const Center(child: Text('Order not found')));
        }
        return BlocProvider(
          create: (_) => JobDetailsCubit(orderId: orderId)
            ..load(customerId: order.customerId, supplierId: order.supplierId),
          child: _OrderDetailView(order: order),
        );
      },
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final Order order;
  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobDetailsCubit, JobDetailsState>(
      builder: (ctx, jobState) {
        final stageColor = StatusChip.colorForOrderStage(order.stage, order.delivered);

        String advLabel;
        bool advDisabled = false;
        if (order.delivered) {
          advLabel = '✓ Delivered';
          advDisabled = true;
        } else if (order.stage == OrderStage.ready) {
          advLabel = 'Mark as Delivered';
        } else {
          advLabel = 'Advance → ${Order.stageLabels[order.stage.index + 1]}';
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(title: '#${order.id} · ${order.customer}'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(order.item,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.02)),
                    ),
                    StatusChip(label: order.stageLabel, color: stageColor),
                  ],
                ),
                const SizedBox(height: 6),
                _WorkTypeBadge(workType: order.workType),
                const SizedBox(height: 16),
                _buildDetailsGrid(order),
                const SizedBox(height: 20),
                const Text('Production Stages', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 14),
                _buildProductionStages(jobState),
                const SizedBox(height: 24),
                if (!advDisabled)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ordersCubit = ctx.read<OrdersCubit>();
                        final navCubit = ctx.read<NavigationCubit>();
                        await ordersCubit.advanceStage(order.id);
                        final updated = ordersCubit.getOrderById(order.id);
                        if (updated != null && updated.delivered) {
                          navCubit.showToast('Order #${order.id} delivered ✓');
                        } else if (updated != null) {
                          navCubit.showToast('Moved to ${updated.stageLabel}');
                        }
                      },
                      child: Text(advLabel),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.statusDelivered.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: const Center(
                      child: Text('✓ Delivered',
                          style: TextStyle(color: AppColors.statusDelivered, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                const SizedBox(height: 28),
                // ── Materials ──────────────────────────────────────────
                _SectionHeader(
                  title: 'Materials',
                  onAdd: () => _showMaterialSheet(ctx, null),
                ),
                const SizedBox(height: 10),
                if (jobState.isLoading)
                  const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                else if (jobState.materials.isEmpty)
                  _EmptySection(label: 'No materials added yet')
                else
                  ...jobState.materials.map((m) => _MaterialCard(
                        material: m,
                        onEdit: () => _showMaterialSheet(ctx, m),
                        onDelete: () => _confirmDelete(ctx, 'material', () => ctx.read<JobDetailsCubit>().deleteMaterial(m.id)),
                      )),
                const SizedBox(height: 24),
                // ── Teams ──────────────────────────────────────────────
                _SectionHeader(
                  title: 'Teams',
                  onAdd: () => _showTeamSheet(ctx, null),
                ),
                const SizedBox(height: 10),
                if (jobState.teams.isEmpty)
                  _EmptySection(label: 'No teams assigned yet')
                else
                  ...jobState.teams.map((t) => _TeamCard(
                        team: t,
                        onEdit: () => _showTeamSheet(ctx, t),
                        onDelete: () => _confirmDelete(ctx, 'team', () => ctx.read<JobDetailsCubit>().deleteTeam(t.id)),
                      )),
                const SizedBox(height: 24),
                // ── Linked Customer ────────────────────────────────────
                _SectionHeader(
                  title: 'Customer Contact',
                  onAdd: jobState.linkedCustomer == null
                      ? () => _showLinkCustomerSheet(ctx)
                      : null,
                ),
                const SizedBox(height: 10),
                if (jobState.linkedCustomer != null)
                  _ContactCard(
                    name: jobState.linkedCustomer!.name,
                    subtitle: jobState.linkedCustomer!.address,
                    phone: jobState.linkedCustomer!.mobile,
                    altPhone: jobState.linkedCustomer!.altNumber,
                    email: jobState.linkedCustomer!.email,
                    notes: jobState.linkedCustomer!.notes,
                    onUnlink: () => ctx.read<JobDetailsCubit>().linkCustomer(null),
                  )
                else
                  _EmptySection(label: 'No customer linked'),
                const SizedBox(height: 24),
                // ── Linked Supplier ────────────────────────────────────
                _SectionHeader(
                  title: 'Supplier',
                  onAdd: jobState.linkedSupplier == null
                      ? () => _showLinkSupplierSheet(ctx)
                      : null,
                ),
                const SizedBox(height: 10),
                if (jobState.linkedSupplier != null)
                  _ContactCard(
                    name: jobState.linkedSupplier!.name,
                    subtitle: jobState.linkedSupplier!.location,
                    phone: jobState.linkedSupplier!.primaryPhone,
                    email: jobState.linkedSupplier!.email,
                    notes: jobState.linkedSupplier!.notes,
                    onUnlink: () => ctx.read<JobDetailsCubit>().linkSupplier(null),
                  )
                else
                  _EmptySection(label: 'No supplier linked'),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sheets ─────────────────────────────────────────────────────────────────

  void _showMaterialSheet(BuildContext ctx, JobMaterial? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MaterialSheet(
        existing: existing,
        onSave: (m) {
          if (existing == null) {
            ctx.read<JobDetailsCubit>().addMaterial(m);
          } else {
            ctx.read<JobDetailsCubit>().updateMaterial(m);
          }
        },
      ),
    );
  }

  void _showTeamSheet(BuildContext ctx, JobTeam? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TeamSheet(
        existing: existing,
        onSave: (t) {
          if (existing == null) {
            ctx.read<JobDetailsCubit>().addTeam(t);
          } else {
            ctx.read<JobDetailsCubit>().updateTeam(t);
          }
        },
      ),
    );
  }

  void _showLinkCustomerSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<CustomersCubit>(),
        child: _LinkPickerSheet<Customer>(
          title: 'Link Customer',
          items: ctx.read<CustomersCubit>().state.customers,
          labelFor: (c) => c.name,
          sublabelFor: (c) => c.mobile,
          onSelect: (c) => ctx.read<JobDetailsCubit>().linkCustomer(c.id),
        ),
      ),
    );
  }

  void _showLinkSupplierSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<SuppliersCubit>(),
        child: _LinkPickerSheet<Supplier>(
          title: 'Link Supplier',
          items: ctx.read<SuppliersCubit>().state.suppliers,
          labelFor: (s) => s.name,
          sublabelFor: (s) => s.materials,
          onSelect: (s) => ctx.read<JobDetailsCubit>().linkSupplier(s.id),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, String label, VoidCallback onConfirm) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Delete $label?'),
        content: Text('This $label will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) onConfirm();
  }

  // ── Detail widgets ─────────────────────────────────────────────────────────

  Widget _buildDetailsGrid(Order order) {
    final details = [
      ['Customer', order.customer],
      ['Work Type', order.workType.label],
      ['Qty', '${order.qty} pcs'],
      ['Material', order.material],
      ['Spec', order.spec.isEmpty ? '—' : order.spec],
      ['Due', order.due],
      ['Ordered', order.ordered],
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: details.asMap().entries.map((e) {
          final isLast = e.key == details.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(e.value[0], style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                    Expanded(
                      child: Text(e.value[1],
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductionStages(JobDetailsState jobState) {
    if (jobState.isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent));
    }
    final steps = jobState.workflowSteps;
    if (steps.isEmpty) {
      return _EmptySection(label: 'No production stages defined');
    }
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == steps.length - 1;
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(step.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Container(width: 2, height: 8, color: AppColors.borderLight),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}

// ── Reusable section widgets ──────────────────────────────────────────────────

class _WorkTypeBadge extends StatelessWidget {
  final WorkType workType;
  const _WorkTypeBadge({required this.workType});

  @override
  Widget build(BuildContext context) {
    final isInHouse = workType == WorkType.inHouse;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isInHouse ? AppColors.accentSoft : AppColors.tagBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isInHouse ? Icons.factory_outlined : Icons.local_shipping_outlined,
              size: 12, color: isInHouse ? AppColors.accent : AppColors.tagText),
          const SizedBox(width: 5),
          Text(workType.label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: isInHouse ? AppColors.accent : AppColors.tagText)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  const _SectionHeader({required this.title, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const Spacer(),
        if (onAdd != null)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final String label;
  const _EmptySection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
    );
  }
}

// ── Material card ─────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  final JobMaterial material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _MaterialCard({required this.material, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.tagBg, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: const Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (material.type.isNotEmpty || material.quality.isNotEmpty)
                  Text(
                    [if (material.type.isNotEmpty) material.type, if (material.quality.isNotEmpty) material.quality].join(' · '),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          _ActionMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// ── Team card ─────────────────────────────────────────────────────────────────

class _TeamCard extends StatelessWidget {
  final JobTeam team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _TeamCard({required this.team, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            child: const Icon(Icons.group_outlined, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.teamName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (team.leader.isNotEmpty)
                  Text('Leader: ${team.leader}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('${team.membersCount} member${team.membersCount != 1 ? 's' : ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (team.contact.isNotEmpty) ...[
            CallButton(number: team.contact),
            const SizedBox(width: 6),
          ],
          _ActionMenu(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// ── Contact card (customer / supplier) ───────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String phone;
  final String? altPhone;
  final String email;
  final String notes;
  final VoidCallback onUnlink;

  const _ContactCard({
    required this.name,
    required this.subtitle,
    required this.phone,
    this.altPhone,
    required this.email,
    required this.notes,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onUnlink,
                child: const Icon(Icons.link_off, size: 18, color: AppColors.textMuted),
              ),
            ],
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 8),
            _PhoneRow(label: 'Mobile', number: phone),
          ],
          if (altPhone != null && altPhone!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _PhoneRow(label: 'Alt', number: altPhone!),
          ],
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(child: Text(email, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              ],
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(notes, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  final String label;
  final String number;
  const _PhoneRow({required this.label, required this.number});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Expanded(child: Text(number, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
        CallButton(number: number, size: 30),
      ],
    );
  }
}

class _ActionMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ActionMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
      onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
      ],
    );
  }
}

// ── Bottom sheets ─────────────────────────────────────────────────────────────

class _MaterialSheet extends StatefulWidget {
  final JobMaterial? existing;
  final ValueChanged<JobMaterial> onSave;
  const _MaterialSheet({this.existing, required this.onSave});

  @override
  State<_MaterialSheet> createState() => _MaterialSheetState();
}

class _MaterialSheetState extends State<_MaterialSheet> {
  late final TextEditingController _name;
  late final TextEditingController _type;
  late final TextEditingController _quality;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _type = TextEditingController(text: widget.existing?.type ?? '');
    _quality = TextEditingController(text: widget.existing?.quality ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _quality.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Material name is required');
      return;
    }
    final m = JobMaterial(
      id: widget.existing?.id ?? 0,
      orderId: widget.existing?.orderId ?? 0,
      name: _name.text.trim(),
      type: _type.text.trim(),
      quality: _quality.text.trim(),
    );
    widget.onSave(m);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: widget.existing == null ? 'Add Material' : 'Edit Material',
      onSave: _save,
      child: Column(
        children: [
          _SheetField(controller: _name, label: 'Material Name *', hint: 'e.g. MS Flat Bar'),
          const SizedBox(height: 12),
          _SheetField(controller: _type, label: 'Material Type', hint: 'e.g. Mild Steel'),
          const SizedBox(height: 12),
          _SheetField(controller: _quality, label: 'Material Quality', hint: 'e.g. IS 2062 Grade A'),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _TeamSheet extends StatefulWidget {
  final JobTeam? existing;
  final ValueChanged<JobTeam> onSave;
  const _TeamSheet({this.existing, required this.onSave});

  @override
  State<_TeamSheet> createState() => _TeamSheetState();
}

class _TeamSheetState extends State<_TeamSheet> {
  late final TextEditingController _name;
  late final TextEditingController _leader;
  late final TextEditingController _contact;
  late final TextEditingController _members;
  late final TextEditingController _notes;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.teamName ?? '');
    _leader = TextEditingController(text: widget.existing?.leader ?? '');
    _contact = TextEditingController(text: widget.existing?.contact ?? '');
    _members = TextEditingController(text: '${widget.existing?.membersCount ?? 1}');
    _notes = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _leader.dispose(); _contact.dispose(); _members.dispose(); _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Team name is required');
      return;
    }
    final count = int.tryParse(_members.text.trim()) ?? 1;
    final t = JobTeam(
      id: widget.existing?.id ?? 0,
      orderId: widget.existing?.orderId ?? 0,
      teamName: _name.text.trim(),
      leader: _leader.text.trim(),
      contact: _contact.text.trim(),
      membersCount: count < 1 ? 1 : count,
      notes: _notes.text.trim(),
    );
    widget.onSave(t);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: widget.existing == null ? 'Add Team' : 'Edit Team',
      onSave: _save,
      child: Column(
        children: [
          _SheetField(controller: _name, label: 'Team Name *', hint: 'e.g. Welding Team A'),
          const SizedBox(height: 12),
          _SheetField(controller: _leader, label: 'Team Leader', hint: 'e.g. Ramesh Patel'),
          const SizedBox(height: 12),
          _SheetField(controller: _contact, label: 'Contact Number', hint: '+91 98765 43210', keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _SheetField(controller: _members, label: 'No. of Members', hint: '4', keyboardType: TextInputType.number),
          const SizedBox(height: 12),
          _SheetField(controller: _notes, label: 'Notes', hint: 'Optional notes', maxLines: 3),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _LinkPickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelFor;
  final String Function(T) sublabelFor;
  final ValueChanged<T> onSelect;

  const _LinkPickerSheet({
    required this.title,
    required this.items,
    required this.labelFor,
    required this.sublabelFor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No items found', style: TextStyle(color: AppColors.textMuted))),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (_, i) {
                  final item = items[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(labelFor(item), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: sublabelFor(item).isNotEmpty
                        ? Text(sublabelFor(item), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
                        : null,
                    onTap: () {
                      onSelect(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Shared sheet chrome ───────────────────────────────────────────────────────

class _SheetScaffold extends StatelessWidget {
  final String title;
  final VoidCallback onSave;
  final Widget child;

  const _SheetScaffold({required this.title, required this.onSave, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 4),
                ElevatedButton(onPressed: onSave, child: const Text('Save')),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
