/// Conditional export for web PDF viewer.
/// Uses the web implementation on web platform, stub on others.
export 'web_pdf_viewer_stub.dart'
    if (dart.library.html) 'web_pdf_viewer_web.dart';
