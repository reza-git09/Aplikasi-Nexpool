class OperatingHoursRange {
  const OperatingHoursRange({
    required this.openMinuteUtc,
    required this.closeMinuteUtc,
  }) : assert(openMinuteUtc >= 0 && openMinuteUtc < 1440),
       assert(closeMinuteUtc >= 0 && closeMinuteUtc < 1440);

  final int openMinuteUtc;
  final int closeMinuteUtc;
}

class OperatingHours {
  const OperatingHours({this.weeklySchedule = defaultWeeklySchedule});

  static const Duration wibOffset = Duration(hours: 7);
  static const OperatingHoursRange dailyHours = OperatingHoursRange(
    openMinuteUtc: 60,
    closeMinuteUtc: 600,
  );
  static const Map<int, OperatingHoursRange?> defaultWeeklySchedule = {
    DateTime.monday: dailyHours,
    DateTime.tuesday: dailyHours,
    DateTime.wednesday: dailyHours,
    DateTime.thursday: dailyHours,
    DateTime.friday: dailyHours,
    DateTime.saturday: dailyHours,
    DateTime.sunday: dailyHours,
  };

  final Map<int, OperatingHoursRange?> weeklySchedule;

  bool isOpen(DateTime nowUtc) {
    final utcNow = nowUtc.toUtc();
    final today = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);

    for (final offset in [-1, 0]) {
      final openingDay = today.add(Duration(days: offset));
      final hours = weeklySchedule[openingDay.weekday];
      if (hours == null) continue;

      final opening = _atMinute(openingDay, hours.openMinuteUtc);
      final closingDay = hours.closeMinuteUtc <= hours.openMinuteUtc
          ? openingDay.add(const Duration(days: 1))
          : openingDay;
      final closing = _atMinute(closingDay, hours.closeMinuteUtc);

      if (!utcNow.isBefore(opening) && utcNow.isBefore(closing)) {
        return true;
      }
    }

    return false;
  }

  DateTime? nextOpenTime(DateTime nowUtc) {
    final utcNow = nowUtc.toUtc();
    final today = DateTime.utc(utcNow.year, utcNow.month, utcNow.day);

    for (var offset = 0; offset <= 7; offset++) {
      final openingDay = today.add(Duration(days: offset));
      final hours = weeklySchedule[openingDay.weekday];
      if (hours == null) continue;

      final opening = _atMinute(openingDay, hours.openMinuteUtc);
      if (opening.isAfter(utcNow)) return opening;
    }

    return null;
  }

  static String formatWibTime(int minuteUtc) {
    final localTime = DateTime.utc(2000)
        .add(Duration(minutes: minuteUtc) + wibOffset);
    return '${localTime.hour.toString().padLeft(2, '0')}.'
        '${localTime.minute.toString().padLeft(2, '0')}';
  }

  static DateTime _atMinute(DateTime dayUtc, int minute) {
    return DateTime.utc(
      dayUtc.year,
      dayUtc.month,
      dayUtc.day,
      minute ~/ 60,
      minute % 60,
    );
  }
}
