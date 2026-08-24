import 'dart:io';
import 'package:path/path.dart' as p;

class LogHelper {
  static String get _logFilePath {
    final executableDir = p.dirname(Platform.resolvedExecutable);
    return p.join(executableDir, 'logs', 'exceptions.log');
  }

  static Future<void> logException(
    Object exception, [
    StackTrace? stackTrace,
    String? context,
  ]) async {
    try {
      final file = File(_logFilePath);
      await file.parent.create(recursive: true);

      final timestamp = DateTime.now().toIso8601String();
      final buffer = StringBuffer();
      buffer.writeln('[$timestamp]');
      if (context != null) buffer.writeln('Context: $context');
      buffer.writeln('Exception: $exception');
      if (stackTrace != null) buffer.writeln('StackTrace:\n$stackTrace');
      buffer.writeln('---');

      await file.writeAsString(buffer.toString(), mode: FileMode.append);
    } catch (_) {
      // Silently ignore errors in the logger itself
    }
  }
}
