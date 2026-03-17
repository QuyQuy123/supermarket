import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/services/customer_api_service.dart';
import 'package:supermarket_manager_system/domain/models/customer_detail.dart';
import 'package:supermarket_manager_system/domain/models/customer_list_item.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';

/// CustomerListScreen: list customers with Add, Details, Edit, View History.
class CustomersContent extends StatefulWidget {
  const CustomersContent({
    super.key,
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
    this.showHeader = true,
    this.onBack,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;
  final bool showHeader;
  final VoidCallback? onBack;

  @override
  State<CustomersContent> createState() => _CustomersContentState();
}

enum _CustomerView { list, detail, history }

class _CustomersContentState extends State<CustomersContent> {
  final _customerApiService = CustomerApiService();
  late Future<List<CustomerListItem>> _customersFuture;
  int? _selectedCustomerId;
  String _selectedCustomerPhone = '';
  _CustomerView _view = _CustomerView.list;

  @override
  void initState() {
    super.initState();
    _customersFuture = _customerApiService.getCustomers();
  }

  void _reloadCustomers() {
    setState(() {
      _customersFuture = _customerApiService.getCustomers();
    });
  }

  Future<void> _openAddCustomerDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _AddCustomerDialog(customerApiService: _customerApiService),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      _reloadCustomers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer created successfully')),
      );
    }
  }

  void _showList() {
    setState(() {
      _view = _CustomerView.list;
      _selectedCustomerId = null;
    });
    _reloadCustomers();
  }

  void _showDetail(int customerId) {
    setState(() {
      _selectedCustomerId = customerId;
      _view = _CustomerView.detail;
    });
  }

  Future<void> _openEditCustomerDialog(CustomerListItem customer) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditCustomerDialog(
        customerApiService: _customerApiService,
        customer: customer,
      ),
    );

    if (!mounted) {
      return;
    }

    if (updated == true) {
      _reloadCustomers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer updated successfully')),
      );
    }
  }

  void _showHistory(int customerId, {required String phone}) {
    setState(() {
      _selectedCustomerId = customerId;
      _selectedCustomerPhone = phone;
      _view = _CustomerView.history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          if (widget.showHeader)
            _CustomersHeader(
              fullName: widget.fullName,
              isCompact: widget.isCompact,
              currentTimeText: widget.currentTimeText,
              onProfileTap: widget.onProfileTap,
            )
          else if (widget.onBack != null)
            _SimpleBackBar(onBack: widget.onBack!),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: switch (_view) {
                _CustomerView.list => _buildListContent(),
                _CustomerView.detail => CustomerDetailContent(
                  customerId: _selectedCustomerId!,
                  customerApiService: _customerApiService,
                  onBack: _showList,
                  onEdit: () {
                    // Load latest detail for dialog
                    // Open edit dialog based on list when returning to list.
                    _showList();
                  },
                  onViewHistory: () => _showHistory(
                    _selectedCustomerId!,
                    phone: _selectedCustomerPhone,
                  ),
                ),
                _CustomerView.history => ViewCustomerHistoryScreen(
                  customerId: _selectedCustomerId!,
                  phone: _selectedCustomerPhone,
                  customerApiService: _customerApiService,
                  onBack: _showList,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer List',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1D21),
                letterSpacing: -0.02,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _openAddCustomerDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Customer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<CustomerListItem>>(
            future: _customersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cannot load customers: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _reloadCustomers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final customers = snapshot.data ?? [];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    horizontalMargin: 20,
                    columnSpacing: 24,
                    headingRowColor: const WidgetStatePropertyAll(
                      Color(0xFFF7F8FA),
                    ),
                    headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4A5568),
                      fontSize: 12,
                    ),
                    columns: const [
                      DataColumn(
                        label: SizedBox(width: 40, child: Center(child: Text('S/N'))),
                      ),
                      DataColumn(label: Text('CUSTOMER')),
                      DataColumn(label: Text('PHONE')),
                      DataColumn(label: Text('POINTS')),
                      DataColumn(label: Text('PURCHASES')),
                      DataColumn(label: Text('TOTAL AMOUNT')),
                      DataColumn(label: Text('DISCOUNT')),
                      DataColumn(label: Text('ACTIONS')),
                    ],
                    rows: customers.asMap().entries.map((entry) {
                      final i = entry.key + 1;
                      final c = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(
                            SizedBox(width: 40, child: Center(child: Text(i.toString()))),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () => _showDetail(c.id),
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  color: Color(0xFF1A1D21),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            InkWell(
                              onTap: () => _showHistory(c.id, phone: c.phone),
                              child: Text(
                                c.phone,
                                style: const TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(c.points.toString())),
                          DataCell(Text(c.totalPurchases.toString())),
                          DataCell(Text(_formatMoney(c.totalAmount))),
                          DataCell(
                            Container(
                                alignment: Alignment.centerRight,
                                child: Text('—')), // Discount placeholder
                          ),
                          DataCell(
                            Center(
                              child: _EditActionBtn(
                                onTap: () => _openEditCustomerDialog(c),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _formatMoney(double v) {
    final fmt = v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '${fmt}đ';
  }
}

class _SimpleBackBar extends StatelessWidget {
  const _SimpleBackBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            tooltip: 'Back',
          ),
          const Text(
            'Customer Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CustomersHeader extends StatelessWidget {
  const _CustomersHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isCompact)
            Builder(
              builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          else
            const SizedBox(width: 48),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentTimeText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fullName.isEmpty ? 'User' : fullName),
                  const Text(
                    'Customer Management',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EditActionBtn extends StatelessWidget {
  const _EditActionBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dialog: Add customer (popup)
class _AddCustomerDialog extends StatefulWidget {
  const _AddCustomerDialog({required this.customerApiService});

  final CustomerApiService customerApiService;

  @override
  State<_AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<_AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorText = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
      await widget.customerApiService.createCustomer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        totalAmount: amount,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Add Customer',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFieldLabel('Customer name'),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Nguyen Van A',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 2) return 'Name must be at least 2 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Phone'),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'e.g. 0901234567',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  if (!RegExp(r'^(0|84)(3|5|7|8|9)([0-9]{8})$').hasMatch(v.trim())) {
                    return 'Invalid Vietnamese phone number format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Amount'),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'e.g. 1,000,000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final cleanV = v.replaceAll(',', '');
                    final amount = double.tryParse(cleanV);
                    if (amount == null) return 'Invalid amount';
                    if (amount < 0) return 'Amount cannot be negative';
                  }
                  return null;
                },
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: Text(_isSubmitting ? 'Submitting...' : 'Submit', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

/// Dialog: Edit customer (popup)
class _EditCustomerDialog extends StatefulWidget {
  const _EditCustomerDialog({
    required this.customerApiService,
    required this.customer,
  });

  final CustomerApiService customerApiService;
  final CustomerListItem customer;

  @override
  State<_EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<_EditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _amountController;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer.name);
    _phoneController = TextEditingController(text: widget.customer.phone);
    _amountController = TextEditingController(text: widget.customer.totalAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorText = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
      await widget.customerApiService.updateCustomer(
        customerId: widget.customer.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        totalAmount: amount,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Update Customer',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFieldLabel('Customer name'),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 2) return 'Name must be at least 2 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Phone'),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  if (!RegExp(r'^(0|84)(3|5|7|8|9)([0-9]{8})$').hasMatch(v.trim())) {
                    return 'Invalid Vietnamese phone number format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFieldLabel('Amount'),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'e.g. 1,000,000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final cleanV = v.replaceAll(',', '');
                    final amount = double.tryParse(cleanV);
                    if (amount == null) return 'Invalid amount';
                    if (amount < 0) return 'Amount cannot be negative';
                  }
                  return null;
                },
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _errorText!,
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: Text(_isSubmitting ? 'Updating...' : 'Update', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

/// AddCustomerScreen: form to add a new customer.
class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({
    super.key,
    required this.customerApiService,
    required this.onSaved,
    required this.onCancel,
  });

  final CustomerApiService customerApiService;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorText = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
      await widget.customerApiService.createCustomer(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        totalAmount: amount,
      );
      if (!mounted) return;
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: const Color(0xFF667EEA),
          ),
          onPressed: widget.onCancel,
          icon: const Icon(Icons.arrow_back, size: 20),
          label: const Text(
            'Back to Customer list',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Add Customer',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Phone is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Total Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isSubmitting ? 'Saving...' : 'Save'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomerDetailContent: view one customer with Edit and View History.
class CustomerDetailContent extends StatefulWidget {
  const CustomerDetailContent({
    super.key,
    required this.customerId,
    required this.customerApiService,
    required this.onBack,
    required this.onEdit,
    required this.onViewHistory,
  });

  final int customerId;
  final CustomerApiService customerApiService;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onViewHistory;

  static String _formatMoney(double v) {
    final fmt = v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '${fmt}đ';
  }

  @override
  State<CustomerDetailContent> createState() => _CustomerDetailContentState();
}

class _CustomerDetailContentState extends State<CustomerDetailContent> {
  late Future<CustomerDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.customerApiService.getCustomerDetail(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerDetail>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cannot load customer: ${snapshot.error}'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
              ],
            ),
          );
        }
        final c = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: const Color(0xFF667EEA),
              ),
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back, size: 20),
              label: const Text(
                'Back to Customer list',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Customer Detail',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8EAED)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'ID', value: c.id.toString()),
                  _DetailRow(label: 'Name', value: c.name),
                  _DetailRow(label: 'Phone', value: c.phone),
                  _DetailRow(label: 'Points', value: c.points.toString()),
                  _DetailRow(
                    label: 'Total Purchases',
                    value: c.totalPurchases.toString(),
                  ),
                  _DetailRow(
                    label: 'Total Amount',
                    value: CustomerDetailContent._formatMoney(c.totalAmount),
                  ),
                  if (c.discountName.isNotEmpty && c.discountName != '—')
                    _DetailRow(label: 'Discount', value: c.discountName),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: widget.onEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: widget.onViewHistory,
                  child: const Text('View Order History'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// UpdateCustomerScreen: form to update customer name and phone.
class UpdateCustomerScreen extends StatefulWidget {
  const UpdateCustomerScreen({
    super.key,
    required this.customerId,
    required this.customerApiService,
    required this.onSaved,
    required this.onCancel,
  });

  final int customerId;
  final CustomerApiService customerApiService;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  State<UpdateCustomerScreen> createState() => _UpdateCustomerScreenState();
}

class _UpdateCustomerScreenState extends State<UpdateCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorText;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final c = await widget.customerApiService.getCustomerDetail(
        widget.customerId,
      );
      if (!mounted) return;
      _nameController.text = c.name;
      _phoneController.text = c.phone;
      _amountController.text = c.totalAmount.toStringAsFixed(0);
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    _errorText = null;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
      await widget.customerApiService.updateCustomer(
        customerId: widget.customerId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        totalAmount: amount,
      );
      if (!mounted) return;
      widget.onSaved();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!),
            TextButton(onPressed: widget.onCancel, child: const Text('Back')),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: const Color(0xFF667EEA),
          ),
          onPressed: widget.onCancel,
          icon: const Icon(Icons.arrow_back, size: 20),
          label: const Text(
            'Back to Detail',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Update Customer',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Phone is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Total Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Color(0xFFDC2626)),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(_isSubmitting ? 'Saving...' : 'Save'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ViewCustomerHistoryScreen: list orders for a customer.
class ViewCustomerHistoryScreen extends StatefulWidget {
  const ViewCustomerHistoryScreen({
    super.key,
    required this.customerId,
    required this.phone,
    required this.customerApiService,
    required this.onBack,
  });

  final int customerId;
  final String phone;
  final CustomerApiService customerApiService;
  final VoidCallback onBack;

  static String _formatDateTime(DateTime dt) {
    // 10:15 AM, 02/01/2025
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$hStr:$mStr $ampm, $day/$month/${dt.year}';
  }

  static String _formatMoney(double v) {
    final fmt = v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '${fmt}đ';
  }

  @override
  State<ViewCustomerHistoryScreen> createState() =>
      _ViewCustomerHistoryScreenState();
}

class _ViewCustomerHistoryScreenState extends State<ViewCustomerHistoryScreen> {
  late Future<List<OrderListItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.customerApiService.getCustomerOrderHistory(widget.customerId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderListItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cannot load history: ${snapshot.error}'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text('Back'),
                ),
              ],
            ),
          );
        }
        final orders = snapshot.data ?? [];
        return ListView(
          padding: const EdgeInsets.only(top: 8),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: widget.onBack,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '← Back to Customer List',
                    style: TextStyle(
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: 'Customer Order History – ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D21),
                ),
                children: [
                  TextSpan(
                    text: widget.phone,
                    style: const TextStyle(
                      color: Color(0xFF667EEA),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE8EAED)),
              ),
              child: orders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                        child: Text(
                          'No orders found for this phone number.',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        horizontalMargin: 20,
                        columnSpacing: 40,
                        headingRowColor: const WidgetStatePropertyAll(
                          Color(0xFFF7F8FA),
                        ),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5568),
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                        columns: const [
                          DataColumn(label: Text('ORDER ID')),
                          DataColumn(label: Text('DATE/TIME')),
                          DataColumn(label: Text('TOTAL')),
                          DataColumn(label: Text('DISCOUNT (%)')),
                          DataColumn(label: Text('PAYABLE')),
                          DataColumn(label: Text('PAYMENT')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTION')),
                        ],
                        rows: orders
                            .map(
                              (o) => DataRow(
                                cells: [
                                  DataCell(Text(o.orderNo)),
                                  DataCell(Text(
                                      ViewCustomerHistoryScreen._formatDateTime(
                                          o.createdAt))),
                                  DataCell(Text(
                                      ViewCustomerHistoryScreen._formatMoney(
                                          o.total))),
                                  DataCell(
                                    Center(
                                      child: Text(
                                        o.discountPercent == 0
                                            ? '—'
                                            : '${o.discountPercent.toStringAsFixed(0)}%',
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(
                                      ViewCustomerHistoryScreen._formatMoney(
                                          o.payable))),
                                  DataCell(Text(o.paymentMethod)),
                                  DataCell(
                                    _StatusBadge(status: o.status),
                                  ),
                                  DataCell(
                                    _ViewOrderActionBtn(
                                      onTap: () {
                                        // TODO: Navigate to Order details
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Full page for Cashier: Customer Management with back to barcode scanner.
class CashierCustomersPage extends StatelessWidget {
  const CashierCustomersPage({super.key, required this.fullName});

  final String fullName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: CustomersContent(
          fullName: fullName,
          isCompact: true,
          currentTimeText: '',
          onProfileTap: () {},
          showHeader: false,
          onBack: () => context.go('/cashier/barcode-scanner'),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final isPaid = s == 'paid';
    final isPending = s == 'pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFD1FAE5)
            : (isPending ? const Color(0xFFFEF3C7) : Colors.grey[200]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isPaid
              ? const Color(0xFF065F46)
              : (isPending ? const Color(0xFF92400E) : Colors.black87),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ViewOrderActionBtn extends StatelessWidget {
  const _ViewOrderActionBtn({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              'View',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
