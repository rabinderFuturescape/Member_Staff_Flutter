class DuesChartItem {
  final String label;
  final double totalDue;

  DuesChartItem({
    required this.label,
    required this.totalDue,
  });

  factory DuesChartItem.fromJson(Map<String, dynamic> json) {
    return DuesChartItem(
      label: json['label'] ?? '',
      totalDue: (json['total_due'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'total_due': totalDue,
    };
  }
}
