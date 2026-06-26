import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validators.dart';
import '../../cubits/customers/customers_cubit.dart';
import '../../cubits/customers/customers_state.dart';
import '../../models/customer.dart';
import '../../widgets/common/screen_app_bar.dart';
import '../../widgets/common/search_bar_field.dart';
import '../../widgets/common/info_card.dart';
import '../../widgets/common/call_button.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersCubit, CustomersState>(
      builder: (ctx, state) {
        final customers = state.filtered;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: ScreenAppBar(
            title: 'Customers',
            action: GestureDetector(
              onTap: () => _showCustomerSheet(ctx, null),
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
                  hint: 'Search customers…',
                  onChanged: (q) => ctx.read<CustomersCubit>().setSearch(q),
                  value: state.searchQuery,
                ),
              ),
              if (state.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColorScheme.accent)))
              else if (customers.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 48, color: context.colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          state.searchQuery.isEmpty ? 'No customers yet' : 'No results found',
                          style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
                        ),
                        if (state.searchQuery.isEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Tap + New to add your first customer',
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
                    itemCount: customers.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _CustomerCard(
                      customer: customers[i],
                      onEdit: () => _showCustomerSheet(ctx, customers[i]),
                      onDelete: () => _confirmDelete(ctx, customers[i]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomerSheet(BuildContext ctx, Customer? existing) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: ctx.read<CustomersCubit>(),
        child: _CustomerSheet(existing: existing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete customer?'),
        content: Text('Remove "${customer.name}" from your contacts?'),
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
      await ctx.read<CustomersCubit>().delete(customer.id);
    }
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CustomerCard({required this.customer, required this.onEdit, required this.onDelete});

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
                decoration: BoxDecoration(color: context.colors.accentSoft, shape: BoxShape.circle),
                child: Center(
                  child: Text(customer.initials,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColorScheme.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                    if (customer.address.isNotEmpty)
                      Text(customer.address,
                          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
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
          const SizedBox(height: 10),
          Divider(height: 1, color: context.colors.divider),
          const SizedBox(height: 10),
          _ContactRow(icon: Icons.phone_outlined, label: customer.mobile, phone: customer.mobile),
          if (customer.altNumber.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ContactRow(icon: Icons.phone_outlined, label: 'Alt: ${customer.altNumber}', phone: customer.altNumber),
          ],
          if (customer.email.isNotEmpty) ...[
            const SizedBox(height: 6),
            _ContactRow(icon: Icons.email_outlined, label: customer.email),
          ],
          if (customer.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(customer.notes,
                style: TextStyle(fontSize: 12, color: context.colors.textMuted, fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? phone;

  const _ContactRow({required this.icon, required this.label, this.phone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.colors.textMuted),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: context.colors.textSecondary))),
        if (phone != null && phone!.isNotEmpty) CallButton(number: phone!, size: 32),
      ],
    );
  }
}

class _CustomerSheet extends StatefulWidget {
  final Customer? existing;
  const _CustomerSheet({this.existing});

  @override
  State<_CustomerSheet> createState() => _CustomerSheetState();
}

class _CustomerSheetState extends State<_CustomerSheet> {
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _altNumber;
  late final TextEditingController _email;
  late final TextEditingController _address;
  late final TextEditingController _notes;
  Map<String, String> _fieldErrors = {};
  String? _saveError;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _mobile = TextEditingController(text: c?.mobile ?? '');
    _altNumber = TextEditingController(text: c?.altNumber ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _notes = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _name.dispose(); _mobile.dispose(); _altNumber.dispose();
    _email.dispose(); _address.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final errors = <String, String>{};

    final nameErr = AppValidators.required(_name.text, 'Customer name');
    if (nameErr != null) errors['name'] = nameErr;

    final mobileErr = AppValidators.required(_mobile.text, 'Mobile number')
        ?? AppValidators.phone(_mobile.text);
    if (mobileErr != null) errors['mobile'] = mobileErr;

    final altErr = AppValidators.phone(_altNumber.text);
    if (altErr != null) errors['altNumber'] = altErr;

    final emailErr = AppValidators.optionalEmail(_email.text);
    if (emailErr != null) errors['email'] = emailErr;

    if (errors.isNotEmpty) {
      setState(() { _fieldErrors = errors; _saveError = null; });
      return;
    }

    setState(() { _saving = true; _fieldErrors = {}; _saveError = null; });

    final cubit = context.read<CustomersCubit>();
    bool success;

    if (widget.existing == null) {
      final created = await cubit.create(Customer(
        id: 0,
        name: _name.text.trim(),
        mobile: _mobile.text.trim(),
        altNumber: _altNumber.text.trim(),
        email: _email.text.trim(),
        address: _address.text.trim(),
        notes: _notes.text.trim(),
      ));
      success = created != null;
    } else {
      success = await cubit.update(widget.existing!.copyWith(
        name: _name.text.trim(),
        mobile: _mobile.text.trim(),
        altNumber: _altNumber.text.trim(),
        email: _email.text.trim(),
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
                  Text(widget.existing == null ? 'New Customer' : 'Edit Customer',
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
              _field(_name, 'Customer Name *', 'e.g. Patel Engineering', fieldKey: 'name'),
              const SizedBox(height: 12),
              _field(_mobile, 'Mobile Number *', '+91 98765 43210', fieldKey: 'mobile', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_altNumber, 'Alternate Number', '+91 98765 00000', fieldKey: 'altNumber', type: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_email, 'Email', 'customer@example.com', fieldKey: 'email', type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_address, 'Address', 'e.g. 12 Industrial Estate, Surat', maxLines: 2),
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
