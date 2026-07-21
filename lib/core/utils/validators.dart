/// Form field validators — return an error message, or `null` if valid.
class Validators {
  Validators._();

  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _gstin = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_indianMobile.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  /// GST number is optional per PRD §4.1 — only validated when non-empty.
  static String? gstNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_gstin.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid 15-character GST number';
    }
    return null;
  }

  static String? name(String? value) => required(value, fieldName: 'Name');

  static String? address(String? value) => required(value, fieldName: 'Address');
}
