/// Minimal RFC 4180 CSV encoder — a field is quoted only when it contains a
/// comma, quote, or newline, with internal quotes doubled. No package needed
/// for something this small.
String encodeCsv(List<List<Object?>> rows) {
  String escapeField(Object? value) {
    final s = value?.toString() ?? '';
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  return rows.map((row) => row.map(escapeField).join(',')).join('\r\n');
}
