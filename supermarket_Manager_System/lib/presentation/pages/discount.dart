import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/discount_api_service.dart';
import 'package:supermarket_manager_system/domain/models/discount.dart';

class DiscountsContent extends StatefulWidget {
  const DiscountsContent({
    super.key,
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
  State<DiscountsContent> createState() => _DiscountsContentState();
}

class _DiscountsContentState extends State<DiscountsContent> {
  final _discountApiService = DiscountApiService();
  late Future<List<Discount>> _discountsFuture;

  @override
  void initState() {
    super.initState();
    _reloadDiscounts();
  }

  void _reloadDiscounts() {
    setState(() {
      _discountsFuture = _discountApiService.getDiscounts();
    });
  }

  Future<void> _openAddDiscountDialog() async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddEditDiscountDialog(discountApiService: _discountApiService),
    );

    if (mounted && created == true) {
      _reloadDiscounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount created successfully')),
      );
    }
  }

  Future<void> _openEditDiscountDialog(Discount discount) async {
    final updated = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddEditDiscountDialog(
        discountApiService: _discountApiService,
        discount: discount,
      ),
    );

    if (mounted && updated == true) {
      _reloadDiscounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount updated successfully')),
      );
    }
  }

  Future<void> _deleteDiscount(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this discount?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _discountApiService.deleteDiscount(id);
        _reloadDiscounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Discount deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting discount: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _DiscountsHeader(
            fullName: widget.fullName,
            isCompact: widget.isCompact,
            currentTimeText: widget.currentTimeText,
            onProfileTap: widget.onProfileTap,
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
                        'Discount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1D21),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFF16A34A),
                        ),
                        child: TextButton.icon(
                          onPressed: _openAddDiscountDialog,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Discount',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<Discount>>(
                      future: _discountsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }
                        final discounts = snapshot.data ?? [];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE8EAED)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: const WidgetStatePropertyAll(Color(0xFFF7F8FA)),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4A5568),
                                fontSize: 12,
                              ),
                              columns: const [
                                DataColumn(label: Text('S/N')),
                                DataColumn(label: Text('DISCOUNT NAME')),
                                DataColumn(label: Text('DISCOUNT %')),
                                DataColumn(label: Text('MIN ORDER AMOUNT')),
                                DataColumn(label: Text('START DATE')),
                                DataColumn(label: Text('END DATE')),
                                DataColumn(label: Text('ACTION')),
                              ],
                              rows: discounts.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final d = entry.value;
                                return DataRow(cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(Text(d.name)),
                                  DataCell(Text('${d.percent}%')),
                                  DataCell(Text('${d.minOrderAmount.toStringAsFixed(0)}đ')),
                                  DataCell(Text(_formatDate(d.startDate))),
                                  DataCell(Text(_formatDate(d.endDate))),
                                  DataCell(
                                    Row(
                                      children: [
                                        _ActionButton(
                                          label: 'Edit',
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                          ),
                                          onTap: () => _openEditDiscountDialog(d),
                                        ),
                                        const SizedBox(width: 8),
                                        _ActionButton(
                                          label: 'Delete',
                                          color: const Color(0xFFDC2626),
                                          onTap: () => _deleteDiscount(d.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _DiscountsHeader extends StatelessWidget {
  const _DiscountsHeader({
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
                child: Text(
                  currentTimeText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fullName.isEmpty ? 'Administrator' : fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Text('Administrator', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                ],
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onProfileTap,
                child: Container(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.color,
    this.gradient,
    required this.onTap,
  });

  final String label;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _AddEditDiscountDialog extends StatefulWidget {
  const _AddEditDiscountDialog({
    required this.discountApiService,
    this.discount,
  });

  final DiscountApiService discountApiService;
  final Discount? discount;

  @override
  State<_AddEditDiscountDialog> createState() => _AddEditDiscountDialogState();
}

class _AddEditDiscountDialogState extends State<_AddEditDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _percentController;
  late TextEditingController _minOrderController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.discount?.name ?? '');
    _percentController = TextEditingController(text: widget.discount?.percent.toString() ?? '');
    _minOrderController = TextEditingController(text: widget.discount?.minOrderAmount.toString() ?? '');
    _startDateController = TextEditingController(text: widget.discount != null ? _formatDate(widget.discount!.startDate) : '');
    _endDateController = TextEditingController(text: widget.discount != null ? _formatDate(widget.discount!.endDate) : '');
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = _formatDate(picked);
      });
    }
  }

  DateTime _parseDate(String text) {
    final parts = text.split('/');
    return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final newDiscount = Discount(
        id: widget.discount?.id ?? 0,
        name: _nameController.text.trim(),
        percent: double.parse(_percentController.text),
        minOrderAmount: double.parse(_minOrderController.text),
        startDate: _parseDate(_startDateController.text),
        endDate: _parseDate(_endDateController.text),
      );

      if (newDiscount.startDate.isAfter(newDiscount.endDate)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Start date must be before or equal to End date')),
          );
        }
        return;
      }

      if (widget.discount == null) {
        await widget.discountApiService.createDiscount(newDiscount);
      } else {
        await widget.discountApiService.updateDiscount(widget.discount!.id, newDiscount);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.discount == null ? 'Add Discount' : 'Edit Discount',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _buildTextField('Discount Name', _nameController, hint: 'e.g. Holiday Special'),
                const SizedBox(height: 12),
                _buildTextField('Discount %', _percentController, hint: 'e.g. 5', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextField('Min Order Amount (đ)', _minOrderController, hint: 'e.g. 500000', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildDateField('Start Date', _startDateController),
                const SizedBox(height: 12),
                _buildDateField('End Date', _endDateController),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(widget.discount == null ? 'Submit' : 'Update', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (label.contains('%')) {
              final val = double.tryParse(value);
              if (val == null) return 'Invalid number';
              if (val < 0 || val > 100) return 'Percent must be between 0 and 100';
            }
            if (label.contains('Amount')) {
              final val = double.tryParse(value);
              if (val == null) return 'Invalid number';
              if (val < 0) return 'Amount cannot be negative';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _selectDate(controller),
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.calendar_today, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }
}
