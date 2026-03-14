import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';
import 'package:supermarket_manager_system/presentation/pages/orders_page.dart';
import 'package:supermarket_manager_system/presentation/pages/profile_content_page.dart';

enum _ManagerTab { dashboard, orders, profile, profileEdit }

class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({
    super.key,
    required this.fullName,
    required this.userId,
    required this.initialTabKey,
    this.onNavigatePath,
    this.onLogoutRequested,
  });

  final String fullName;
  final int userId;
  final String initialTabKey;
  final ValueChanged<String>? onNavigatePath;
  final VoidCallback? onLogoutRequested;

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  _ManagerTab _selectedTab = _ManagerTab.dashboard;
  UserDetail? _editingProfile;
  late DateTime _now;
  Timer? _clockTimer;

  _ManagerTab _tabFromKey(String key) {
    return switch (key) {
      'profile' => _ManagerTab.profile,
      'orders' => _ManagerTab.orders,
      'profile-edit' => _ManagerTab.profileEdit,
      _ => _ManagerTab.dashboard,
    };
  }

  String _pathForTab(_ManagerTab tab) {
    return switch (tab) {
      _ManagerTab.dashboard => '/manager/dashboard',
      _ManagerTab.orders => '/manager/orders',
      _ManagerTab.profile => '/manager/profile',
      _ManagerTab.profileEdit => '/manager/profile/edit',
    };
  }

  @override
  void initState() {
    super.initState();
    _selectedTab = _tabFromKey(widget.initialTabKey);
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ManagerDashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabKey != oldWidget.initialTabKey) {
      _selectedTab = _tabFromKey(widget.initialTabKey);
    }
  }

  String _formatClock(DateTime dateTime) {
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute:$second $amPm';
  }

  void _selectTab(_ManagerTab tab, {bool notifyRouter = true}) {
    setState(() => _selectedTab = tab);
    if (notifyRouter) {
      widget.onNavigatePath?.call(_pathForTab(tab));
    }
    final isCompact = MediaQuery.sizeOf(context).width < 1024;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  void _openProfileEdit(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _ManagerTab.profileEdit;
    });
    widget.onNavigatePath?.call(_pathForTab(_ManagerTab.profileEdit));
  }

  void _onProfileUpdated(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _ManagerTab.profile;
    });
    widget.onNavigatePath?.call(_pathForTab(_ManagerTab.profile));
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }
    widget.onLogoutRequested?.call();
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
                  child: _ManagerSidebar(
                    onLogout: _logout,
                    selectedTab: _selectedTab,
                    onDashboardTap: () => _selectTab(_ManagerTab.dashboard),
                    onOrdersTap: () => _selectTab(_ManagerTab.orders),
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!isCompact)
                SizedBox(
                  width: 230,
                  child: _ManagerSidebar(
                    onLogout: _logout,
                    selectedTab: _selectedTab,
                    onDashboardTap: () => _selectTab(_ManagerTab.dashboard),
                    onOrdersTap: () => _selectTab(_ManagerTab.orders),
                  ),
                ),
              Expanded(
                child: switch (_selectedTab) {
                  _ManagerTab.dashboard => Container(
                      color: const Color(0xFFF0F2F5),
                      child: Column(
                        children: [
                          _ManagerHeader(
                            fullName: widget.fullName,
                            isCompact: isCompact,
                            currentTimeText: _formatClock(_now),
                            onAvatarTap: () => _selectTab(_ManagerTab.profile),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(24),
                              children: const [
                                _ManagerTopCards(),
                                SizedBox(height: 16),
                                _ManagerStatsGrid(),
                                SizedBox(height: 16),
                                _ManagerChartRow(),
                                SizedBox(height: 16),
                                _ManagerTransactionsTable(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  _ManagerTab.orders => OrdersContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      roleLabel: 'Manager',
                      onProfileTap: () => _selectTab(_ManagerTab.profile),
                    ),
                  _ManagerTab.profile => ProfileViewContent(
                      fullName: widget.fullName,
                      userId: widget.userId,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onEditProfile: _openProfileEdit,
                    ),
                  _ManagerTab.profileEdit => ProfileEditContent(
                      userId: widget.userId,
                      initialDetail: _editingProfile,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onSaved: _onProfileUpdated,
                      onCancel: () => _selectTab(_ManagerTab.profile),
                    ),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ManagerSidebar extends StatelessWidget {
  const _ManagerSidebar({
    required this.onLogout,
    required this.selectedTab,
    required this.onDashboardTap,
    required this.onOrdersTap,
  });

  final VoidCallback onLogout;
  final _ManagerTab selectedTab;
  final VoidCallback onDashboardTap;
  final VoidCallback onOrdersTap;

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
                _ManagerLogo(),
                SizedBox(width: 10),
                Text(
                  'SMS SYSTEM',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                    _ManagerSidebarItem(
                      label: 'Dashboard',
                      active: selectedTab == _ManagerTab.dashboard,
                      onTap: onDashboardTap,
                    ),
                    _ManagerSidebarItem(
                      label: 'Orders',
                      active: selectedTab == _ManagerTab.orders,
                      onTap: onOrdersTap,
                    ),
                    const _ManagerSidebarItem(label: 'Suppliers'),
                    const _ManagerSidebarItem(label: 'Category'),
                    const _ManagerSidebarItem(label: 'Products'),
                    const _ManagerSidebarItem(label: 'Creditors'),
                    const _ManagerSidebarItem(label: 'Expired'),
                    const _ManagerSidebarItem(label: 'Reports'),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: Color.fromRGBO(255, 255, 255, 0.25), height: 1),
          _ManagerSidebarItem(label: 'Logout', onTap: onLogout),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ManagerHeader extends StatelessWidget {
  const _ManagerHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
    required this.onAvatarTap,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;
  final VoidCallback onAvatarTap;

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
                  color: const Color(0xFF16A34A),
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
                  Text(fullName.isEmpty ? 'Manager' : fullName),
                  const Text(
                    'Manager',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onAvatarTap,
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
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'M',
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

class _ManagerLogo extends StatelessWidget {
  const _ManagerLogo();

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
        style: TextStyle(color: Color(0xFF667EEA), fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ManagerSidebarItem extends StatelessWidget {
  const _ManagerSidebarItem({
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
          left: BorderSide(color: active ? Colors.white : Colors.transparent, width: 3),
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

class _ManagerTopCards extends StatelessWidget {
  const _ManagerTopCards();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _ManagerCardData(color: Color(0xFF16A34A), title: 'Today Sales', value: '250,000đ'),
      _ManagerCardData(color: Color(0xFFF472B6), title: 'Expired', value: '0'),
      _ManagerCardData(color: Color(0xFFFACC15), title: 'Today Invoice', value: '3', darkText: true),
      _ManagerCardData(color: Color(0xFF7DD3FC), title: 'New Products', value: '4'),
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
              .map((card) => SizedBox(width: cardWidth, child: _ManagerColorCard(data: card)))
              .toList(),
        );
      },
    );
  }
}

class _ManagerCardData {
  const _ManagerCardData({
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

class _ManagerColorCard extends StatelessWidget {
  const _ManagerColorCard({required this.data});

  final _ManagerCardData data;

  @override
  Widget build(BuildContext context) {
    final fg = data.darkText ? const Color(0xFF1A1D21) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: data.color, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 22),
          ),
        ],
      ),
    );
  }
}

class _ManagerStatsGrid extends StatelessWidget {
  const _ManagerStatsGrid();

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

class _ManagerChartRow extends StatelessWidget {
  const _ManagerChartRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return const Column(
            children: [
              _ManagerChartCard(title: 'Sales Overview'),
              SizedBox(height: 16),
              _ManagerChartCard(title: 'Top Selling Products'),
            ],
          );
        }
        return const Row(
          children: [
            Expanded(child: _ManagerChartCard(title: 'Sales Overview')),
            SizedBox(width: 16),
            Expanded(child: _ManagerChartCard(title: 'Top Selling Products')),
          ],
        );
      },
    );
  }
}

class _ManagerChartCard extends StatelessWidget {
  const _ManagerChartCard({required this.title});

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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FA),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text('Chart Placeholder', style: TextStyle(color: Color(0xFF6B7280))),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagerTransactionsTable extends StatelessWidget {
  const _ManagerTransactionsTable();

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
            child: Text("Today's Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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

