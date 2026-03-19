class UpdateProductRequest {
  const UpdateProductRequest({
    this.productBatch,
    required this.productName,
    this.description,
    this.costPrice,
    required this.sellingPrice,
    this.qtyCartons,
    this.supplierId,
    this.categoryId,
    this.mftDate,
    this.expiryDate,
    this.imageUrl,
  });

  final String? productBatch;
  final String productName;
  final String? description;
  final double? costPrice;
  final double sellingPrice;
  final int? qtyCartons;
  final int? supplierId;
  final int? categoryId;
  final String? mftDate;
  final String? expiryDate;
  final String? imageUrl;

  Map<String, dynamic> toJson() {
    return {
      if (productBatch != null && productBatch!.isNotEmpty) 'productBatch': productBatch,
      'productName': productName,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (costPrice != null) 'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      if (qtyCartons != null) 'qtyCartons': qtyCartons,
      if (supplierId != null) 'supplierId': supplierId,
      if (categoryId != null) 'categoryId': categoryId,
      if (mftDate != null && mftDate!.isNotEmpty) 'mftDate': mftDate,
      if (expiryDate != null && expiryDate!.isNotEmpty) 'expiryDate': expiryDate,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
    };
  }
}
