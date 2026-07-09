import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// لا تستورد dart:io هنا لأنه يكسر الويب

class ExportHelper {
  static Future<void> exportToCsv({
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) async {
    String csvData = headers.join(',') + '\n';
    
    for (var row in rows) {
      csvData += row.map((e) => '"$e"').join(',') + '\n';
    }

    if (kIsWeb) {
      // منطق التصدير للويب (تنزيل الملف في المتصفح)
      // حالياً سنعرض رسالة، ويمكن تطويرها لاحقاً بمكتبة dart:html
      print("تصدير الويب قيد التطوير: $fileName");
    } else {
      // منطق الموبايل (Share)
      // هنا سنحتاج لاستخدام مكتبة خارجية بديلة لـ dart:io إذا أردنا حفظ الملف
      await Share.share(csvData, subject: 'تصدير بيانات $fileName');
    }
  }
}
