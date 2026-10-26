import 'package:flutter_test/flutter_test.dart';
import 'package:mirada/utils/version.dart';

void main() {
  group('Version.tryParse', () {
    test('parses plain and v-prefixed versions', () {
      expect(Version.tryParse('1.2.3'), const Version(1, 2, 3));
      expect(Version.tryParse('v2.0.1'), const Version(2, 0, 1));
      expect(Version.tryParse('  v0.10.20  '), const Version(0, 10, 20));
    });

    test('ignores build metadata and prerelease suffix', () {
      expect(Version.tryParse('1.2.3+build.5'), const Version(1, 2, 3));
      expect(Version.tryParse('v1.2.3-rc.1'), const Version(1, 2, 3));
    });

    test('rejects malformed input', () {
      expect(Version.tryParse(''), isNull);
      expect(Version.tryParse('1.2'), isNull);
      expect(Version.tryParse('1.2.3.4'), isNull);
      expect(Version.tryParse('a.b.c'), isNull);
      expect(Version.tryParse('1.x.3'), isNull);
      expect(Version.tryParse('-1.2.3'), isNull);
    });
  });

  group('Version comparison', () {
    test('orders by major then minor then patch', () {
      expect(const Version(1, 0, 0) < const Version(2, 0, 0), isTrue);
      expect(const Version(1, 0, 0) < const Version(1, 1, 0), isTrue);
      expect(const Version(1, 0, 0) < const Version(1, 0, 1), isTrue);
      expect(const Version(1, 2, 3) > const Version(1, 2, 2), isTrue);
      expect(const Version(2, 0, 0) >= const Version(2, 0, 0), isTrue);
      expect(const Version(1, 0, 0) <= const Version(1, 0, 0), isTrue);
      expect(const Version(3, 0, 0) > const Version(2, 9, 9), isTrue);
    });

    test('equality and hashCode', () {
      expect(const Version(1, 2, 3), equals(const Version(1, 2, 3)));
      expect(const Version(1, 2, 3).hashCode, const Version(1, 2, 3).hashCode);
      expect(const Version(1, 2, 3) == const Version(1, 2, 4), isFalse);
      // ignore: unrelated_type_equality_checks
      expect(const Version(1, 2, 3) == '1.2.3', isFalse);
    });
  });

  test('toString', () {
    expect(const Version(1, 2, 3).toString(), '1.2.3');
    expect(const Version(0, 0, 10).toString(), '0.0.10');
  });
}
