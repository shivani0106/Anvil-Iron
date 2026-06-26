import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/materials/materials_cubit.dart';
import '../../cubits/materials/materials_state.dart';
import '../../models/app_material.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MaterialsCubit, MaterialsState>(
      builder: (ctx, state) {
        final materials = state.filtered;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: ScreenAppBar(
            title: 'Materials',
            action: GestureDetector(
              onTap: () => _showMaterialSheet(ctx, null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                    color: AppColorScheme.accent, borderRadius: BorderRadius.circular(999)),
                child: const Text('+ New',
                    style: TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: SearchBarField(
                  hint: 'Search materials…',
                  onChanged: (q) => ctx.read<MaterialsCubit>().setSearch(q),
                  value: state.searchQuery,
                ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: context.colors.errorSoft,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                    child: Text(state.error!,
                        style: const TextStyle(color: AppColorScheme.error, fontSize: 13)),
                  ),
                ),
              if (state.isLoading)
                const Expanded(
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColorScheme.accent)))
              else if (materials.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 48, color: context.colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty
                              ? 'No materials yet'
                              : 'No results found',
                          style: TextStyle(
                              fontSize: 14, color: context.colors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Tap + New to add your first material',
                              style: TextStyle(fontSize: 12, color: context.colors.textMuted)),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    itemCount: materials.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _MaterialCard(
                      material: materials[i],
                      onEdit: () => _showMaterialSheet(ctx, materials[i]),
                      onDelete: () => _confirmDelete(ctx, materials[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMaterialSheet(BuildContext ctx, AppMaterial? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<MaterialsCubit>(),
        child: _MaterialSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, AppMaterial material) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete material?'),
        content: Text('Remove "${material.name}" from your catalog?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<MaterialsCubit>().delete(material.id);
    }
  }
}

class _MaterialCard extends StatelessWidget {
  final AppMaterial material;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MaterialCard(
      {required this.material, required this.onEdit, required this.onDelete});

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
                    color: context.colors.accentSoft, shape: BoxShape.circle),
                child: const Center(
                  child: Icon(Icons.inventory_2_outlined,
                      size: 20, color: AppColorScheme.accent),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.name,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textPrimary)),
                    if (material.type.isNotEmpty)
                      Text(material.type,
                          style: TextStyle(
                              fontSize: 12, color: context.colors.textSecondary)),
                  ],
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
                      child: Text('Delete',
                          style: TextStyle(color: AppColorScheme.error))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: context.colors.divider),
          const SizedBox(height: 10),
          Row(
            children: [
              _Chip(label: material.displayQty, icon: Icons.scale_outlined),
              const SizedBox(width: 8),
              if (material.quality.isNotEmpty)
                _Chip(label: material.quality, icon: Icons.verified_outlined),
              const Spacer(),
              Text(material.costLabel,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColorScheme.accent)),
            ],
          ),
          if (material.supplierName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.storefront_outlined,
                    size: 14, color: context.colors.textMuted),
                const SizedBox(width: 5),
                Text(material.supplierName,
                    style: TextStyle(
                        fontSize: 12, color: context.colors.textSecondary)),
              ],
            ),
          ],
          if (material.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(material.notes,
                style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textMuted,
                    fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: context.colors.tagBg,
          borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.colors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: context.colors.textSecondary)),
        ],
      ),
    );
  }
}

class _MaterialSheet extends StatefulWidget {
  final AppMaterial? existing;
  const _MaterialSheet({this.existing});

  @override
  State<_MaterialSheet> createState() => _MaterialSheetState();
}

class _MaterialSheetState extends State<_MaterialSheet> {
  late final TextEditingController _name;
  late final TextEditingController _type;
  late final TextEditingController _quality;
  late final TextEditingController _quantity;
  late final TextEditingController _unit;
  late final TextEditingController _supplierName;
  late final TextEditingController _cost;
  late final TextEditingController _notes;
  Map<String, String> _fieldErrors = {};
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _name = TextEditingController(text: m?.name ?? '');
    _type = TextEditingController(text: m?.type ?? '');
    _quality = TextEditingController(text: m?.quality ?? '');
    _quantity = TextEditingController(
        text: m != null ? m.quantity.toString() : '');
    _unit = TextEditingController(text: m?.unit ?? '');
    _supplierName = TextEditingController(text: m?.supplierName ?? '');
    _cost = TextEditingController(
        text: m?.cost != null ? m!.cost.toString() : '');
    _notes = TextEditingController(text: m?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    _quality.dispose();
    _quantity.dispose();
    _unit.dispose();
    _supplierName.dispose();
    _cost.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = <String, String>{};

    final nameErr = AppValidators.required(_name.text, 'Material name');
    if (nameErr != null) errors['name'] = nameErr;

    final qtyErr = AppValidators.number(_quantity.text);
    if (qtyErr != null) errors['quantity'] = qtyErr;

    final costErr = AppValidators.number(_cost.text);
    if (costErr != null) errors['cost'] = costErr;

    if (errors.isNotEmpty) {
      setState(() { _fieldErrors = errors; _saveError = null; });
      return;
    }

    final qty = double.tryParse(_quantity.text.trim()) ?? 0;
    final cost = _cost.text.trim().isEmpty ? null : double.tryParse(_cost.text.trim());

    setState(() { _saving = true; _fieldErrors = {}; _saveError = null; });

    final cubit = context.read<MaterialsCubit>();
    bool success;

    if (widget.existing == null) {
      success = await cubit.create(AppMaterial(
        id: 0,
        name: _name.text.trim(),
        type: _type.text.trim(),
        quality: _quality.text.trim(),
        quantity: qty,
        unit: _unit.text.trim(),
        supplierName: _supplierName.text.trim(),
        cost: cost,
        notes: _notes.text.trim(),
      ));
    } else {
      success = await cubit.update(widget.existing!.copyWith(
        name: _name.text.trim(),
        type: _type.text.trim(),
        quality: _quality.text.trim(),
        quantity: qty,
        unit: _unit.text.trim(),
        supplierName: _supplierName.text.trim(),
        cost: cost,
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
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
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
                      widget.existing == null ? 'New Material' : 'Edit Material',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary)),
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
              _field(_name, 'Material Name *', 'e.g. Mild Steel Rod', fieldKey: 'name'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _field(_type, 'Type', 'e.g. Metal, Polymer')),
                const SizedBox(width: 12),
                Expanded(child: _field(_quality, 'Quality', 'e.g. Grade A')),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _field(_quantity, 'Quantity', '0',
                        fieldKey: 'quantity', type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _field(_unit, 'Unit', 'kg, pcs, m')),
              ]),
              const SizedBox(height: 12),
              _field(_supplierName, 'Supplier Name', 'e.g. ABC Metals'),
              const SizedBox(height: 12),
              _field(_cost, 'Cost per Unit (₹)', '0.00',
                  fieldKey: 'cost', type: TextInputType.number),
              const SizedBox(height: 12),
              _field(_notes, 'Notes', 'Optional notes', maxLines: 3),
              if (_saveError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: context.colors.errorSoft,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
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
                color: context.colors.textSecondary)),
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
