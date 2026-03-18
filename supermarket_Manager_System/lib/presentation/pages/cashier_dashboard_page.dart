import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/customer_api_service.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/customer_list_item.dart';
import 'package:supermarket_manager_system/domain/models/order_detail.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';
import 'package:supermarket_manager_system/presentation/pages/profile_content_page.dart';

enum _CashierTab {
  scanner,
  customers,
  customerHistory,
  orderDetail,
  profile,
  profileEdit,
}

class CashierDashboardPage extends StatefulWidget {
  const CashierDashboardPage({
    super.key,
    required this.fullName,
    required this.userId,
    required this.initialTabKey,
    required this.initialPhone,
    required this.initialOrderId,
    required this.onNavigatePath,
    required this.onLogoutRequested,
  });

  final String fullName;
  final int userId;
  final String initialTabKey;
  final String initialPhone;
  final int? initialOrderId;
  final void Function(String path) onNavigatePath;
  final VoidCallback onLogoutRequested;

  @override
  State<CashierDashboardPage> createState() => _CashierDashboardPageState();
}

class _CashierDashboardPageState extends State<CashierDashboardPage> {
  final _customerApiService = CustomerApiService();
  final _orderApiService = OrderApiService();
  final TextEditingController _totalCashEndController = TextEditingController();

  late DateTime _now;
  Timer? _clockTimer;
  late _CashierTab _selectedTab;
  String _selectedPhone = '';
  int? _selectedOrderId;

  List<CustomerListItem> _customers = const [];
  bool _isLoadingCustomers = true;
  String? _customersError;

  List<OrderListItem> _historyOrders = const [];
  bool _isLoadingHistory = false;
  String? _historyError;
  bool _isLoadingOrderDetail = false;
  String? _orderDetailError;
  OrderDetail? _orderDetail;
  UserDetail? _editingProfile;

  @override
  void initState() {
    super.initState();
    _selectedTab = _tabFromKey(widget.initialTabKey);
    _selectedPhone = widget.initialPhone;
    _selectedOrderId = widget.initialOrderId;
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
    _loadCustomers();
    if (_selectedTab == _CashierTab.customerHistory && _selectedPhone.isNotEmpty) {
      _loadHistory();
    }
    if (_selectedTab == _CashierTab.orderDetail && _selectedOrderId != null) {
      _loadOrderDetail(_selectedOrderId!);
    }
  }

