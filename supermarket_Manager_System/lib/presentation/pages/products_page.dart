import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supermarket_manager_system/data/services/product_api_service.dart';
import 'package:supermarket_manager_system/domain/models/product_list_item.dart';

class ProductsContent extends StatefulWidget {
  const ProductsContent({
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
  State<ProductsContent> createState() => _ProductsContentState();
}

class _ProductsContentState extends State<ProductsContent> {
  final _productApiService = ProductApiService();
  late Future<List<ProductListItem>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productApiService.getProducts();
  }

  void _reloadProducts() {
    setState(() {
      _productsFuture = _productApiService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Column(
        children: [
          _ProductsHeader(
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
                        'Stock Inventory',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF4B5563),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Import Product',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF93C5FD),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                '+ Add New Product',
                                style: TextStyle(
                                  color: Color(0xFF1E40AF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<ProductListItem>>(
                      future: _productsFuture,
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
                                  'Cannot load products: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: _reloadProducts,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final products = snapshot.data ?? [];
                        if (products.isEmpty) {
                          return const Center(
                            child: Text('No products found'),
                          );
                        }

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
                              horizontalMargin: 16,
                              columnSpacing: 16,
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
                                    width: 110,
                                    child: Text('BARCODE'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 120,
                                    child: Text('PRODUCTS'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 100,
                                    child: Text('CATEGORY'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 110,
                                    child: Text('EXPIRE'),
                                  ),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: SizedBox(
                                    width: 90,
                                    child: Text('PRICE'),
                                  ),
                                ),
                                DataColumn(
                                  numeric: true,
                                  label: SizedBox(
                                    width: 80,
                                    child: Text('IN STOCK'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 110,
                                    child: Text('STATUS'),
                                  ),
                                ),
                                DataColumn(
                                  label: SizedBox(
                                    width: 200,
                                    child: Text('ACTIONS'),
                                  ),
                                ),
                              ],
                              rows: products.map(_buildRow).toList(),
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

  DataRow _buildRow(ProductListItem product) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 110,
            child: InkWell(
              onTap: product.id <= 0
                  ? null
                  : () => context.push(
                        '${_basePathFromLocation(context)}/product-detail/${product.id}',
                      ),
              child: Text(
                product.barcode.isEmpty ? '-' : product.barcode,
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 120,
            child: Text(
              product.productName.isEmpty ? '-' : product.productName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: Text(
              product.categoryName.isEmpty ? '-' : product.categoryName,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 110,
            child: Text(
              product.expiryDate.isEmpty ? '-' : product.expiryDate,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 90,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(product.sellingPrice.toStringAsFixed(2)),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(product.inStock.toString()),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 110,
            child: _StatusBadge(status: product.status),
          ),
        ),
        DataCell(
          SizedBox(
            width: 200,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    foregroundColor: const Color(0xFF667EEA),
                    side: const BorderSide(color: Color(0xFF667EEA)),
                  ),
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 6),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _basePathFromLocation(BuildContext context) {
  final loc = GoRouterState.of(context).uri.path;
  if (loc.startsWith('/manager')) return '/manager';
  return '/admin';
}

class _ProductsHeader extends StatelessWidget {
  const _ProductsHeader({
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
                  color: const Color(0xFF3B82F6),
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
                    fullName.isEmpty ? 'User' : fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    'Administrator',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final isInStock = normalized.contains('in');
    final bg = isInStock ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2);
    final fg = isInStock ? const Color(0xFF065F46) : const Color(0xFF991B1B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: bg,
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

