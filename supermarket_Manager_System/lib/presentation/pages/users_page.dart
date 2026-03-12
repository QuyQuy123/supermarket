import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/user_api_service.dart';
import 'package:supermarket_manager_system/domain/models/role_option.dart';
import 'package:supermarket_manager_system/domain/models/user_list_item.dart';
import 'package:supermarket_manager_system/presentation/pages/user_detail_page.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({
    super.key,
    required this.fullName,
    required this.isCompact,
  });

  final String fullName;
  final bool isCompact;

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final _userApiService = UserApiService();
  late Future<List<UserListItem>> _usersFuture;
  int? _selectedUserId;
  int? _statusLoadingUserId;

  @override
  void initState() {
    super.initState();
    _usersFuture = _userApiService.getUsers();
  }

  void _reloadUsers() {
    setState(() {
      _usersFuture = _userApiService.getUsers();
    });
  }

  Future<void> _openAddUserDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddUserDialog(userApiService: _userApiService),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      _reloadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _UsersHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedUserId == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'User Information',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                          ),
                          child: TextButton(
                            onPressed: _openAddUserDialog,
                            child: const Text(
                              '+ Add User',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _selectedUserId == null
                        ? FutureBuilder<List<UserListItem>>(
                            future: _usersFuture,
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
                                        'Cannot load users: ${snapshot.error}',
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _reloadUsers,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              final users = snapshot.data ?? [];
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
                                    columnSpacing: 38,
                                    headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7F8FA)),
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4A5568),
                                      fontSize: 12,
                                    ),
                                    columns: const [
                                      DataColumn(label: SizedBox(width: 28, child: Text('S/N'))),
                                      DataColumn(label: Text('NAME')),
                                      DataColumn(label: Text('USERNAME')),
                                      DataColumn(label: Text('E-MAIL')),
                                      DataColumn(label: Text('ROLE')),
                                      DataColumn(label: Text('STATUS')),
                                      DataColumn(label: Text('ID CARD')),
                                      DataColumn(label: Text('ACTIONS')),
                                    ],
                                    rows: users
                                        .asMap()
                                        .entries
                                        .map((entry) => _buildRow(entry.key + 1, entry.value))
                                        .toList(),
                                  ),
                                ),
                              );
                            },
                          )
                        : UserDetailContent(
                            userId: _selectedUserId!,
                            onBack: () => setState(() => _selectedUserId = null),
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

  DataRow _buildRow(int index, UserListItem user) {
    return DataRow(
      cells: [
        DataCell(SizedBox(width: 28, child: Text(index.toString()))),
        DataCell(
          Text(
            user.fullname.isEmpty ? '-' : user.fullname,
            style: const TextStyle(
              color: Color(0xFF667EEA),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        DataCell(Text(user.username)),
        DataCell(Text(user.email)),
        DataCell(_RoleBadge(role: user.role)),
        DataCell(_StatusBadge(status: user.status)),
        DataCell(Text(user.idCard.isEmpty ? '-' : user.idCard)),
        DataCell(
          Row(
            children: [
              _ActionButton(
                label: 'Details',
                color: const Color(0xFF14B8A6),
                onTap: () => _openUserDetails(user.id),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Edit',
                color: const Color(0xFF667EEA),
                onTap: () => _openEditUserDialog(user),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: _statusLoadingUserId == user.id
                    ? '...'
                    : (_isActiveStatus(user.status) ? 'Active' : 'Deactive'),
                color: _isActiveStatus(user.status)
                    ? const Color(0xFF14B8A6)
                    : const Color(0xFFDC2626),
                onTap: _statusLoadingUserId == user.id
                    ? () {}
                    : () => _confirmToggleUserStatus(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openUserDetails(int userId) {
    setState(() => _selectedUserId = userId);
  }

  Future<void> _openEditUserDialog(UserListItem user) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditUserDialog(
        userApiService: _userApiService,
        user: user,
      ),
    );

    if (!mounted) {
      return;
    }

    if (updated == true) {
      _reloadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully')),
      );
    }
  }

  Future<void> _confirmToggleUserStatus(UserListItem user) async {
    final targetStatus = _isActiveStatus(user.status) ? 'deactive' : 'active';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Status Change'),
          content: Text(
            'Are you sure you want to change ${user.username} status to ${targetStatus.toUpperCase()}?',
          ),
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

    if (confirmed == true) {
      await _toggleUserStatus(user);
    }
  }

  Future<void> _toggleUserStatus(UserListItem user) async {
    final targetStatus = _isActiveStatus(user.status) ? 'deactive' : 'active';
    setState(() => _statusLoadingUserId = user.id);
    try {
      await _userApiService.updateUserStatus(
        userId: user.id,
        status: targetStatus,
      );
      if (!mounted) {
        return;
      }
      _reloadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User status updated to $targetStatus')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _statusLoadingUserId = null);
      }
    }
  }

  bool _isActiveStatus(String status) => status.trim().toLowerCase() == 'active';
}

class _UsersHeader extends StatelessWidget {
  const _UsersHeader({
    required this.fullName,
    required this.isCompact,
  });

  final String fullName;
  final bool isCompact;

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
                  color: const Color(0xFF667EEA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('11:14:36 AM', style: TextStyle(color: Colors.white)),
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
                  color: const Color(0xFF667EEA),
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

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final isAdmin = role.toLowerCase().contains('admin');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isAdmin ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
      ),
      child: Text(
        role.isEmpty ? 'Unknown' : role,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isAdmin ? const Color(0xFF065F46) : const Color(0xFF92400E),
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
    final normalized = status.toLowerCase();
    final isActive = normalized == 'active';
    final bg = isActive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final fg = isActive ? const Color(0xFF065F46) : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bg,
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog({required this.userApiService});

  final UserApiService userApiService;

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _idCardController = TextEditingController();

  String _selectedRole = '';
  bool _showPassword = false;
  bool _isSubmitting = false;
  bool _isLoadingRoles = true;
  List<RoleOption> _roles = const [];
  String? _errorText;
  String? _rolesErrorText;

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _rolesErrorText = null;
    });
    try {
      final roles = await widget.userApiService.getRoles();
      if (!mounted) {
        return;
      }
      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRoles = false;
        _rolesErrorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    if (_isLoadingRoles) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.userApiService.createUser(
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        idCard: _idCardController.text.trim(),
        userRole: _selectedRole,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() {
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 16, 10, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0x33FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Create User Account',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x33FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildSectionTitle('Basic Information'),
                      _buildTextField(
                        controller: _fullnameController,
                        label: 'Fullname',
                        hint: 'Enter name',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Fullname is required' : null,
                      ),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Enter username',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                      ),
                      _buildTextField(
                        controller: _emailController,
                        label: 'e-Mail',
                        hint: 'Enter e-mail...',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@')) {
                            return 'Email is invalid';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: 'Enter password',
                        obscureText: !_showPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _showPassword,
                              onChanged: _isSubmitting
                                  ? null
                                  : (value) => setState(() => _showPassword = value ?? false),
                            ),
                            const Text('Show password'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSectionTitle('Optional Information'),
                      _buildTextField(
                        controller: _idCardController,
                        label: 'ID Card (optional)',
                        hint: 'Enter ID card (optional)',
                      ),
                      if (_isLoadingRoles)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: LinearProgressIndicator(),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole.isEmpty ? null : _selectedRole,
                          items: _roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role.name,
                                  child: Text(_formatRoleLabel(role.name)),
                                ),
                              )
                              .toList(),
                          onChanged: (_isSubmitting || _roles.isEmpty)
                              ? null
                              : (value) => setState(() => _selectedRole = value ?? ''),
                          decoration: _inputDecoration('User Role', 'Choose User Role..'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'User role is required' : null,
                        ),
                      if (_rolesErrorText != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _rolesErrorText!,
                                style: const TextStyle(color: Color(0xFFB91C1C)),
                              ),
                            ),
                            TextButton(
                              onPressed: _isSubmitting ? null : _loadRoles,
                              child: const Text('Retry roles'),
                            ),
                          ],
                        ),
                      ],
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: const TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFBFC),
                    border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB91C1C),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Dismiss'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_isSubmitting || _isLoadingRoles || _roles.isEmpty) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14B8A6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Create'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: !_isSubmitting,
        decoration: _inputDecoration(label, hint),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF14B8A6)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRoleLabel(String roleName) {
    if (roleName.isEmpty) {
      return '';
    }
    final lower = roleName.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}

class _EditUserDialog extends StatefulWidget {
  const _EditUserDialog({
    required this.userApiService,
    required this.user,
  });

  final UserApiService userApiService;
  final UserListItem user;

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullnameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _idCardController;

  String _selectedRole = '';
  bool _showPassword = false;
  bool _isSubmitting = false;
  bool _isLoadingRoles = true;
  List<RoleOption> _roles = const [];
  String? _errorText;
  String? _rolesErrorText;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.user.fullname);
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController();
    _idCardController = TextEditingController(text: widget.user.idCard);
    _loadRoles();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _idCardController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    setState(() {
      _isLoadingRoles = true;
      _rolesErrorText = null;
    });
    try {
      final roles = await widget.userApiService.getRoles();
      if (!mounted) {
        return;
      }
      String selected = '';
      for (final role in roles) {
        if (role.name.toLowerCase() == widget.user.role.toLowerCase()) {
          selected = role.name;
          break;
        }
      }
      setState(() {
        _roles = roles;
        _selectedRole = selected;
        _isLoadingRoles = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRoles = false;
        _rolesErrorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _submit() async {
    if (_isLoadingRoles) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.userApiService.updateUser(
        userId: widget.user.id,
        fullname: _fullnameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        userRole: _selectedRole,
        idCard: _idCardController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() {
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 16, 10, 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0x33FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit_note, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Update User Account',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x33FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildSectionTitle('Basic Information'),
                      _buildTextField(
                        controller: _fullnameController,
                        label: 'Fullname',
                        hint: 'Enter name',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Fullname is required' : null,
                      ),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        hint: 'Enter username',
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Username is required' : null,
                      ),
                      _buildTextField(
                        controller: _emailController,
                        label: 'e-Mail',
                        hint: 'Enter e-mail...',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!v.contains('@')) {
                            return 'Email is invalid';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password (optional)',
                        hint: 'Leave blank to keep current',
                        obscureText: !_showPassword,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return null;
                          }
                          if (v.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _showPassword,
                              onChanged: _isSubmitting
                                  ? null
                                  : (value) => setState(() => _showPassword = value ?? false),
                            ),
                            const Text('Show password'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildSectionTitle('Optional Information'),
                      _buildTextField(
                        controller: _idCardController,
                        label: 'ID Card (optional)',
                        hint: 'Enter ID card (optional)',
                      ),
                      if (_isLoadingRoles)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: LinearProgressIndicator(),
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRole.isEmpty ? null : _selectedRole,
                          items: _roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role.name,
                                  child: Text(_formatRoleLabel(role.name)),
                                ),
                              )
                              .toList(),
                          onChanged: (_isSubmitting || _roles.isEmpty)
                              ? null
                              : (value) => setState(() => _selectedRole = value ?? ''),
                          decoration: _inputDecoration('User Role', 'Choose User Role..'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'User role is required' : null,
                        ),
                      if (_rolesErrorText != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _rolesErrorText!,
                                style: const TextStyle(color: Color(0xFFB91C1C)),
                              ),
                            ),
                            TextButton(
                              onPressed: _isSubmitting ? null : _loadRoles,
                              child: const Text('Retry roles'),
                            ),
                          ],
                        ),
                      ],
                      if (_errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorText!,
                          style: const TextStyle(color: Color(0xFFB91C1C)),
                        ),
                      ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFAFBFC),
                    border: Border(top: BorderSide(color: Color(0xFFE8EAED))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB91C1C),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: (_isSubmitting || _isLoadingRoles || _roles.isEmpty) ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14B8A6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: !_isSubmitting,
        decoration: _inputDecoration(label, hint),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF14B8A6)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _formatRoleLabel(String roleName) {
    if (roleName.isEmpty) {
      return '';
    }
    final lower = roleName.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
