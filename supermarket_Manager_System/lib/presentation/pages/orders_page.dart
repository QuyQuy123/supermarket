import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/order_detail.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';

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
                                child: _OrderDetailCard(
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

class _OrderDetailCard extends StatelessWidget {
  const _OrderDetailCard({
    required this.detail,
    required this.moneyFormatter,
    required this.onBack,
  });

  final OrderDetail detail;
  final String Function(double value) moneyFormatter;
  final VoidCallback onBack;

  String _discountText() {
    if (detail.discountPercent <= 0 || detail.discountAmount <= 0) {
      return 'đ0';
    }
    return '${detail.discountPercent.toStringAsFixed(0)}% (${moneyFormatter(detail.discountAmount)})';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Orders List'),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF0D9488)),
          ),
          const SizedBox(height: 4),
          Text(
            'Order Detail - ${detail.orderNo}',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
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
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4A5568),
                        fontSize: 12,
                      ),
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
                  _SummaryRow(
                    label: 'Tổng tiền hàng',
                    value: moneyFormatter(detail.subtotal),
                  ),
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
        ],
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

