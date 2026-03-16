import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/utils/app_session.dart';

class CashierCustomerPage extends StatefulWidget {
  const CashierCustomerPage({
    super.key,
    required this.fullName,
  });

  final String fullName;

  @override
  State<CashierCustomerPage> createState() => _CashierCustomerPageState();
}

class _CashierCustomerPageState extends State<CashierCustomerPage> {
  late DateTime _now;
  Timer? _clockTimer;
  final TextEditingController _totalCashEndController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _totalCashEndController.dispose();
    super.dispose();
  }

  String _timeText() {
    return '${_twoDigits(_now.hour)}:${_twoDigits(_now.minute)}:${_twoDigits(_now.second)}';
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  Future<void> _openCloseShiftDialog() async {
    final fullName = widget.fullName.isEmpty ? 'Cashier' : widget.fullName;
    _totalCashEndController.clear();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
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
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Close Shift',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Enter total cash at end of shift to close your shift.',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          borderRadius: BorderRadius.circular(16),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Employee name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1D21),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Total cash at end of shift',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _totalCashEndController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter total cash after shift (e.g. 1500000)',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Total cash in drawer at the end of your shift.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                    ),
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          final raw = _totalCashEndController.text.trim().replaceAll(',', '');
                          final amount = double.tryParse(raw);
                          if (amount == null || amount < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a valid total cash amount.'),
                              ),
                            );
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          AppSession.instance.clear();
                          context.go('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Confirm & close shift',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.fullName.isEmpty ? 'Cashier' : widget.fullName;
    final customers = const [
      _CustomerRow('1', 'Nguyen Van A', '0901234567', '1,250', '18', '2,450,000đ', '5%'),
      _CustomerRow('2', 'Tran Thi B', '0912345678', '820', '12', '1,180,500đ', '3%'),
      _CustomerRow('3', 'Le Van C', '0923456789', '450', '7', '685,200đ', '—'),
      _CustomerRow('4', 'Pham Thi D', '0934567890', '2,100', '32', '4,920,000đ', '10%'),
      _CustomerRow('5', 'Hoang Van E', '0945678901', '120', '3', '156,000đ', '—'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Row(
        children: [
          Container(
            width: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
                        child: Text(
                          'P',
                          style: TextStyle(
                            color: Color(0xFF667EEA),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'SMS SYSTEM',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _CashierMenuItem(
                  label: 'Barcode Scanner',
                  active: false,
                  onTap: () => context.go('/cashier/barcode-scanner'),
                ),
                const _CashierMenuItem(label: 'Customer', active: true),
                const Spacer(),
                _CashierMenuItem(
                  label: 'Logout',
                  active: false,
                  onTap: _openCloseShiftDialog,
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
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
                          const Text(
                            'Cashier',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFF667EEA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          fullName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Customer List',
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _openCustomerDialog(
                                title: 'Add Customer',
                                submitText: 'Submit',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Customer'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7F8FA)),
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
                                rows: customers
                                    .map(
                                      (c) => DataRow(
                                        cells: [
                                          DataCell(Text(c.sn)),
                                          DataCell(Text(c.customer)),
                                          DataCell(Text(c.phone)),
                                          DataCell(Text(c.points)),
                                          DataCell(Text(c.purchases)),
                                          DataCell(Text(c.totalAmount)),
                                          DataCell(Text(c.discount)),
                                          DataCell(
                                            TextButton(
                                              onPressed: () => _openCustomerDialog(
                                                title: 'Update Customer',
                                                submitText: 'Update',
                                              ),
                                              child: const Text('Edit'),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCustomerDialog({
    required String title,
    required String submitText,
  }) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(submitText),
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
}

class _CustomerRow {
  const _CustomerRow(
    this.sn,
    this.customer,
    this.phone,
    this.points,
    this.purchases,
    this.totalAmount,
    this.discount,
  );

  final String sn;
  final String customer;
  final String phone;
  final String points;
  final String purchases;
  final String totalAmount;
  final String discount;
}

class _CashierMenuItem extends StatelessWidget {
  const _CashierMenuItem({
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

