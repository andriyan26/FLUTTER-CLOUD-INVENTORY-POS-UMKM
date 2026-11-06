// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

Future<bool> triggerHtmlPrintImpl({
  required String title,
  required String htmlDocument,
}) async {
  try {
    // Hapus iframe cetak lama jika masih ada
    final existing = html.document.getElementById('cloudpos-print-frame');
    existing?.remove();

    final iframe = html.IFrameElement()
      ..id = 'cloudpos-print-frame'
      ..style.position = 'fixed'
      ..style.right = '0'
      ..style.bottom = '0'
      ..style.width = '1px'
      ..style.height = '1px'
      ..style.border = '0'
      ..style.opacity = '0.01';

    html.document.body?.append(iframe);

    final completer = Completer<bool>();
    iframe.onLoad.first.then((_) async {
      await Future.delayed(const Duration(milliseconds: 280));
      try {
        final win = iframe.contentWindow;
        if (win != null) {
          // Panggil dialog cetak / Save as PDF bawaan browser pada dokumen terformat
          (win as dynamic).focus();
          (win as dynamic).print();
        }
      } catch (_) {}
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    iframe.srcdoc = htmlDocument;

    return await completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () => true,
    );
  } catch (_) {
    return false;
  }
}

Future<bool> triggerFileDownloadImpl({
  required String fileName,
  required String content,
  required String mimeType,
}) async {
  try {
    final bytes = utf8.encode(content);
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
    return true;
  } catch (_) {
    return false;
  }
}
