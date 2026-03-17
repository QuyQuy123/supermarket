class DashboardSummary {
  final double todaySales;
  final int expiredProducts;
  final int todayInvoiceCount;
  final int newProductsCount;
  final int supplierCount;
  final int invoiceCount;
  final double currentMonthSales;
  final double last3MonthSales;
  final double last6MonthSales;
  final int userCount;
  final int availableProductsCount;
  final double currentYearRevenue;

  DashboardSummary({
    required this.todaySales,
    required this.expiredProducts,
    required this.todayInvoiceCount,
    required this.newProductsCount,
    required this.supplierCount,
    required this.invoiceCount,
    required this.currentMonthSales,
    required this.last3MonthSales,
    required this.last6MonthSales,
    required this.userCount,
    required this.availableProductsCount,
    required this.currentYearRevenue,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      todaySales: _toDouble(json['todaySales']),
      expiredProducts: _toInt(json['expiredProducts']),
      todayInvoiceCount: _toInt(json['todayInvoiceCount']),
      newProductsCount: _toInt(json['newProductsCount']),
      supplierCount: _toInt(json['supplierCount']),
      invoiceCount: _toInt(json['invoiceCount']),
      currentMonthSales: _toDouble(json['currentMonthSales']),
      last3MonthSales: _toDouble(json['last3MonthSales']),
      last6MonthSales: _toDouble(json['last6MonthSales']),
      userCount: _toInt(json['userCount']),
      availableProductsCount: _toInt(json['availableProductsCount']),
      currentYearRevenue: _toDouble(json['currentYearRevenue']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
