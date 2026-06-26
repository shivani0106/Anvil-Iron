import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../cubits/inventory/inventory_cubit.dart';
import '../../models/order.dart';
import '../../widgets/common/screen_app_bar.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersCubit, OrdersState>(
      builder: (ctx, state) {
        final nav = ctx.read<NavigationCubit>();
        final ordersCubit = ctx.read<OrdersCubit>();
        final materials = ctx.read<InventoryCubit>().state.items.map((m) => m.name).toList();

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: const ScreenAppBar(title: 'New Job Order'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  context: context,
                  label: 'Customer',
                  hint: 'e.g. Patel Engineering',
                  value: state.formCustomer,
                  onChanged: (v) => ordersCubit.updateForm(customer: v),
                ),
                const SizedBox(height: 14),
                _buildField(
                  context: context,
                  label: 'Item',
                  hint: 'e.g. MS Angle Bracket',
                  value: state.formItem,
                  onChanged: (v) => ordersCubit.updateForm(item: v),
                ),
                const SizedBox(height: 14),
                _buildField(
                  context: context,
                  label: 'Quantity',
                  hint: 'e.g. 100',
                  value: state.formQty,
                  onChanged: (v) => ordersCubit.updateForm(qty: v),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  context: context,
                  label: 'Material',
                  hint: 'Select material',
                  value: state.formMaterial.isEmpty ? null : state.formMaterial,
                  options: materials,
                  onChanged: (v) => ordersCubit.updateForm(material: v ?? ''),
                ),
                const SizedBox(height: 14),
                _buildDatePickerField(
                  context: ctx,
                  value: state.formDue,
                  ordersCubit: ordersCubit,
                ),
                const SizedBox(height: 14),
                _buildWorkTypeField(
                  context: context,
                  value: state.formWorkType,
                  onChanged: (v) => ordersCubit.updateForm(workType: v),
                ),
                const SizedBox(height: 14),
                _FormWorkflowSection(
                  steps: state.formWorkflowSteps,
                  onAdd: (name) => ordersCubit.addFormWorkflowStep(name),
                  onRemove: (i) => ordersCubit.removeFormWorkflowStep(i),
                  onMoveUp: (i) => ordersCubit.moveFormWorkflowStepUp(i),
                  onMoveDown: (i) => ordersCubit.moveFormWorkflowStepDown(i),
                ),
                if (state.formError.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.errorSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppColorScheme.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.formError,
                            style: const TextStyle(color: AppColorScheme.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newId = await ordersCubit.submitOrder();
                      if (newId != null) {
                        nav.replaceStack([
                          const ScreenEntry(screen: AppScreen.hub),
                          const ScreenEntry(screen: AppScreen.orders),
                        ]);
                        nav.showToast('Job #$newId created');
                      }
                    },
                    child: const Text('Create Order'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField({
    required BuildContext context,
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
          style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String value,
    required OrdersCubit ordersCubit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due date',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textSecondary),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 5),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColorScheme.accent,
                      brightness: Theme.of(context).brightness,
                    ).copyWith(
                      primary: AppColorScheme.accent,
                      onPrimary: Colors.white,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColorScheme.accent,
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              ordersCubit.updateForm(due: DateFormat('d MMM').format(picked));
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Select due date' : value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value.isEmpty ? context.colors.textMuted : context.colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, size: 16, color: context.colors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: context.colors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: TextStyle(color: context.colors.textMuted, fontSize: 14)),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTypeField({
    required BuildContext context,
    required WorkType value,
    required ValueChanged<WorkType> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Work Type *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
        const SizedBox(height: 6),
        Row(
          children: WorkType.values.map((wt) {
            final selected = value == wt;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(wt),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: wt == WorkType.inHouse ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? AppColorScheme.accent : context.colors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: selected ? AppColorScheme.accent : context.colors.border,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        wt == WorkType.inHouse ? Icons.factory_outlined : Icons.local_shipping_outlined,
                        size: 16,
                        color: selected ? Colors.white : context.colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        wt.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Production Workflow (form) ────────────────────────────────────────────────

class _FormWorkflowSection extends StatefulWidget {
  final List<String> steps;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onMoveUp;
  final ValueChanged<int> onMoveDown;

  const _FormWorkflowSection({
    required this.steps,
    required this.onAdd,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });

  @override
  State<_FormWorkflowSection> createState() => _FormWorkflowSectionState();
}

class _FormWorkflowSectionState extends State<_FormWorkflowSection> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Production workflow',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textSecondary),
            ),
            const Spacer(),
            if (steps.isNotEmpty)
              Text('▲▼ to reorder', style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
          ],
        ),
        const SizedBox(height: 8),
        ...steps.asMap().entries.map((e) {
          final i = e.key;
          final name = e.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColorScheme.accent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(name, style: TextStyle(fontSize: 14, color: context.colors.textPrimary)),
                ),
                _ReorderBtn(
                  icon: Icons.arrow_drop_up,
                  enabled: i > 0,
                  onTap: () => widget.onMoveUp(i),
                ),
                _ReorderBtn(
                  icon: Icons.arrow_drop_down,
                  enabled: i < steps.length - 1,
                  onTap: () => widget.onMoveDown(i),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => widget.onRemove(i),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColorScheme.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close, size: 14, color: AppColorScheme.error),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(hintText: 'Add a step...'),
                style: TextStyle(fontSize: 14, color: context.colors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _add,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.accentSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Text(
                  '+ Add',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColorScheme.accent),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReorderBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ReorderBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: enabled ? context.colors.tagBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 20, color: enabled ? context.colors.textSecondary : context.colors.borderLight),
      ),
    );
  }
}
