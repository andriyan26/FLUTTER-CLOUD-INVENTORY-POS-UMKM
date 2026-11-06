Future<bool> triggerHtmlPrintImpl({
  required String title,
  required String htmlDocument,
}) async {
  // Fallback untuk environment unit test / non-web VM
  return true;
}

Future<bool> triggerFileDownloadImpl({
  required String fileName,
  required String content,
  required String mimeType,
}) async {
  return true;
}

