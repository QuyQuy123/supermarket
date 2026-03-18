import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/order_detail.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';
import 'package:supermarket_manager_system/presentation/widgets/order_detail_card.dart';

class OrdersContent extends StatefulWidget {
  const OrdersContent({
    super.key,
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.roleLabel,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final String roleLabel;
  final VoidCallback onProfileTap;

  @override
  State<OrdersContent> createState() => _OrdersContentState();
}

class _OrdersContentState extends State<OrdersContent> {
  final _orderApiService = OrderApiService();
  late Future<List<OrderListItem>> _ordersFuture;
  int? _selectedOrderId;
  Future<OrderDetail>? _orderDetailFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderApiService.getOrders();
  }

  void _reloadOrders() {
    setState(() => _ordersFuture = _orderApiService.getOrders());
  }

  void _openOrderDetail(int orderId) {
    setState(() {
      _selectedOrderId = orderId;
      _orderDetailFuture = _orderApiService.getOrderDetail(orderId);
    });
  }

  void _backToOrderList() {
    setState(() {
      _selectedOrderId = null;
      _orderDetailFuture = null;
    });
  }

  String _money(double value) => 'đ${value.toStringAsFixed(0)}';

  String _paidText(double? paid) => paid == null ? '—' : _money(paid);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _OrdersHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
            roleLabel: widget.roleLabel,
            onProfileTap: widget.onProfileTap,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedOrderId == null) ...[
                    const Text(
                      'Orders List',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Expanded(
                    child: _selectedOrderId == null
                        ? FutureBuilder<List<OrderListItem>>(
                            future: _ordersFuture,
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
                                        'Cannot load orders: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _reloadOrders,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final orders = snapshot.data ?? [];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE8EAED)),
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: const WidgetStatePropertyAll(
                                      Color(0xFFF7F8FA),
                                    ),
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4A5568),
                                      fontSize: 12,
                                    ),
                                    columns: const [
                                      DataColumn(label: Text('ORDER ID')),
                                      DataColumn(label: Text('CUSTOMER')),
                                      DataColumn(label: Text('PHONE')),
                                      DataColumn(label: Text('TOTAL')),
                                      DataColumn(label: Text('DISCOUNT (%)')),
                                      DataColumn(label: Text('PAYABLE')),
                                      DataColumn(label: Text('PAID')),
                                      DataColumn(label: Text('PAYMENT')),
                                      DataColumn(label: Text('STATUS')),
                                      DataColumn(label: Text('CASHIER')),
                                      DataColumn(label: Text('ACTION')),
                                    ],
                                    rows: orders
                                        .map(
                                          (order) => DataRow(
                                            cells: [
                                              DataCell(Text(order.orderNo)),
                                              DataCell(Text(order.customerName)),
                                              DataCell(Text(order.customerPhone)),
                                              DataCell(Text(_money(order.total))),
                                              DataCell(
                                                Text(order.discountPercent.toStringAsFixed(0)),
                                              ),
                                              DataCell(Text(_money(order.payable))),
                                              DataCell(Text(_paidText(order.paid))),
                                              DataCell(Text(order.paymentMethod)),
                                              DataCell(
                                                _OrderStatusBadge(status: order.status),
                                              ),
                                              DataCell(Text(order.cashierName)),
                                              DataCell(
                                                TextButton(
                                                  onPressed: () => _openOrderDetail(order.id),
                                                  child: const Text('View'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          )
                        : FutureBuilder<OrderDetail>(
                            future: _orderDetailFuture,
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
                                        'Cannot load order detail: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () => _openOrderDetail(_selectedOrderId!),
                                        child: const Text('Retry'),
                                      ),
                                      const SizedBox(height: 8),
                                      TextButton(
                                        onPressed: _backToOrderList,
                                        child: const Text('Back to Orders List'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final detail = snapshot.data;
                              if (detail == null) {
                                return const Center(child: Text('Order detail not found.'));
                              }

                              return SingleChildScrollView(
                                child: OrderDetailCard(
                                  detail: detail,
                                  moneyFormatter: _money,
                                  onBack: _backToOrderList,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.roleLabel,
    required this.onProfileTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final String roleLabel;
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(currentTimeText, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fullName.isEmpty ? roleLabel : fullName),
                  Text(
                    roleLabel,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
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
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : roleLabel[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isPaid = normalized == 'paid';
    final isPending = normalized == 'pending';
    final bg = isPaid
        ? const Color(0xFFD1FAE5)
        : isPending
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2);
    final fg = isPaid
        ? const Color(0xFF065F46)
        : isPending
            ? const Color(0xFF92400E)
            : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
