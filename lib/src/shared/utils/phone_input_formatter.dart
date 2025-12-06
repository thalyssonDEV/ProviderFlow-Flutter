import 'package:flutter/services.dart';

/// Formats Brazilian phone numbers while typing.
/// Examples:
/// - 10 digits: (99) 9999-9999
/// - 11 digits: (99) 99999-9999
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';

    if (digits.isEmpty) {
      formatted = '';
    } else {
      final d = digits;
      final len = d.length;
      if (len <= 2) {
        formatted = d;
      } else if (len <= 6) {
        // (99) 9999 or (99) 99999 partial
        formatted = '(${d.substring(0, 2)}) ${d.substring(2)}';
      } else if (len <= 10) {
        // (99) 9999-9999 partial
        formatted = '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
      } else {
        // cap at 11 digits: (99) 99999-9999
        final capped = d.substring(0, 11);
        formatted = '(${capped.substring(0, 2)}) ${capped.substring(2, 7)}-${capped.substring(7)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Returns only digits (useful to store in DB or send to APIs)
  static String extractDigits(String input) => input.replaceAll(RegExp(r'[^0-9]'), '');
}
