import '../constants/app_strings.dart';

/// Arabic-aware formatting helpers (Eastern Arabic numerals, dates, sizes).
abstract final class Formatters {
  static const int _zero = 0x30; // '0'
  static const int _nine = 0x39; // '9'
  static const int _arabicZero = 0x0660; // '٠'
  static const String _decimalSeparator = '٫';

  /// Converts Western digits (0-9) to Eastern Arabic digits (٠-٩).
  static String digits(String input) {
    final StringBuffer buffer = StringBuffer();
    for (final int code in input.codeUnits) {
      if (code >= _zero && code <= _nine) {
        buffer.writeCharCode(_arabicZero + code - _zero);
      } else if (code == 0x2E) {
        buffer.write(_decimalSeparator);
      } else {
        buffer.writeCharCode(code);
      }
    }
    return buffer.toString();
  }

  static String number(num value) => digits(value.toString());

  static String _two(int v) => v.toString().padLeft(2, '0');

  /// `mm:ss` (or `h:mm:ss`) in Arabic digits.
  static String duration(Duration d) {
    final int hours = d.inHours;
    final String mmss =
        '${_two(d.inMinutes.remainder(60))}:${_two(d.inSeconds.remainder(60))}';
    return digits(hours > 0 ? '$hours:$mmss' : mmss);
  }

  /// `١٠:٣٠ ص`
  static String time(DateTime date) {
    final int hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String suffix = date.hour < 12 ? AppStrings.am : AppStrings.pm;
    return '${digits('$hour12:${_two(date.minute)}')} $suffix';
  }

  /// Relative, human friendly date: "اليوم، ١٠:٣٠ ص", "أمس، ...", "١٢ مارس".
  static String relativeDate(DateTime date, {DateTime? now}) {
    final DateTime current = now ?? DateTime.now();
    final DateTime today = DateTime(current.year, current.month, current.day);
    final DateTime day = DateTime(date.year, date.month, date.day);
    final int diff = today.difference(day).inDays;

    if (diff == 0) return '${AppStrings.today}، ${time(date)}';
    if (diff == 1) return '${AppStrings.yesterday}، ${time(date)}';

    final String dm =
        '${digits('${date.day}')} ${AppStrings.months[date.month - 1]}';
    return date.year == current.year ? dm : '$dm ${digits('${date.year}')}';
  }

  /// Human readable byte size, e.g. "١٫٤ ميجابايت".
  static String fileSize(int bytes) {
    const int kb = 1024;
    const int mb = kb * 1024;
    const int gb = mb * 1024;
    if (bytes >= gb) return '${_fixed(bytes / gb)} ${AppStrings.gigaBytes}';
    if (bytes >= mb) return '${_fixed(bytes / mb)} ${AppStrings.megaBytes}';
    if (bytes >= kb) return '${_fixed(bytes / kb)} ${AppStrings.kiloBytes}';
    return '${digits('$bytes')} ${AppStrings.bytes}';
  }

  /// Short "MB" figure used in the storage card.
  static String megaBytes(int bytes) => '${_fixed(bytes / (1024 * 1024))} MB';

  static String _fixed(double value) {
    final String text = value >= 100
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return digits(
      text.endsWith('.0') ? text.substring(0, text.length - 2) : text,
    );
  }
}
