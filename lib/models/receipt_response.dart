class ReceiptResponse {
  final CostCalculation costCalculation;
  final List<Receipt> receipts;

  ReceiptResponse({required this.costCalculation, required this.receipts});

  factory ReceiptResponse.fromJson(Map<String, dynamic> json) {
    return ReceiptResponse(
      costCalculation: CostCalculation.fromJson(json['costCalculation']),
      receipts:
          (json['receipts'] as List)
              .map((receipt) => Receipt.fromJson(receipt))
              .toList(),
    );
  }
}

class CostCalculation {
  final String operation;
  final int? charactersIn;
  final int? charactersOut;
  final int? totalCharacters;
  final int? charactersPerPage;
  final int pages;
  final int pageCost;
  final int totalCost;

  CostCalculation({
    required this.operation,
    this.charactersIn,
    this.charactersOut,
    this.totalCharacters,
    this.charactersPerPage,
    required this.pages,
    required this.pageCost,
    required this.totalCost,
  });

  factory CostCalculation.fromJson(Map<String, dynamic> json) {
    return CostCalculation(
      operation: json['operation'],
      charactersIn: json['charactersIn'],
      charactersOut: json['charactersOut'],
      totalCharacters: json['totalCharacters'],
      charactersPerPage: json['charactersPerPage'],
      pages: json['pages'],
      pageCost: json['pageCost'],
      totalCost: json['totalCost'],
    );
  }
}

class Receipt {
  final ReceiptSummary summary;
  final List<ReceiptItem> items;

  Receipt({required this.summary, required this.items});

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      summary: ReceiptSummary.fromJson(json['summary']),
      items:
          (json['items'] as List)
              .map((item) => ReceiptItem.fromJson(item))
              .toList(),
    );
  }
}

class ReceiptSummary {
  final String invoiceReceiptDate;
  final String invoiceReceiptId;
  final String vendorName;
  final String vendorAddress;
  final String total;
  final String amountPaid;
  final String vendorVATNumber;
  final String vendorPhone;
  final String vendorURL;

  ReceiptSummary({
    required this.invoiceReceiptDate,
    required this.invoiceReceiptId,
    required this.vendorName,
    required this.vendorAddress,
    required this.total,
    required this.amountPaid,
    required this.vendorVATNumber,
    required this.vendorPhone,
    required this.vendorURL,
  });

  factory ReceiptSummary.fromJson(Map<String, dynamic> json) {
    return ReceiptSummary(
      invoiceReceiptDate: json['invoiceReceiptDate'] ?? '',
      invoiceReceiptId: json['invoiceReceiptId'] ?? '',
      vendorName: json['vendorName'] ?? '',
      vendorAddress: json['vendorAddress'] ?? '',
      total: json['total'] ?? '',
      amountPaid: json['amountPaid'] ?? '',
      vendorVATNumber: json['vendorVATNumber'] ?? '',
      vendorPhone: json['vendorPhone'] ?? '',
      vendorURL: json['vendorURL'] ?? '',
    );
  }
}

class ReceiptItem {
  final String item;
  final String price;
  final String expenseRow;
  final String quantity;
  final String other;
  final String unitPrice;

  ReceiptItem({
    required this.item,
    required this.price,
    required this.expenseRow,
    required this.quantity,
    required this.other,
    required this.unitPrice,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      item: json['item'] ?? '',
      price: json['price'] ?? '',
      expenseRow: json['expenseRow'] ?? '',
      quantity: json['quantity'] ?? '',
      other: json['other'] ?? '',
      unitPrice: json['unitPrice'] ?? '',
    );
  }
}
