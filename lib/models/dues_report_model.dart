class DuesReportItem {
  final String memberName;
  final String unitNumber;
  final String buildingName;
  final String billCycle;
  final double billAmount;
  final double amountPaid;
  final double dueAmount;
  final DateTime dueDate;
  final DateTime? lastPaymentDate;

  DuesReportItem({
    required this.memberName,
    required this.unitNumber,
    required this.buildingName,
    required this.billCycle,
    required this.billAmount,
    required this.amountPaid,
    required this.dueAmount,
    required this.dueDate,
    this.lastPaymentDate,
  });

  factory DuesReportItem.fromJson(Map<String, dynamic> json) {
    return DuesReportItem(
      memberName: json['member_name'] ?? '',
      unitNumber: json['unit_number'] ?? '',
      buildingName: json['building_name'] ?? '',
      billCycle: json['bill_cycle'] ?? '',
      billAmount: (json['bill_amount'] ?? 0).toDouble(),
      amountPaid: (json['amount_paid'] ?? 0).toDouble(),
      dueAmount: (json['due_amount'] ?? 0).toDouble(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'])
          : DateTime.now(),
      lastPaymentDate: json['last_payment_date'] != null
          ? DateTime.parse(json['last_payment_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_name': memberName,
      'unit_number': unitNumber,
      'building_name': buildingName,
      'bill_cycle': billCycle,
      'bill_amount': billAmount,
      'amount_paid': amountPaid,
      'due_amount': dueAmount,
      'due_date': dueDate.toIso8601String(),
      'last_payment_date':
          lastPaymentDate != null ? lastPaymentDate!.toIso8601String() : null,
    };
  }
}
