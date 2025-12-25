/// Conditional export for file helper.
/// Uses the IO implementation on mobile/desktop, stub on web.
export 'file_helper_stub.dart' if (dart.library.io) 'file_helper_io.dart';
