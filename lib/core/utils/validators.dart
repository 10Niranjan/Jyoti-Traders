/// Form field validators — return an error message, or `null` if valid.
class Validators {
  Validators._();

  static final RegExp _indianMobile = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _gstin = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
  );
  static final RegExp _ifsc = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  static final RegExp _accountNumber = RegExp(r'^\d{9,18}$');

  /// Letters only, single spaces/apostrophes/hyphens between words — the
  /// alternation (separator must be followed by another letter run) is what
  /// rules out doubled-up spaces/punctuation without a separate check.
  static final RegExp _fullName = RegExp(r"^[A-Za-z]+(?:[ '-][A-Za-z]+)*$");
  static final RegExp _shopName = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9 &.-]*[A-Za-z0-9])?$');
  static final RegExp _email = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp _hasUpper = RegExp(r'[A-Z]');
  static final RegExp _hasLower = RegExp(r'[a-z]');
  static final RegExp _hasDigit = RegExp(r'\d');
  static final RegExp _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\[\]/\\;+=~`]');

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

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Name is required';
    if (trimmed.length < 2) return 'Name must be at least 2 characters';
    if (trimmed.length > 50) return 'Name must be under 50 characters';
    if (!_fullName.hasMatch(trimmed)) return 'Name can only contain letters and spaces';
    return null;
  }

  static String? address(String? value) => required(value, fieldName: 'Address');

  static String? businessName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Shop name is required';
    if (trimmed.length < 2) return 'Shop name must be at least 2 characters';
    if (trimmed.length > 100) return 'Shop name must be under 100 characters';
    if (!_shopName.hasMatch(trimmed)) return 'Only letters, numbers, spaces, & - . are allowed';
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Email is required';
    if (trimmed.length > 254) return 'Email must be under 254 characters';
    if (!_email.hasMatch(trimmed)) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.trim() != value) return 'Password cannot start or end with a space';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (value.length > 128) return 'Password must be under 128 characters';
    if (!_hasUpper.hasMatch(value)) return 'Include at least one uppercase letter';
    if (!_hasLower.hasMatch(value)) return 'Include at least one lowercase letter';
    if (!_hasDigit.hasMatch(value)) return 'Include at least one number';
    if (!_hasSpecialChar.hasMatch(value)) return 'Include at least one special character';
    return null;
  }

  /// Bank details are optional as a set — only validated once the retailer
  /// has started filling in payout info, mirroring [gstNumber].
  static String? ifscCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_ifsc.hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid 11-character IFSC code';
    }
    return null;
  }

  static String? bankAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (!_accountNumber.hasMatch(value.trim())) {
      return 'Enter a valid 9-18 digit account number';
    }
    return null;
  }
}
