import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/suppliers/suppliers_cubit.dart';
import '../../cubits/suppliers/suppliers_state.dart';
import '../../models/supplier.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/call_button.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuppliersCubit, SuppliersState>(
      builder: (ctx, state) {
        final suppliers = state.filtered;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: ScreenAppBar(
            title: 'Suppliers',
            action: GestureDetector(
              onTap: () => _showSupplierSheet(ctx, null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColorScheme.accent, borderRadius: BorderRadius.circular(999)),
                child: const Text('+ New', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: SearchBarField(
                  hint: 'Search suppliers…',
                  onChanged: (q) => ctx.read<SuppliersCubit>().setSearch(q),
                  value: state.searchQuery,
                ),
              ),
              if (state.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColorScheme.accent)))
              else if (suppliers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.store_outlined, size: 48, color: context.colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty ? 'No suppliers yet' : 'No results found',
                          style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Tap + New to add your first supplier',
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
                    itemCount: suppliers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _SupplierCard(
                      supplier: suppliers[i],
                      onEdit: () => _showSupplierSheet(ctx, suppliers[i]),
                      onDelete: () => _confirmDelete(ctx, suppliers[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showSupplierSheet(BuildContext ctx, Supplier? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<SuppliersCubit>(),
        child: _SupplierSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, Supplier supplier) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text('Remove "${supplier.name}" from your suppliers?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete', style: TextStyle(color: AppColorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<SuppliersCubit>().delete(supplier.id);
    }
  }
}

class _SupplierCard extends StatelessWidget {
  final Supplier supplier;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SupplierCard({required this.supplier, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: context.colors.accentSoft, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: const Icon(Icons.store_outlined, size: 20, color: AppColorScheme.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(supplier.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                    if (supplier.materials.isNotEmpty)
                      Text(supplier.materials,
                          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (supplier.location.isNotEmpty)
                      Text(supplier.location,
                          style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 18, color: context.colors.textMuted),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColorScheme.error))),
                ],
              ),
            ],
          ),
          if (supplier.contactPerson.isNotEmpty ||
              supplier.primaryPhone.isNotEmpty ||
              supplier.email.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(height: 1, color: context.colors.divider),
            const SizedBox(height: 10),
            if (supplier.contactPerson.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 14, color: context.colors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(supplier.contactPerson,
                          style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                    ),
                  ],
                ),
              ),
            if (supplier.primaryPhone.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: context.colors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(supplier.primaryPhone,
                        style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                  ),
                  CallButton(number: supplier.primaryPhone, size: 32),
                ],
              ),
            if (supplier.email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.email_outlined, size: 14, color: context.colors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(supplier.email,
                        style: TextStyle(fontSize: 13, color: context.colors.textSecondary)),
                  ),
                ],
              ),
            ],
            if (supplier.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(supplier.notes,
                  style: TextStyle(fontSize: 12, color: context.colors.textMuted, fontStyle: FontStyle.italic)),
            ],
          ],
        ],
      ),
    );
  }
}

class _SupplierSheet extends StatefulWidget {
  final Supplier? existing;
  const _SupplierSheet({this.existing});

  @override
  State<_SupplierSheet> createState() => _SupplierSheetState();
}

class _SupplierSheetState extends State<_SupplierSheet> {
  late final TextEditingController _name;
  late final TextEditingController _materials;
  late final TextEditingController _contactPerson;
  late final TextEditingController _mobile;
  late final TextEditingController _email;
  late final TextEditingController _location;
  late final TextEditingController _address;
  late final TextEditingController _notes;
  Map<String, String> _fieldErrors = {};
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _name = TextEditingController(text: s?.name ?? '');
    _materials = TextEditingController(text: s?.materials ?? '');
    _contactPerson = TextEditingController(text: s?.contactPerson ?? '');
    _mobile = TextEditingController(text: s?.mobile ?? '');
    _email = TextEditingController(text: s?.email ?? '');
    _location = TextEditingController(text: s?.location ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _notes = TextEditingController(text: s?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _materials.dispose(); _contactPerson.dispose();
    _mobile.dispose(); _email.dispose(); _location.dispose();
    _address.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = <String, String>{};

    final nameErr = AppValidators.required(_name.text, 'Supplier name');
    if (nameErr != null) errors['name'] = nameErr;

    final mobileErr = AppValidators.phone(_mobile.text);
    if (mobileErr != null) errors['mobile'] = mobileErr;

    final emailErr = AppValidators.optionalEmail(_email.text);
    if (emailErr != null) errors['email'] = emailErr;

    if (errors.isNotEmpty) {
      setState(() { _fieldErrors = errors; _saveError = null; });
      return;
    }

    setState(() { _saving = true; _fieldErrors = {}; _saveError = null; });

    final cubit = context.read<SuppliersCubit>();
    bool success;

    if (widget.existing == null) {
      final created = await cubit.create(Supplier(
        id: 0,
        name: _name.text.trim(),
        materials: _materials.text.trim(),
        contactPerson: _contactPerson.text.trim(),
        mobile: _mobile.text.trim(),
        email: _email.text.trim(),
        location: _location.text.trim(),
        address: _address.text.trim(),
        notes: _notes.text.trim(),
      ));
      success = created != null;
    } else {
      success = await cubit.update(widget.existing!.copyWith(
        name: _name.text.trim(),
        materials: _materials.text.trim(),
        contactPerson: _contactPerson.text.trim(),
        mobile: _mobile.text.trim(),
        email: _email.text.trim(),
        location: _location.text.trim(),
        address: _address.text.trim(),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.existing == null ? 'New Supplier' : 'Edit Supplier',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                  const Spacer(),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _field(_name, 'Supplier Name *', 'e.g. Gujarat Steel Traders', fieldKey: 'name'),
              const SizedBox(height: 12),
              _field(_materials, 'Materials Supplied', 'e.g. MS Flat, Angle, Channel'),
              const SizedBox(height: 12),
              _field(_contactPerson, 'Contact Person', 'e.g. Rakesh Mehta'),
              const SizedBox(height: 12),
              _field(_mobile, 'Mobile Number', '+91 98765 43210', fieldKey: 'mobile', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_email, 'Email', 'supplier@example.com', fieldKey: 'email', type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_location, 'Location', 'e.g. Surat, Gujarat'),
              const SizedBox(height: 12),
              _field(_address, 'Full Address', 'e.g. Plot 42, GIDC Estate', maxLines: 2),
              const SizedBox(height: 12),
              _field(_notes, 'Notes', 'Optional notes', maxLines: 3),
              if (_saveError != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: context.colors.errorSoft, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
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
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
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