  @override
  void didUpdateWidget(covariant CashierDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTab = _tabFromKey(widget.initialTabKey);
    if (newTab != _selectedTab ||
        widget.initialPhone != _selectedPhone ||
        widget.initialOrderId != _selectedOrderId) {
      setState(() {
        _selectedTab = newTab;
        _selectedPhone = widget.initialPhone;
        _selectedOrderId = widget.initialOrderId;
      });
      if (newTab == _CashierTab.customerHistory && widget.initialPhone.isNotEmpty) {
        _loadHistory();
      }
      if (newTab == _CashierTab.orderDetail && widget.initialOrderId != null) {
        _loadOrderDetail(widget.initialOrderId!);
      }
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _totalCashEndController.dispose();
    super.dispose();
  }

  _CashierTab _tabFromKey(String key) {
    switch (key) {
      case 'customers':
        return _CashierTab.customers;
      case 'customer-history':
        return _CashierTab.customerHistory;
      case 'order-detail':
        return _CashierTab.orderDetail;
      case 'profile':
        return _CashierTab.profile;
      case 'profile-edit':
        return _CashierTab.profileEdit;
      case 'scanner':
      default:
        return _CashierTab.scanner;
    }
  }

  void _navigateToTab(_CashierTab tab, {String? phone}) {
    if (tab == _CashierTab.scanner) {
      widget.onNavigatePath('/cashier/barcode-scanner');
      return;
    }
    if (tab == _CashierTab.customers) {
      widget.onNavigatePath('/cashier/customers');
      return;
    }
    if (tab == _CashierTab.profile) {
      widget.onNavigatePath('/cashier/profile');
      return;
    }
    if (tab == _CashierTab.profileEdit) {
      widget.onNavigatePath('/cashier/profile/edit');
      return;
    }
    if (tab == _CashierTab.customerHistory) {
      final targetPhone = (phone ?? _selectedPhone).trim();
      widget.onNavigatePath('/cashier/customers/history?phone=${Uri.encodeComponent(targetPhone)}');
      return;
    }
    final orderId = _selectedOrderId;
    if (orderId != null) {
      final targetPhone = (phone ?? _selectedPhone).trim();
      widget.onNavigatePath(
        '/cashier/orders/detail?orderId=$orderId&phone=${Uri.encodeComponent(targetPhone)}',
      );
    }
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
      _customersError = null;
    });
    try {
      final data = await _customerApiService.getCustomers();
      if (!mounted) {
        return;
      }
      setState(() {
        _customers = data;
        _isLoadingCustomers = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _customersError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingCustomers = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    if (_selectedPhone.isEmpty) {
      setState(() {
        _historyOrders = const [];
        _historyError = null;
        _isLoadingHistory = false;
      });
      return;
    }
    setState(() {
      _isLoadingHistory = true;
      _historyError = null;
    });
    try {
      final allOrders = await _orderApiService.getOrders();
      final filtered = allOrders.where((o) => o.customerPhone.trim() == _selectedPhone.trim()).toList();
      if (!mounted) {
        return;
      }
      setState(() {
        _historyOrders = filtered;
        _isLoadingHistory = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _historyError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadOrderDetail(int orderId) async {
    setState(() {
      _isLoadingOrderDetail = true;
      _orderDetailError = null;
    });
    try {
      final detail = await _orderApiService.getOrderDetail(orderId);
      if (!mounted) {
        return;
      }
      setState(() {
        _orderDetail = detail;
        _isLoadingOrderDetail = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _orderDetailError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingOrderDetail = false;
      });
    }
  }

  void _openProfileEdit(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _CashierTab.profileEdit;
    });
    _navigateToTab(_CashierTab.profileEdit);
  }

  void _onProfileUpdated(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _CashierTab.profile;
    });
    _navigateToTab(_CashierTab.profile);
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _timeText() => '${_two(_now.hour)}:${_two(_now.minute)}:${_two(_now.second)}';
  String _money(double amount) => '${amount.toStringAsFixed(0)}đ';
  String _discountText(double p) => p <= 0 ? '—' : '${p.toStringAsFixed(0)}%';

  Future<void> _openCloseShiftDialog() async {
    final fullName = widget.fullName.isEmpty ? 'Cashier' : widget.fullName;
    _totalCashEndController.clear();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8EAED)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF0F766E)]),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Close Shift',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Employee name'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(fullName),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _totalCashEndController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Enter total cash after shift',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: ElevatedButton(
                    onPressed: () {
                      final amount = double.tryParse(_totalCashEndController.text.trim().replaceAll(',', ''));
                      if (amount == null || amount < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid total cash amount.')),
                        );
                        return;
                      }
                      Navigator.of(dialogContext).pop();
                      widget.onLogoutRequested();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D9488)),
                    child: const Text('Confirm & close shift', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUpdateCustomerDialog(CustomerListItem customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index < 0) return;
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final amountController = TextEditingController(text: customer.totalAmount.toStringAsFixed(0));

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('Update Customer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(onPressed: () => Navigator.of(dialogContext).pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 10),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 10),
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount')),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final dialogNavigator = Navigator.of(dialogContext);
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final amount = double.tryParse(amountController.text.trim().replaceAll(',', '').replaceAll('đ', ''));
                        if (name.isEmpty || phone.isEmpty || amount == null || amount < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Name, Phone, and Amount are required.')),
                          );
                          return;
                        }
                        try {
                          final updated = await _customerApiService.updateCustomer(
                            customerId: customer.id,
                            name: name,
                            phone: phone,
                            totalAmount: amount,
                          );
                          if (!mounted) return;
                          setState(() => _customers[index] = updated);
                          dialogNavigator.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Customer updated successfully.')),
                          );
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                      child: const Text('Update', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameController.dispose();
    phoneController.dispose();
    amountController.dispose();
  }

  Widget _buildBody() {
    switch (_selectedTab) {
      case _CashierTab.scanner:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _scannerInputBox(
                    label: 'Customer Name',
                    hint: 'Optional [Required for credit sales]',
                  ),
                  _scannerInputBox(
                    label: 'Phone',
                    hint: 'Optional [Required for credit sales]',
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add customer for points'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('+ Add To Cart'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Scan product barcode'),
                  ),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Scan or enter barcode...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by name or code...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: const WidgetStatePropertyAll(Color(0xFF7DD3FC)),
                    columns: const [
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('Stock Qty')),
                      DataColumn(label: Text('Unit Price')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Subtotal')),
                      DataColumn(label: Text('')),
                    ],
                    rows: const [
                      DataRow(
                        cells: [
                          DataCell(Text('No products. Scan barcode or search to add.')),
                          DataCell(Text('-')),
                          DataCell(Text('-')),
                          DataCell(Text('-')),
                          DataCell(Text('-')),
                          DataCell(Text('-')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Text(
                    'Grand Total: ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text('0đ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        );
      case _CashierTab.customers:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Customer List', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoadingCustomers
                    ? const Center(child: CircularProgressIndicator())
                    : _customersError != null
                        ? Center(child: Text('Cannot load customers: $_customersError'))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('S/N')),
                                  DataColumn(label: Text('CUSTOMER')),
                                  DataColumn(label: Text('PHONE')),
                                  DataColumn(label: Text('POINTS')),
                                  DataColumn(label: Text('PURCHASES')),
                                  DataColumn(label: Text('TOTAL AMOUNT')),
                                  DataColumn(label: Text('DISCOUNT')),
                                  DataColumn(label: Text('ACTIONS')),
                                ],
                                rows: _customers.asMap().entries.map((entry) {
                                  final c = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${entry.key + 1}')),
                                      DataCell(Text(c.name)),
                                      DataCell(
                                        InkWell(
                                          onTap: () {
                                            setState(() => _selectedPhone = c.phone);
                                            _navigateToTab(_CashierTab.customerHistory, phone: c.phone);
                                          },
                                          child: Text(
                                            c.phone,
                                            style: const TextStyle(
                                              color: Color(0xFF3B82F6),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(Text('${c.points}')),
                                      DataCell(Text('${c.totalPurchases}')),
                                      DataCell(Text(_money(c.totalAmount))),
                                      DataCell(Text(_discountText(c.discountPercent))),
                                      DataCell(
                                        TextButton(
                                          onPressed: () => _openUpdateCustomerDialog(c),
                                          child: const Text('Edit'),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        );
      case _CashierTab.customerHistory:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                onPressed: () => _navigateToTab(_CashierTab.customers),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Customer List'),
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              ),
              Text(
                'Customer Order History - ${_selectedPhone.isEmpty ? '—' : _selectedPhone}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoadingHistory
                    ? const Center(child: CircularProgressIndicator())
                    : _historyError != null
                        ? Center(child: Text('Cannot load history: $_historyError'))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: _historyOrders.isEmpty
                                ? const Center(child: Text('No orders found for this phone number.'))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
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
                                      rows: _historyOrders
                                          .map(
                                            (o) => DataRow(
                                              cells: [
                                                DataCell(Text(o.orderNo)),
                                                DataCell(Text(o.orderDateTime)),
                                                DataCell(Text(_money(o.total))),
                                                DataCell(Text(o.discountPercent.toStringAsFixed(0))),
                                                DataCell(Text(_money(o.payable))),
                                                DataCell(Text(o.paymentMethod)),
                                                DataCell(Text(o.status)),
                                                DataCell(
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _selectedOrderId = o.id;
                                                      });
                                                      _navigateToTab(
                                                        _CashierTab.orderDetail,
                                                        phone: _selectedPhone,
                                                      );
                                                    },
                                                    child: const Text('View'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                          ),
              ),
            ],
          ),
        );
      case _CashierTab.orderDetail:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton.icon(
                onPressed: () => _navigateToTab(_CashierTab.customerHistory),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Customer Order History'),
                style: TextButton.styleFrom(alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 8),
              if (_isLoadingOrderDetail)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_orderDetailError != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Cannot load order detail: $_orderDetailError'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedOrderId != null) {
                              _loadOrderDetail(_selectedOrderId!);
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_orderDetail == null)
                const Expanded(child: Center(child: Text('Order detail not found.')))
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: _OrderDetailCard(
                      detail: _orderDetail!,
                      moneyFormatter: _money,
                    ),
                  ),
                ),
            ],
          ),
        );
      case _CashierTab.profile:
        return ProfileViewContent(
          fullName: widget.fullName,
          userId: widget.userId,
          isCompact: false,
          currentTimeText: _timeText(),
          onEditProfile: _openProfileEdit,
        );
      case _CashierTab.profileEdit:
        return ProfileEditContent(
          userId: widget.userId,
          initialDetail: _editingProfile,
          isCompact: false,
          currentTimeText: _timeText(),
          onSaved: _onProfileUpdated,
          onCancel: () => _navigateToTab(_CashierTab.profile),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.fullName.isEmpty ? 'Cashier' : widget.fullName;
    final hideShellHeader =
        _selectedTab == _CashierTab.profile ||
        _selectedTab == _CashierTab.profileEdit;
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Row(
        children: [
          Container(
            width: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  color: const Color.fromRGBO(0, 0, 0, 0.12),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Text('P', style: TextStyle(color: Color(0xFF667EEA))),
                      ),
                      SizedBox(width: 10),
                      Text('SMS SYSTEM', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _MenuItem(
                  label: 'Barcode Scanner',
                  active: _selectedTab == _CashierTab.scanner,
                  onTap: () => _navigateToTab(_CashierTab.scanner),
                ),
                _MenuItem(
                  label: 'Customer',
                  active: _selectedTab == _CashierTab.customers || _selectedTab == _CashierTab.customerHistory,
                  onTap: () => _navigateToTab(_CashierTab.customers),
                ),
                const Spacer(),
                _MenuItem(label: 'Logout', active: false, onTap: _openCloseShiftDialog),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (!hideShellHeader)
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_timeText(), style: const TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(fullName),
                            const Text('Cashier', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () => _navigateToTab(_CashierTab.profile),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scannerInputBox({required String label, required String hint}) {
    return SizedBox(
      width: 280,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.label,
    required this.active,
    this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? const Color.fromRGBO(255, 255, 255, 0.2) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({
    required this.detail,
    required this.moneyFormatter,
  });

  final OrderDetail detail;
  final String Function(double value) moneyFormatter;

  String _discountText() {
    if (detail.discountPercent <= 0 || detail.discountAmount <= 0) {
      return '0đ';
    }
    return '${detail.discountPercent.toStringAsFixed(0)}% (${moneyFormatter(detail.discountAmount)})';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EAED)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Detail - ${detail.orderNo}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Số điện thoại khách hàng (nếu có): ${detail.customerPhone}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhân viên bán hàng: ${detail.cashierName}',
                style: const TextStyle(fontSize: 16, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7F8FA)),
                  columns: const [
                    DataColumn(label: Text('ĐƠN GIÁ')),
                    DataColumn(label: Text('SỐ LƯỢNG')),
                    DataColumn(label: Text('THÀNH TIỀN')),
                  ],
                  rows: detail.items
                      .map(
                        (item) => DataRow(
                          cells: [
                            DataCell(
                              Text('(${item.productName} - ${moneyFormatter(item.unitPrice)})'),
                            ),
                            DataCell(Text(item.qty.toString())),
                            DataCell(Text(moneyFormatter(item.amount))),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE8EAED), thickness: 1.5),
              const SizedBox(height: 8),
              _SummaryRow(label: 'Tổng tiền hàng', value: moneyFormatter(detail.subtotal)),
              _SummaryRow(label: 'Giảm giá', value: _discountText()),
              const Divider(color: Color(0xFFE8EAED)),
              _SummaryRow(
                label: 'Tổng thanh toán',
                value: moneyFormatter(detail.totalPayment),
                isTotal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Color(0xFF1A1D21))
        : const TextStyle(fontSize: 16, color: Color(0xFF374151));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

