import 'package:flutter_test/flutter_test.dart';
import 'package:nexpool/services/operating_hours.dart';

void main() {
  const operatingHours = OperatingHours();

  group('OperatingHours.isOpen', () {
    test('is closed at 00:59 UTC (07:59 WIB)', () {
      expect(operatingHours.isOpen(DateTime.utc(2026, 11, 10, 0, 59)), isFalse);
    });

    test('is open at 01:00 UTC (08:00 WIB)', () {
      expect(operatingHours.isOpen(DateTime.utc(2026, 11, 10, 1)), isTrue);
    });

    test('is open at 09:59 UTC (16:59 WIB)', () {
      expect(operatingHours.isOpen(DateTime.utc(2026, 11, 10, 9, 59)), isTrue);
    });

    test('is closed at 10:00 UTC (17:00 WIB)', () {
      expect(operatingHours.isOpen(DateTime.utc(2026, 11, 10, 10)), isFalse);
    });

    test(
      'uses the same instant regardless of local DateTime representation',
      () {
        final nowUtc = DateTime.utc(2026, 11, 10, 9, 59);
        final localRepresentation = DateTime.fromMillisecondsSinceEpoch(
          nowUtc.millisecondsSinceEpoch,
        );

        expect(
          operatingHours.isOpen(localRepresentation),
          operatingHours.isOpen(nowUtc),
        );
      },
    );

    test('handles operating hours that cross midnight UTC', () {
      const overnightHours = OperatingHours(
        weeklySchedule: {
          DateTime.friday: OperatingHoursRange(
            openMinuteUtc: 22 * 60,
            closeMinuteUtc: 2 * 60,
          ),
        },
      );

      expect(overnightHours.isOpen(DateTime.utc(2026, 11, 13, 23)), isTrue);
      expect(overnightHours.isOpen(DateTime.utc(2026, 11, 14, 1, 59)), isTrue);
      expect(overnightHours.isOpen(DateTime.utc(2026, 11, 14, 2)), isFalse);
    });
  });

  test('formats the UTC schedule as WIB using the fixed offset', () {
    expect(OperatingHours.formatWibTime(60), '08.00');
    expect(OperatingHours.formatWibTime(600), '17.00');
  });
}
