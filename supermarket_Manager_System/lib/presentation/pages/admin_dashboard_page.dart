import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/presentation/pages/users_page.dart';

enum _AdminTab { dashboard, users }

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({
    super.key,
    required this.fullName,
  });

  final String fullName;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  _AdminTab _selectedTab = _AdminTab.dashboard;

  void _selectTab(_AdminTab tab) {
    setState(() => _selectedTab = tab);
    final isCompact = MediaQuery.sizeOf(context).width < 1024;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1024;

        return Scaffold(
          drawer: isCompact
              ? Drawer(
                  width: 250,
                  child: _SidebarMenu(
                    selectedTab: _selectedTab,
                    onSelectTab: _selectTab,
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!isCompact)
                SizedBox(
                  width: 230,
                  child: _SidebarMenu(
                    selectedTab: _selectedTab,
                    onSelectTab: _selectTab,
                  ),
                ),
              Expanded(
                child: _selectedTab == _AdminTab.dashboard
                    ? _DashboardContent(
                        fullName: widget.fullName,
                        isCompact: isCompact,
                      )
                    : UsersContent(
                        fullName: widget.fullName,
                        isCompact: isCompact,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  const _SidebarMenu({
    required this.selectedTab,
    required this.onSelectTab,
  });

  final _AdminTab selectedTab;
  final ValueChanged<_AdminTab> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            child: const Row(
              children: [
                _LogoBox(),
                SizedBox(width: 10),
                Text(
                  'SMS SYSTEM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _SidebarItem(
                      label: 'Dashboard',
                      active: selectedTab == _AdminTab.dashboard,
                      onTap: () => onSelectTab(_AdminTab.dashboard),
                    ),
                    _SidebarItem(
                      label: 'Users',
                      active: selectedTab == _AdminTab.users,
                      onTap: () => onSelectTab(_AdminTab.users),
                    ),
                    const _SidebarItem(label: 'Customer'),
                    const _SidebarItem(label: 'Discount'),
                    const _SidebarItem(label: 'Suppliers'),
                    const _SidebarItem(label: 'Category'),
                    const _SidebarItem(label: 'Products'),
                    const _SidebarItem(label: 'Barcode Scanner'),
                    const _SidebarItem(label: 'Orders'),
                    const _SidebarItem(label: 'Creditors'),
                    const _SidebarItem(label: 'Expired'),
                    const _SidebarItem(label: 'Reports'),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Color.fromRGBO(255, 255, 255, 0.25), height: 1),
          const _SidebarItem(label: 'Logout'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.fullName,
    required this.isCompact,
  });

  final String fullName;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Color(0xFFE8EAED)),
              ),
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
                        color: const Color(0xFF16A34A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '11:07:24 AM',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fullName.isEmpty ? 'Administrator' : fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const Text(
                          'Administrator',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                _TopCards(),
                SizedBox(height: 16),
                _StatsGrid(),
                SizedBox(height: 16),
                _ChartRow(),
                SizedBox(height: 16),
                _TransactionTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'P',
        style: TextStyle(
          color: Color(0xFF667EEA),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    this.active = false,
    this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: active ? const Color.fromRGBO(255, 255, 255, 0.18) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: active ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        onTap: onTap,
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TopCards extends StatelessWidget {
  const _TopCards();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _CardData(color: Color(0xFF16A34A), title: 'Today Sales', value: '250,000đ'),
      _CardData(color: Color(0xFFF472B6), title: 'Expired', value: '0'),
      _CardData(color: Color(0xFFFACC15), title: 'Today Invoice', value: '3', darkText: true),
      _CardData(color: Color(0xFF7DD3FC), title: 'New Products', value: '4'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1200 ? 4 : (width >= 700 ? 2 : 1);
        final cardWidth = (width - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _ColorCard(
                    color: card.color,
                    title: card.title,
                    value: card.value,
                    darkText: card.darkText,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _CardData {
  const _CardData({
    required this.color,
    required this.title,
    required this.value,
    this.darkText = false,
  });

  final Color color;
  final String title;
  final String value;
  final bool darkText;
}

class _ColorCard extends StatelessWidget {
  const _ColorCard({
    required this.color,
    required this.title,
    required this.value,
    this.darkText = false,
  });

  final Color color;
  final String title;
  final String value;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final fg = darkText ? const Color(0xFF1A1D21) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final items = <(String, String)>[
      ('Suppliers', '4'),
      ('Invoices', '12'),
      ('Current Month Sales', '1,850,000đ'),
      ('Last 3 Month Record', '5,220,000đ'),
      ('Last 6 Month Record Sales', '9,100,000đ'),
      ('Users', '3'),
      ('Available Products', '4'),
      ('Current Year Revenue', '18,500,000đ'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: 290,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EAED)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ChartRow extends StatelessWidget {
  const _ChartRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width < 900) {
          return const Column(
            children: [
              _ChartCard(title: 'Sales Overview'),
              SizedBox(height: 16),
              _ChartCard(title: 'Top Selling Products'),
            ],
          );
        }
        return const Row(
          children: [
            Expanded(child: _ChartCard(title: 'Sales Overview')),
            SizedBox(width: 16),
            Expanded(child: _ChartCard(title: 'Top Selling Products')),
          ],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Chart Placeholder',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTable extends StatelessWidget {
  const _TransactionTable();

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              "Today's Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          DataTable(
            columns: const [
              DataColumn(label: Text('Order ID')),
              DataColumn(label: Text('Payment')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Attendant')),
              DataColumn(label: Text('Status')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Text('ORD-201')),
                DataCell(Text('Cash')),
                DataCell(Text('125,000đ')),
                DataCell(Text('John')),
                DataCell(Text('Paid')),
              ]),
              DataRow(cells: [
                DataCell(Text('ORD-202')),
                DataCell(Text('Transfer')),
                DataCell(Text('85,400đ')),
                DataCell(Text('Jane')),
                DataCell(Text('Paid')),
              ]),
              DataRow(cells: [
                DataCell(Text('ORD-203')),
                DataCell(Text('POS')),
                DataCell(Text('39,600đ')),
                DataCell(Text('John')),
                DataCell(Text('Pending')),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}
