import 'package:intl/intl.dart';

/// Returns today's date as `yyyy-MM-dd` for log keys.
String todayDateKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());
