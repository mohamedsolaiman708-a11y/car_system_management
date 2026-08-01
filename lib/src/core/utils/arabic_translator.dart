/// Utility class for translating database-stored English strings to Arabic.
class ArabicTranslator {
  static const Map<String, String> _accountNames = {
    'Cash at Bank': 'نقد في البنك',
    'Investors Capital': 'رأس مال المستثمرين',
    'Profit Payable': 'أرباح مستحقة الدفع',
    'Accounts Receivable': 'ذمم مدينة',
    'Accounts Payable': 'ذمم دائنة',
    'Revenue': 'الإيرادات',
    'Cost of Revenue': 'تكلفة الإيرادات',
    'Operating Expenses': 'المصروفات التشغيلية',
    'Retained Earnings': 'الأرباح المحتجزة',
    'Cash': 'نقدية',
    'Inventory': 'المخزون',
    'Fixed Assets': 'الأصول الثابتة',
    'Loans Payable': 'قروض مستحقة',
    'Share Capital': 'رأس المال',
    'Financing Profits': 'أرباح التمويل',
    'Prepaid Expenses': 'مصروفات مدفوعة مقدماً',
    'Accrued Liabilities': 'التزامات مستحقة',
  };

  static const Map<String, String> _descriptionPrefixes = {
    'Investor Deposit': 'إيداع مستثمر',
    'Investor Withdrawal': 'سحب مستثمر',
    'Withdrawal Request Approved': 'تمت المواقة على طلب السحب',
    'Activation of Contract': 'تفعيل العقد',
    'Payment for Contract': 'دفعة للعقد',
  };

  static const Map<String, String> _jobTypes = {
    'EMAIL_NOTIFICATION': 'إشعار بريد إلكتروني',
    'MONTHLY_REPORT_GEN': 'توليد التقرير الشهري',
    'SYNC': 'مزامنة بيانات',
    'BACKUP': 'نسخ احتياطي',
  };

  static const Map<String, String> _statusLabels = {
    'active': 'نشط',
    'inactive': 'غير نشط',
    'pending': 'قيد الانتظار',
    'completed': 'مكتمل',
    'failed': 'فشل',
    'cancelled': 'ملغي',
    'running': 'قيد التنفيذ',
    'retrying': 'إعادة محاولة',
    'in_progress': 'جاري',
    'approved': 'معتمد',
    'rejected': 'مرفوض',
    'paid': 'مدفوع',
    'unpaid': 'غير مدفوع',
    'partially_paid': 'مدفوع جزئياً',
  };

  static const Map<String, String> _eventTypes = {
    'PAYMENT_RECEIVED': 'تم استلام الدفعة',
    'FUNDING_ALLOCATED': 'تخصيص التمويل',
    'ContractClosed': 'إغلاق العقد',
    'ContractCreated': 'إنشاء العقد',
    'ContractActivated': 'تفعيل العقد',
    'CONTRACT_CREATED': 'إنشاء العقد',
    'CONTRACT_ACTIVATED': 'تفعيل العقد',
    'CONTRACT_CLOSED': 'إغلاق العقد',
    'document_uploaded': 'تم أرشفة مستند جديد',
    'document_deleted': 'تم حذف مستند من الأرشيف',
  };

  static const Map<String, String> _actionTypes = {
    // العمليات
    'INSERT': 'إضافة جديد',
    'UPDATE': 'تحديث بيانات',
    'DELETE': 'حذف سجل',
    'LOGIN': 'تسجيل دخول',
    'LOGOUT': 'تسجيل خروج',
    // الجداول
    'financing_contracts': 'العقود التمويلية',
    'customers': 'بيانات العملاء',
    'inventory_items': 'المخزون والسيارات',
    'payments': 'المدفوعات',
    'installments': 'الأقساط المجدولة',
    'investors': 'المستثمرون',
    'contract_documents': 'المستندات والأرشيف',
    'accounts': 'الحسابات المالية',
    'profiles': 'ملفات المستخدمين',
  };

  static String accountName(String? name) => name == null ? '' : _accountNames[name] ?? name;

  static String description(String? text) {
    if (text == null) return '';
    for (final entry in _descriptionPrefixes.entries) {
      if (text.startsWith(entry.key)) return text.replaceFirst(entry.key, entry.value);
    }
    return text;
  }

  static String jobType(String? type) => type == null ? '' : _jobTypes[type] ?? type;

  static String status(String? s) => s == null ? '' : _statusLabels[s.toLowerCase()] ?? s;

  static String eventType(String? type) => type == null ? '' : _eventTypes[type] ?? type;

  /// دالة لترجمة نوع العملية أو اسم الجدول في سجلات الرقابة
  static String actionType(String? type) {
    if (type == null || type.isEmpty) return '';
    if (_actionTypes.containsKey(type)) return _actionTypes[type]!;
    
    // محاولة ترجمة ذكية للكلمات المركبة
    final words = type.split('_');
    final translatedWords = words.map((w) => _actionTypes[w] ?? w).toList();
    return translatedWords.join(' ');
  }
}
