import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
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
          backgroundColor: AppColors.background,
          appBar: ScreenAppBar(
            title: 'Suppliers',
            action: GestureDetector(
              onTap: () => _showSupplierSheet(ctx, null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(999)),
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
                const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)))
              else if (suppliers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty ? 'No suppliers yet' : 'No results found',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          const Text('Tap + New to add your first supplier',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
      builder: (_) => AlertDialog(
        title: const Text('Delete supplier?'),
        content: Text('Remove "${supplier.name}" from your suppliers?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<SuppliersCubit>().delete(supplier.id);
    }
  }
}

// ── Supplier Card ─────────────────────────────────────────────────────────────

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
                    color: AppColors.accentSoft, borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                child: const Icon(Icons.store_outlined, size: 20, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(supplier.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    if (supplier.materials.isNotEmpty)
                      Text(supplier.materials,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (supplier.location.isNotEmpty)
                      Text(supplier.location,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.error))),
                ],
              ),
            ],
          ),
          if (supplier.contactPerson.isNotEmpty ||
              supplier.primaryPhone.isNotEmpty ||
              supplier.email.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            if (supplier.contactPerson.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(supplier.contactPerson,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            if (supplier.primaryPhone.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(supplier.primaryPhone,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                  CallButton(number: supplier.primaryPhone, size: 32),
                ],
              ),
            if (supplier.email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.email_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(supplier.email,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ],
            if (supplier.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(supplier.notes,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontStyle: FontStyle.italic)),
            ],
          ],
        ],
      ),
    );
  }
}

// ── Supplier Form Sheet ───────────────────────────────────────────────────────

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
  String? _error;
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
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Supplier name is required');
      return;
    }

    setState(() { _saving = true; _error = null; });

    final cubit = context.read<SuppliersCubit>();
    bool success;

    if (widget.existing == null) {
      // Use max id + 1 for integer PK suppliers table
      final maxId = cubit.state.suppliers.isEmpty
          ? 1
          : cubit.state.suppliers.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
      final created = await cubit.create(Supplier(
        id: maxId,
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
      setState(() { _saving = false; _error = 'Failed to save. Please try again.'; });
    }
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(widget.existing == null ? 'New Supplier' : 'Edit Supplier',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
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
              _field(_name, 'Supplier Name *', 'e.g. Gujarat Steel Traders'),
              const SizedBox(height: 12),
              _field(_materials, 'Materials Supplied', 'e.g. MS Flat, Angle, Channel'),
              const SizedBox(height: 12),
              _field(_contactPerson, 'Contact Person', 'e.g. Rakesh Mehta'),
              const SizedBox(height: 12),
              _field(_mobile, 'Mobile Number', '+91 98765 43210', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_email, 'Email', 'supplier@example.com', type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_location, 'Location', 'e.g. Surat, Gujarat'),
              const SizedBox(height: 12),
              _field(_address, 'Full Address', 'e.g. Plot 42, GIDC Estate', maxLines: 2),
              const SizedBox(height: 12),
              _field(_notes, 'Notes', 'Optional notes', maxLines: 3),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.errorSoft, borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
