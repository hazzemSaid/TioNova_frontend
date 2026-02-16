/// Conditional export for web PDF viewer.
/// Uses the web implementation on web platform, stub on others.
/// Note: Using dart.library.js_interop for modern Flutter web compatibility.
export 'web_pdf_viewer_stub.dart'
    if (dart.library.js_interop) 'web_pdf_viewer_web.dart';
