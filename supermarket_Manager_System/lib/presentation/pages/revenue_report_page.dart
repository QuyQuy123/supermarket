import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/order_api_service.dart';
import 'package:supermarket_manager_system/domain/models/order_list_item.dart';

class RevenueReportPage extends StatefulWidget {
  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback? onProfileTap;

  const RevenueReportPage({
    super.key,
    required this.fullName,
    this.isCompact = false,
    this.currentTimeText = '',
    this.onProfileTap,
  });

  @override
  State<RevenueReportPage> createState() => _RevenueReportPageState();
}

class _RevenueReportPageState extends State<RevenueReportPage> {
  final _service = OrderApiService();

  bool _loading = false;
  String? _error;
  List<OrderListItem> _allOrders = [];
  List<OrderListItem> _filteredOrders = [];

  late DateTime _fromDate;
  late DateTime _toDate;
  String _selectedPayment = 'All Payments';

  // AI Chatbox state
  bool _isChatOpen = false;
  final TextEditingController _chatController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _chatMessages = [
    {
      'text': 'Xin chào! Tôi là trợ lý AI. Bạn có thể nhập câu hỏi về báo cáo, doanh thu hoặc bất kỳ thắc mắc nào.',
      'isUser': false
    },
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _fromDate = DateTime(now.year, now.month, 1);
    _toDate = now;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getOrders();
      _allOrders = data;
      _applyFilter();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyFilter() {
    if (_fromDate.isAfter(_toDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: "From Date" cannot be after "To Date"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _filteredOrders = _allOrders.where((o) {
        final date = o.createdAt;
        final d = DateTime(date.year, date.month, date.day);
        final from = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
        final to = DateTime(_toDate.year, _toDate.month, _toDate.day);

        if (d.isBefore(from) || d.isAfter(to)) return false;
        if (_selectedPayment != 'All Payments' && o.paymentMethod != _selectedPayment) return false;
        return true;
      }).toList();
    });
  }

  // Formatting helpers
  String _formatMoney(double v) {
    if (v == 0) return '0đ';
    final fmt = v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$fmtđ';
  }

  static const _monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Summaries
  double get _totalRevenue => _filteredOrders.fold(0, (sum, o) => sum + o.payable);
  double _paymentSum(String method) => _filteredOrders
      .where((o) => o.paymentMethod.toLowerCase() == method.toLowerCase())
      .fold(0, (sum, o) => sum + o.payable);

  void _sendAiMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add({'text': text, 'isUser': true});
      _chatController.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final q = text.toLowerCase();
      String reply = 'Cảm ơn bạn đã gửi câu hỏi. Đây là tính năng trợ lý AI demo. Bạn có thể kết nối API AI thực tế để nhận câu trả lời.';
      if (q.contains('doanh thu') || q.contains('revenue')) {
        reply = 'Tổng doanh thu hiện tại trong báo cáo là ${_formatMoney(_totalRevenue)}. Bạn có thể xem chi tiết trong bảng phía trên.';
      } else if (q.contains('báo cáo') || q.contains('report')) {
        reply = 'Đây là trang Sales Report. Bạn có thể lọc theo khoảng thời gian, loại thanh toán và xuất Excel. Nếu cần phân tích sâu hơn, hãy mô tả cụ thể.';
      } else if (q.contains('xin chào') || q.contains('hello')) {
        reply = 'Xin chào! Tôi có thể hỗ trợ bạn về báo cáo bán hàng, doanh thu và dữ liệu trên trang này.';
      }
      setState(() {
        _chatMessages.add({'text': reply, 'isUser': false});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF0F2F5),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                        : Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: ListView(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(24),
                              children: [
                              // Title
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.analytics, color: Color(0xFF4F46E5)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Sales Report for ${_monthNames[_fromDate.month - 1]}, ${_fromDate.year}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1D21),
                                      letterSpacing: -0.02,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildPaymentCards(),
                              const SizedBox(height: 24),
                              _buildFilters(),
                              const SizedBox(height: 24),
                              _buildTable(),
                              const SizedBox(height: 16),
                              _buildTotalBanner(),
                            ],
                          ),
                        ),
                      ),
            ],
          ),
        ),
        // AI Chatbox UI
        if (_isChatOpen)
          Positioned(
            right: 24,
            bottom: 90,
            child: _buildAiChatBox(),
          ),
        // AI FAB
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF6366F1),
            onPressed: () {
              setState(() => _isChatOpen = !_isChatOpen);
            },
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
          if (widget.isCompact)
            Builder(
              builder: (ctx) => IconButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                icon: const Icon(Icons.menu),
              ),
            )
          else
            const Text(
              'Sales Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          Row(
            children: [
              if (widget.currentTimeText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(widget.currentTimeText, style: const TextStyle(color: Colors.white)),
                ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.fullName.isEmpty ? 'Admin' : widget.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Text('Administrator', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.fullName.isNotEmpty ? widget.fullName[0].toUpperCase() : 'A',
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

  Widget _buildPaymentCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 800 ? 2 : 4;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: constraints.maxWidth < 600 ? 2.5 : 2.0,
          children: [
            _buildPaymentCard('₦', 'Cash Payment', _paymentSum('Cash'), const Color(0xFF16A34A), Colors.white),
            _buildPaymentCard('⇄', 'Transfer Payment', _paymentSum('Transfer'), const Color(0xFFDC2626), Colors.white),
            _buildPaymentCard('💳', 'POS Payment', _paymentSum('POS'), const Color(0xFFEAB308), const Color(0xFF1A1D21)),
            _buildPaymentCard('📄', 'Cheque Payment', _paymentSum('Cheque'), const Color(0xFF38BDF8), Colors.white),
          ],
        );
      },
    );
  }

  Widget _buildPaymentCard(String iconStr, String label, double amount, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor == const Color(0xFFEAB308) ? const Color(0x26000000) : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(iconStr, style: TextStyle(fontSize: 24, color: textColor)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(_formatMoney(amount), style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('You can filter sales record by date range', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            _buildDatePicker(
              'FROM',
              _fromDate,
              (d) => setState(() => _fromDate = d),
              first: DateTime(2000),
              last: _toDate,
            ),
            const SizedBox(width: 16),
            _buildDatePicker(
              'TO',
              _toDate,
              (d) => setState(() => _toDate = d),
              first: _fromDate,
              last: DateTime.now(),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(8)),
                  height: 40,
                  alignment: Alignment.center,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPayment,
                      isDense: true,
                      items: ['All Payments', 'Cash', 'Transfer', 'POS', 'Cheque']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPayment = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {
                  _applyFilter();
                },
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Search Record'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1D21),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.bar_chart, size: 18),
                label: const Text('Export Excel'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onPicked, {DateTime? first, DateTime? last}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final now = DateTime.now();
            final d = await showDatePicker(
              context: context,
              initialDate: date.isAfter(last ?? now) ? (last ?? now) : (date.isBefore(first ?? DateTime(2000)) ? (first ?? DateTime(2000)) : date),
              firstDate: first ?? DateTime(2000),
              lastDate: last ?? now,
            );
            if (d != null) onPicked(d);
          },
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.centerLeft,
            child: Text(_formatDate(date), style: const TextStyle(fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2))],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFFF7F8FA)),
                headingTextStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A5568), fontSize: 12),
                columns: const [
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Discount (%)')),
                  DataColumn(label: Text('Payable')),
                  DataColumn(label: Text('Payment Method')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Cashier')),
                ],
                rows: _filteredOrders.map((o) {
                  return DataRow(cells: [
                    DataCell(Text(o.orderNo, style: const TextStyle(fontWeight: FontWeight.w500))),
                    DataCell(Text(o.customerPhone)),
                    DataCell(Text(_formatMoney(o.total))),
                    DataCell(Text(o.discountPercent.toStringAsFixed(0))),
                    DataCell(Text(_formatMoney(o.payable), style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF16A34A)))),
                    DataCell(Text(o.paymentMethod.isEmpty ? '—' : o.paymentMethod)),
                    DataCell(Text(o.status.isEmpty ? '—' : o.status)),
                    DataCell(Text(o.cashierName.isEmpty ? '—' : o.cashierName)),
                  ]);
                }).toList(),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildTotalBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Tổng doanh thu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF166534))),
          Text(_formatMoney(_totalRevenue), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
        ],
      ),
    );
  }

  Widget _buildAiChatBox() {
    return Container(
      width: 380,
      height: 480,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 32, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('✨ Trợ lý AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                InkWell(
                  onTap: () => setState(() => _isChatOpen = false),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: Container(
              color: const Color(0xFFF9FAFB),
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  final msg = _chatMessages[index];
                  final isUser = msg['isUser'] as bool;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      constraints: const BoxConstraints(maxWidth: 280),
                      decoration: BoxDecoration(
                        color: isUser ? null : Colors.white,
                        gradient: isUser ? const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]) : null,
                        border: isUser ? null : Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg['text'] as String,
                        style: TextStyle(color: isUser ? Colors.white : const Color(0xFF374151), fontSize: 13, height: 1.4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi...',
                      hintStyle: const TextStyle(fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendAiMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _sendAiMessage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Gửi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
