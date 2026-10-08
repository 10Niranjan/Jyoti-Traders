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

/// Minimal RFC 4180 CSV decoder — the counterpart to [encodeCsv]. Handles
/// quoted fields (commas/newlines/doubled-quotes inside them) via a small
/// character-by-character state machine rather than a naive `split(',')`,
/// which would break on any quoted field containing a comma.
List<List<String>> decodeCsv(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    rows.add(row);
    row = [];
  }

  for (var i = 0; i < input.length; i++) {
    final c = input[i];
    if (inQuotes) {
      if (c == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      inQuotes = true;
    } else if (c == ',') {
      endField();
    } else if (c == '\r') {
      // Swallowed; the paired '\n' (or its absence, for a lone '\r') ends
      // the row below.
    } else if (c == '\n') {
      endRow();
    } else {
      field.write(c);
    }
  }
  // A trailing row with no final newline still has content pending.
  if (field.isNotEmpty || row.isNotEmpty) endRow();

  return rows;
}
