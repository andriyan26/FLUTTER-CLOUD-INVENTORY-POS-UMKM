import 'print_helper_stub.dart'
    if (dart.library.html) 'print_helper_web.dart';

class PrintHelper {
  PrintHelper._();

  /// Membuka dialog Cetak / Simpan PDF bawaan browser dengan dokumen HTML khusus
  static Future<bool> printHtmlDocument({
    required String title,
    required String htmlDocument,
  }) {
    return triggerHtmlPrintImpl(
      title: title,
      htmlDocument: htmlDocument,
    );
  }

  /// Mengunduh file (CSV / HTML) langsung ke perangkat pengguna
  static Future<bool> downloadFile({
    required String fileName,
    required String content,
    String mimeType = 'text/csv;charset=utf-8',
  }) {
    return triggerFileDownloadImpl(
      fileName: fileName,
      content: content,
      mimeType: mimeType,
    );
  }
}

