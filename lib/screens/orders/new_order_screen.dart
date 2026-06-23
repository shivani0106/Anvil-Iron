import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../cubits/navigation/navigation_cubit.dart';
import '../../cubits/navigation/navigation_state.dart';
import '../../cubits/orders/orders_cubit.dart';
import '../../cubits/orders/orders_state.dart';
import '../../cubits/inventory/inventory_cubit.dart';
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
          backgroundColor: AppColors.background,
          appBar: const ScreenAppBar(title: 'New Job Order'),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  label: 'Customer',
                  hint: 'e.g. Patel Engineering',
                  value: state.formCustomer,
                  onChanged: (v) => ordersCubit.updateForm(customer: v),
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Item',
                  hint: 'e.g. MS Angle Bracket',
                  value: state.formItem,
                  onChanged: (v) => ordersCubit.updateForm(item: v),
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Quantity',
                  hint: 'e.g. 100',
                  value: state.formQty,
                  onChanged: (v) => ordersCubit.updateForm(qty: v),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _buildDropdownField(
                  label: 'Material',
                  hint: 'Select material',
                  value: state.formMaterial.isEmpty ? null : state.formMaterial,
                  options: materials,
                  onChanged: (v) => ordersCubit.updateForm(material: v ?? ''),
                ),
                const SizedBox(height: 14),
                _buildField(
                  label: 'Due date',
                  hint: 'e.g. 30 Jun',
                  value: state.formDue,
                  onChanged: (v) => ordersCubit.updateForm(due: v),
                ),
                if (state.formError.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: AppColors.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.formError,
                            style: const TextStyle(color: AppColors.error, fontSize: 13),
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
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14))))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
