class Voucher {
  final String id;
  final String voucherNumber;
  final String type; // 'receipt' or 'payment'
  final String partyType; // 'investor', 'customer', 'general'
  final String? entityId;
  final String partyName;
  final double amount;
  final String paymentMethod; // 'cash' or 'cheque'
  final String? chequeNumber;
  final String? bankName;
  final String purpose;
  final DateTime voucherDate;
  final DateTime? createdAt;

  Voucher({
    required this.id,
    required this.voucherNumber,
    required this.type,
    required this.partyType,
    this.entityId,
    required this.partyName,
    required this.amount,
    required this.paymentMethod,
    this.chequeNumber,
    this.bankName,
    required this.purpose,
    required this.voucherDate,
    this.createdAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id']?.toString() ?? '',
      voucherNumber: json['voucher_number']?.toString() ?? '',
      type: json['type']?.toString() ?? 'receipt',
      partyType: json['party_type']?.toString() ?? 'general',
      entityId: json['entity_id']?.toString(),
      partyName: json['party_name']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method']?.toString() ?? 'cash',
      chequeNumber: json['cheque_number']?.toString(),
      bankName: json['bank_name']?.toString(),
      purpose: json['purpose']?.toString() ?? '',
      voucherDate: json['voucher_date'] != null ? DateTime.tryParse(json['voucher_date'].toString()) ?? DateTime.now() : DateTime.now(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucher_number': voucherNumber,
      'type': type,
      'party_type': partyType,
      'entity_id': entityId,
      'party_name': partyName,
      'amount': amount,
      'payment_method': paymentMethod,
      'cheque_number': chequeNumber,
      'bank_name': bankName,
      'purpose': purpose,
      'voucher_date': voucherDate.toIso8601String().split('T').first,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
