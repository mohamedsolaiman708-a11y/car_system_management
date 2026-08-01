import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/providers/supabase_provider.dart';
import '../../domain/voucher.dart';

class SupabaseVoucherDataSource {
  final SupabaseClient _client;

  SupabaseVoucherDataSource(this._client);

  Future<Map<String, dynamic>> createVoucher({
    required String type, // 'receipt' or 'payment'
    required String partyType, // 'investor', 'customer', 'general'
    String? entityId,
    required String partyName,
    required double amount,
    required String paymentMethod, // 'cash' or 'cheque'
    String? chequeNumber,
    String? bankName,
    required String purpose,
    DateTime? voucherDate,
  }) async {
    final res = await _client.rpc('create_voucher_entry', params: {
      'p_type': type,
      'p_party_type': partyType,
      'p_entity_id': entityId,
      'p_party_name': partyName,
      'p_amount': amount,
      'p_payment_method': paymentMethod,
      'p_cheque_number': chequeNumber,
      'p_bank_name': bankName,
      'p_purpose': purpose,
      'p_voucher_date': (voucherDate ?? DateTime.now()).toIso8601String().split('T').first,
    });

    if (res is Map) {
      return Map<String, dynamic>.from(res);
    }
    return {'success': true};
  }

  Future<List<Voucher>> getVouchers({String? type}) async {
    var query = _client.from('vouchers').select();
    if (type != null) {
      query = query.eq('type', type);
    }
    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Voucher.fromJson(Map<String, dynamic>.from(json))).toList();
  }
}

final voucherDataSourceProvider = Provider<SupabaseVoucherDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseVoucherDataSource(client);
});

