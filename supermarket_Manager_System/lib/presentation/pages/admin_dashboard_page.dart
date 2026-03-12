import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/user_api_service.dart';
import 'package:supermarket_manager_system/domain/models/user_detail.dart';
import 'package:supermarket_manager_system/presentation/pages/login_page.dart';
import 'package:supermarket_manager_system/presentation/pages/users_page.dart';

enum _AdminTab { dashboard, users, profile, profileEdit }

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({
    super.key,
    required this.fullName,
    required this.userId,
  });

  final String fullName;
  final int userId;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  _AdminTab _selectedTab = _AdminTab.dashboard;
  UserDetail? _editingProfile;
  late DateTime _now;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
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

  void _selectTab(_AdminTab tab) {
    setState(() => _selectedTab = tab);
    final isCompact = MediaQuery.sizeOf(context).width < 1024;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  void _openProfileEdit(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _AdminTab.profileEdit;
    });
    final isCompact = MediaQuery.sizeOf(context).width < 1024;
    if (isCompact) {
      Navigator.of(context).maybePop();
    }
  }

  void _onProfileUpdated(UserDetail detail) {
    setState(() {
      _editingProfile = detail;
      _selectedTab = _AdminTab.profile;
    });
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

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  String _formatClock(DateTime dateTime) {
    final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    final amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute:$second $amPm';
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
                    onLogout: _logout,
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
                    onLogout: _logout,
                  ),
                ),
              Expanded(
                child: switch (_selectedTab) {
                  _AdminTab.dashboard => _DashboardContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_AdminTab.profile),
                    ),
                  _AdminTab.users => UsersContent(
                      fullName: widget.fullName,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onProfileTap: () => _selectTab(_AdminTab.profile),
                    ),
                  _AdminTab.profile => _ProfileContent(
                      fullName: widget.fullName,
                      userId: widget.userId,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onEditProfile: _openProfileEdit,
                    ),
                  _AdminTab.profileEdit => _ProfileEditContent(
                      userId: widget.userId,
                      initialDetail: _editingProfile,
                      isCompact: isCompact,
                      currentTimeText: _formatClock(_now),
                      onSaved: _onProfileUpdated,
                      onCancel: () => _selectTab(_AdminTab.profile),
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

class _SidebarMenu extends StatelessWidget {
  const _SidebarMenu({
    required this.selectedTab,
    required this.onSelectTab,
    required this.onLogout,
  });

  final _AdminTab selectedTab;
  final ValueChanged<_AdminTab> onSelectTab;
  final VoidCallback onLogout;

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
          _SidebarItem(
            label: 'Logout',
            onTap: onLogout,
          ),
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
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'A',
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

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({
    required this.fullName,
    required this.userId,
    required this.isCompact,
    required this.currentTimeText,
    required this.onEditProfile,
  });

  final String fullName;
  final int userId;
  final bool isCompact;
  final String currentTimeText;
  final ValueChanged<UserDetail> onEditProfile;

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _userApiService = UserApiService();
  late Future<UserDetail> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _userApiService.getUserDetail(widget.userId);
  }

  void _reloadProfile() {
    setState(() => _profileFuture = _userApiService.getUserDetail(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: FutureBuilder<UserDetail>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          final displayName = detail?.fullname.trim().isNotEmpty == true
              ? detail!.fullname
              : widget.fullName;
          return Column(
            children: [
              _ProfileHeader(
                fullName: displayName,
                isCompact: widget.isCompact,
                currentTimeText: widget.currentTimeText,
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || detail == null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 520),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8EAED)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Cannot load profile from database',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton(
                                  onPressed: _reloadProfile,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final twoColumns = constraints.maxWidth >= 980;
                          final leftCard = _ProfileInfoCard(detail: detail);
                          final rightCard = _ProfileSettingsCard(
                            detail: detail,
                            onEditProfile: () => widget.onEditProfile(detail),
                          );
                          if (!twoColumns) {
                            return Column(
                              children: [
                                leftCard,
                                const SizedBox(height: 16),
                                rightCard,
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: leftCard),
                              const SizedBox(width: 16),
                              Expanded(child: rightCard),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.fullName,
    required this.isCompact,
    required this.currentTimeText,
  });

  final String fullName;
  final bool isCompact;
  final String currentTimeText;

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
            const Text(
              'My Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
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
                  Text(fullName.isEmpty ? 'Administrator' : fullName),
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
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.detail});

  final UserDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    detail.fullname.isNotEmpty ? detail.fullname[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin ID - ${detail.id}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Text(
                  detail.fullname.isEmpty ? 'Administrator' : detail.fullname,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    detail.status.isEmpty ? 'Unknown' : detail.status,
                    style: TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _ProfileBullet(text: detail.phone.isEmpty ? 'Phone: N/A' : detail.phone),
          _ProfileBullet(text: detail.email.isEmpty ? 'Email: N/A' : detail.email),
          _ProfileBullet(text: detail.idCard.isEmpty ? 'ID Card: N/A' : detail.idCard),
          _ProfileBullet(text: detail.dob.isEmpty ? 'DOB: N/A' : 'DOB: ${detail.dob}'),
          _ProfileBullet(text: detail.address.isEmpty ? 'Address: N/A' : detail.address),
          _ProfileBullet(text: detail.role.isEmpty ? 'Role: N/A' : detail.role),
          const SizedBox(height: 20),
          const Text(
            'Authentication Details',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Divider(color: Color(0xFFE2E8F0)),
          _AuthDetailRow(label: 'User Name :', value: detail.username),
          _AuthDetailRow(
            label: 'Last Login:',
            value: detail.lastLogin,
          ),
          const _AuthDetailRow(label: 'Registered:', value: '—'),
        ],
      ),
    );
  }
}

class _ProfileBullet extends StatelessWidget {
  const _ProfileBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF334155),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _AuthDetailRow extends StatelessWidget {
  const _AuthDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsCard extends StatelessWidget {
  const _ProfileSettingsCard({
    required this.detail,
    required this.onEditProfile,
  });

  final UserDetail detail;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EAED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Settings',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          const _ProfileInputLabel('Email'),
          const SizedBox(height: 6),
          _ProfileTextField(initialValue: detail.email, readOnly: true),
          const SizedBox(height: 14),
          const _ProfileInputLabel('Phone *'),
          const SizedBox(height: 6),
          _ProfileTextField(initialValue: detail.phone, hintText: 'Enter phone', readOnly: true),
          const SizedBox(height: 14),
          const _ProfileInputLabel('ID Card Number'),
          const SizedBox(height: 6),
          _ProfileTextField(initialValue: detail.idCard, hintText: 'Enter ID card number', readOnly: true),
          const SizedBox(height: 14),
          const _ProfileInputLabel('Date Of Birth'),
          const SizedBox(height: 6),
          _ProfileTextField(initialValue: detail.dob, hintText: 'yyyy-MM-dd', readOnly: true),
          const SizedBox(height: 14),
          const _ProfileInputLabel('Address'),
          const SizedBox(height: 6),
          _ProfileTextField(
            initialValue: detail.address,
            hintText: 'Sample address',
            maxLines: 4,
            readOnly: true,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onEditProfile,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Update Profile',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B7280),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'Change Password',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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

class _ProfileEditContent extends StatefulWidget {
  const _ProfileEditContent({
    required this.userId,
    required this.initialDetail,
    required this.isCompact,
    required this.currentTimeText,
    required this.onSaved,
    required this.onCancel,
  });

  final int userId;
  final UserDetail? initialDetail;
  final bool isCompact;
  final String currentTimeText;
  final ValueChanged<UserDetail> onSaved;
  final VoidCallback onCancel;

  @override
  State<_ProfileEditContent> createState() => _ProfileEditContentState();
}

class _ProfileEditContentState extends State<_ProfileEditContent> {
  final _formKey = GlobalKey<FormState>();
  final _userApiService = UserApiService();

  late final TextEditingController _fullnameController;
  late final TextEditingController _emailController;
  late final TextEditingController _idCardController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _dobController;
  bool _isSaving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final detail = widget.initialDetail;
    _fullnameController = TextEditingController(text: detail?.fullname ?? '');
    _emailController = TextEditingController(text: detail?.email ?? '');
    _idCardController = TextEditingController(text: detail?.idCard ?? '');
    _phoneController = TextEditingController(text: detail?.phone ?? '');
    _addressController = TextEditingController(text: detail?.address ?? '');
    _dobController = TextEditingController(text: detail?.dob ?? '');
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _idCardController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    try {
      final updated = await _userApiService.updateProfile(
        userId: widget.userId,
        fullname: _fullnameController.text.trim(),
        email: _emailController.text.trim(),
        idCard: _idCardController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        dob: _dobController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      widget.onSaved(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _fullnameController.text.trim().isEmpty
        ? 'Administrator'
        : _fullnameController.text.trim();
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _ProfileHeader(
            fullName: displayName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8EAED)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          const _ProfileInputLabel('Fullname'),
                          const SizedBox(height: 6),
                          _ProfileEditableField(
                            controller: _fullnameController,
                            enabled: !_isSaving,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty) ? 'Fullname is required' : null,
                          ),
                          const SizedBox(height: 14),
                          const _ProfileInputLabel('Email'),
                          const SizedBox(height: 6),
                          _ProfileEditableField(
                            controller: _emailController,
                            enabled: !_isSaving,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Email is invalid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          const _ProfileInputLabel('ID Card Number'),
                          const SizedBox(height: 6),
                          _ProfileEditableField(
                            controller: _idCardController,
                            enabled: !_isSaving,
                          ),
                          const SizedBox(height: 14),
                          const _ProfileInputLabel('Phone'),
                          const SizedBox(height: 6),
                          _ProfileEditableField(
                            controller: _phoneController,
                            enabled: !_isSaving,
                          ),
                          const SizedBox(height: 14),
                          const _ProfileInputLabel('Date Of Birth (yyyy-MM-dd)'),
                          const SizedBox(height: 6),
                          _ProfileEditableField(
                            controller: _dobController,
                            enabled: !_isSaving,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }
                              final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                              if (!pattern.hasMatch(value.trim())) {
                                return 'DOB must be yyyy-MM-dd';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          const _ProfileInputLabel('Address'),
                          const SizedBox(height: 6),
                          _ProfileEditableField(
                            controller: _addressController,
                            enabled: !_isSaving,
                            maxLines: 4,
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 14),
                            Text(
                              _errorText!,
                              style: const TextStyle(color: Color(0xFFB91C1C)),
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _isSaving ? null : widget.onCancel,
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _isSaving ? null : _submit,
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInputLabel extends StatelessWidget {
  const _ProfileInputLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF475569),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProfileEditableField extends StatelessWidget {
  const _ProfileEditableField({
    required this.controller,
    this.enabled = true,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final bool enabled;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.initialValue,
    this.hintText,
    this.readOnly = false,
    this.maxLines = 1,
  });

  final String initialValue;
  final String? hintText;
  final bool readOnly;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD5DCE5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
        ),
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
