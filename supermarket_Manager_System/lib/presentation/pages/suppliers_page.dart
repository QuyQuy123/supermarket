import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/supplier_api_service.dart';
import 'package:supermarket_manager_system/domain/models/supplier_list_item.dart';

class SuppliersContent extends StatefulWidget {
  const SuppliersContent({
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
  State<SuppliersContent> createState() => _SuppliersContentState();
}

class _SuppliersContentState extends State<SuppliersContent> {
  final _supplierApiService = SupplierApiService();
  late Future<List<SupplierListItem>> _suppliersFuture;

  @override
  void initState() {
    super.initState();
    _suppliersFuture = _supplierApiService.getSuppliers();
  }

  void _reloadSuppliers() {
    setState(() {
      _suppliersFuture = _supplierApiService.getSuppliers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _SuppliersHeader(
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
                  const Text(
                    'List Supplier',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<SupplierListItem>>(
                      future: _suppliersFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cannot load suppliers: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _reloadSuppliers,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final suppliers = snapshot.data ?? [];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFE8EAED),
                            ),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              horizontalMargin: 20,
                              columnSpacing: 38,
                              headingRowColor: const WidgetStatePropertyAll(
                                Color(0xFFF7F8FA),
                              ),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A5568),
                                fontSize: 12,
                              ),
                              columns: const [
                                DataColumn(
                                  label: SizedBox(
                                    width: 28,
                                    child: Text('S/N'),
                                  ),
                                ),
                                DataColumn(label: Text('SUPPLIER NAME')),
                                DataColumn(label: Text('COMPANY')),
                                DataColumn(label: Text('EMAIL')),
                                DataColumn(label: Text('PHONE')),
                                DataColumn(label: Text('ADDRESS')),
                                DataColumn(label: Text('STATUS')),
                              ],
                              rows: suppliers
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => _buildRow(
                                      entry.key + 1,
                                      entry.value,
                                    ),
                                  )
                                  .toList(),
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

  DataRow _buildRow(int index, SupplierListItem supplier) {
    return DataRow(
      cells: [
        DataCell(SizedBox(width: 28, child: Text(index.toString()))),
        DataCell(Text(
          supplier.supplierName.isEmpty ? '-' : supplier.supplierName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        )),
        DataCell(Text(supplier.companyName.isEmpty ? '-' : supplier.companyName)),
        DataCell(Text(supplier.email.isEmpty ? '-' : supplier.email)),
        DataCell(Text(supplier.phone.isEmpty ? '-' : supplier.phone)),
        DataCell(Text(supplier.address.isEmpty ? '-' : supplier.address)),
        DataCell(_StatusChip(status: supplier.status)),
      ],
    );
  }
}

class _SuppliersHeader extends StatelessWidget {
  const _SuppliersHeader({
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA),
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
                  Text(fullName.isEmpty ? 'User' : fullName),
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
                    color: const Color(0xFF667EEA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
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
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

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
        status.isEmpty ? '-' : status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
