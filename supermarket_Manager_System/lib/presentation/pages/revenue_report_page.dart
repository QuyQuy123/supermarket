import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/report_api_service.dart';
import 'package:supermarket_manager_system/domain/models/revenue_report_item.dart';

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
  final _service = ReportApiService();

  int _selectedYear = DateTime.now().year;
  int? _selectedMonth;

  bool _loading = false;
  String? _error;
  List<RevenueReportItem> _items = [];

  final List<int> _years = List.generate(5, (i) => DateTime.now().year - i);
  final List<String> _monthLabels = const [
    'All Months', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getRevenueReport(
        year: _selectedYear,
        month: _selectedMonth,
      );
      setState(() { _items = data; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  double get _maxRevenue {
    if (_items.isEmpty) return 1;
    final max = _items.map((e) => e.totalRevenue).reduce((a, b) => a > b ? a : b);
    return max == 0 ? 1 : max;
  }

  double get _totalRevenue => _items.fold(0, (s, e) => s + e.totalRevenue);
  int get _totalOrders => _items.fold(0, (s, e) => s + e.orderCount);

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M₫';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K₫';
    return '${v.toStringAsFixed(0)}₫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error', style: const TextStyle(color: Colors.red)))
                    : ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          _buildFilters(),
                          const SizedBox(height: 16),
                          _buildSummaryCards(),
                          const SizedBox(height: 16),
                          _buildBarChart(),
                          const SizedBox(height: 16),
                          _buildTable(),
                        ],
                      ),
          ),
        ],
      ),
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
              'Revenue Reports',
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
                  child: Text(widget.currentTimeText,
                      style: const TextStyle(color: Colors.white)),
                ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(widget.fullName.isEmpty ? 'Admin' : widget.fullName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Text('Administrator',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                ],
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: Container(
                  width: 40, height: 40,
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

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Row(
        children: [
          const Text('Year:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _selectedYear,
            items: _years
                .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                .toList(),
            onChanged: (v) {
              if (v != null) { setState(() => _selectedYear = v); _load(); }
            },
          ),
          const SizedBox(width: 20),
          const Text('Month:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          DropdownButton<int?>(
            value: _selectedMonth,
            items: [
              const DropdownMenuItem(value: null, child: Text('All Months')),
              ...List.generate(12, (i) => DropdownMenuItem(
                value: i + 1, child: Text(_monthLabels[i + 1]),
              )),
            ],
            onChanged: (v) {
              setState(() => _selectedMonth = v); _load();
            },
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _SummaryCard(
          title: 'Total Revenue',
          value: _fmt(_totalRevenue),
          color: const Color(0xFF667EEA),
          icon: Icons.attach_money,
        )),
        const SizedBox(width: 16),
        Expanded(child: _SummaryCard(
          title: 'Total Orders',
          value: _totalOrders.toString(),
          color: const Color(0xFF16A34A),
          icon: Icons.receipt_long,
        )),
        const SizedBox(width: 16),
        Expanded(child: _SummaryCard(
          title: 'Avg per Period',
          value: _items.isEmpty ? '0₫' : _fmt(_totalRevenue / _items.length),
          color: const Color(0xFFF59E0B),
          icon: Icons.trending_up,
        )),
      ],
    );
  }

  Widget _buildBarChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMonth == null
                ? 'Revenue by Month – $_selectedYear'
                : 'Revenue by Day – ${_monthLabels[_selectedMonth!]} $_selectedYear',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: _items.isEmpty
                ? const Center(child: Text('No data available', style: TextStyle(color: Color(0xFF6B7280))))
                : _RevenueBarChart(items: _items, maxValue: _maxRevenue, formatLabel: _fmt),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Revenue Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('Period', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Revenue', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Orders', style: TextStyle(fontWeight: FontWeight.w700))),
                DataColumn(label: Text('Avg per Order', style: TextStyle(fontWeight: FontWeight.w700))),
              ],
              rows: _items.map((item) {
                final avg = item.orderCount > 0 ? item.totalRevenue / item.orderCount : 0.0;
                return DataRow(cells: [
                  DataCell(Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(_fmt(item.totalRevenue),
                      style: const TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.w600))),
                  DataCell(Text(item.orderCount.toString())),
                  DataCell(Text(_fmt(avg))),
                ]);
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total: ${_fmt(_totalRevenue)} | $_totalOrders orders',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBarChart extends StatelessWidget {
  final List<RevenueReportItem> items;
  final double maxValue;
  final String Function(double) formatLabel;

  const _RevenueBarChart({
    required this.items,
    required this.maxValue,
    required this.formatLabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final chartWidth = constraints.maxWidth;
      final chartHeight = constraints.maxHeight - 40; // reserve for labels
      final barCount = items.length;
      final totalSpacing = barCount > 1 ? (barCount - 1) * 4.0 : 0.0;
      final barWidth = max(4.0, (chartWidth - totalSpacing) / barCount);

      return Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size(chartWidth, chartHeight),
              painter: _BarChartPainter(
                items: items,
                maxValue: maxValue,
                barWidth: barWidth,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: Row(
              children: items.map((item) {
                return SizedBox(
                  width: barWidth + 4,
                  child: Center(
                    child: Text(
                      item.label,
                      style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}

class _BarChartPainter extends CustomPainter {
  final List<RevenueReportItem> items;
  final double maxValue;
  final double barWidth;

  _BarChartPainter({
    required this.items,
    required this.maxValue,
    required this.barWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()
      ..color = const Color(0xFF667EEA)
      ..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = const Color(0xFFE8EAED)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final ratio = maxValue > 0 ? item.totalRevenue / maxValue : 0.0;
      final barHeight = size.height * ratio;
      final x = i * (barWidth + 4);
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      barPaint.color = item.totalRevenue > 0
          ? const Color(0xFF667EEA)
          : const Color(0xFFE8EAED);
      canvas.drawRRect(rect, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.items != items || old.maxValue != maxValue;
}
