import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// مساعد التصدير لتحويل البيانات إلى CSV (كبداية سريعة ومتوافقة مع Excel)
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

    // إضافة BOM لضمان دعم اللغة العربية في Excel
    final List<int> bytes = [0xEF, 0xBB, 0xBF] + csvData.codeUnits;

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.csv');
    
    await file.writeAsBytes(bytes);
    
    // مشاركة الملف أو فتحه
    await Share.shareXFiles([XFile(file.path)], text: 'تصدير بيانات $fileName');
  }

  /// يمكن لاحقاً إضافة exportToPdf و exportToExcel هنا باستخدام مكتبات متخصصة
}
