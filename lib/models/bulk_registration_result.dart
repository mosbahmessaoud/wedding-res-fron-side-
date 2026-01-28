class BulkRegistrationResult {
  final int totalRows;
  final int successful;
  final int skipped;
  final int failed;
  final List<RegistrationDetail> details;

  BulkRegistrationResult({
    required this.totalRows,
    required this.successful,
    required this.skipped,
    required this.failed,
    required this.details,
  });

  factory BulkRegistrationResult.fromJson(Map<String, dynamic> json) {
    return BulkRegistrationResult(
      totalRows: json['total_rows'],
      successful: json['successful'],
      skipped: json['skipped'],
      failed: json['failed'],
      details: (json['details'] as List)
          .map((detail) => RegistrationDetail.fromJson(detail))
          .toList(),
    );
  }
}
class RegistrationDetail {
  final int row;
  final String? phone;
  final String status;
  final String? name;
  final String? reason;

  RegistrationDetail({
    required this.row,
    this.phone,
    required this.status,
    this.name,
    this.reason,
  });

  factory RegistrationDetail.fromJson(Map<String, dynamic> json) {
    return RegistrationDetail(
      row: json['row'],
      phone: json['phone'],
      status: json['status'],
      name: json['name'],
      reason: json['reason'],
    );
  }

  bool get isSuccess => status == 'success';
  bool get isSkipped => status == 'skipped';
  bool get isFailed => status == 'failed';
  bool get hasReservation => reason == 'مع حجز';
}