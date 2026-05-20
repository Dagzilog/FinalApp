/// String and numeric helpers used across the app.
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension DoubleFormatting on double {
  /// Rounds to one decimal place for display.
  String toDisplayString({int decimals = 1}) {
    return toStringAsFixed(decimals);
  }
}

extension IntFormatting on int {
  String withThousandsSeparator() {
    final str = toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
