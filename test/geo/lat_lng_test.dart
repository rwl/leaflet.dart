import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/geo/geo.dart' show LatLng;


main() {
  useHtmlEnhancedConfiguration();

  group('LatLng', () {
    group('constructor', () {
      test('sets lat and lng', () {
        final a = new LatLng(25, 74);
        expect(a.lat, equals(25));
        expect(a.lng, equals(74));

        final b = new LatLng(-25, -74);
        expect(b.lat, equals(-25));
        expect(b.lng, equals(-74));
      });

      test('throws an error if invalid lat or lng', () {
        expect(() {
          var a = new LatLng(double.NAN, double.NAN);
        }).to.throwError();
      });

      test('does not set altitude if undefined', () {
        final a = new LatLng(25, 74);
        expect(a.alt == null, isTrue);
      });

      test('sets altitude', () {
        final a = new LatLng(25, 74, 50);
        expect(a.alt, equals(50));

        final b = new LatLng(-25, -74, -50);
        expect(b.alt, equals(-50));
      });
    });

    group('#equals', () {
      test('returns true if compared objects are equal within a certain margin', () {
        final a = new LatLng(10, 20);
        final b = new LatLng(10 + 1.0E-10, 20 - 1.0E-10);
        expect(a == b, isTrue);
      });

      test('returns false if compared objects are not equal within a certain margin', () {
        final a = new LatLng(10, 20);
        final b = new LatLng(10, 23.3);
        expect(a == b, isFalse);
      });

      test('returns false if passed non-valid object', () {
        final a = new LatLng(10, 20);
        expect(a == null, isFalse);
      });
    });

    group('#wrap', () {
      test('wraps longitude to lie between -180 and 180 by default', () {
        final a = new LatLng(0, 190).wrap().lng;
        expect(a, equals(-170));

        final b = new LatLng(0, 360).wrap().lng;
        expect(b, equals(0));

        final c = new LatLng(0, 380).wrap().lng;
        expect(c, equals(20));

        final d = new LatLng(0, -190).wrap().lng;
        expect(d, equals(170));

        final e = new LatLng(0, -360).wrap().lng;
        expect(e, equals(0));

        final f = new LatLng(0, -380).wrap().lng;
        expect(f, equals(-20));

        final g = new LatLng(0, 90).wrap().lng;
        expect(g, equals(90));

        final h = new LatLng(0, 180).wrap().lng;
        expect(h, equals(180));
      });

      test('wraps longitude within the given range', () {
        final a = new LatLng(0, 190).wrap(-100, 100).lng;
        expect(a, equals(-10));
      });
    });

    group('#toString', () {
      test('formats a string', () {
        final a = new LatLng(10.333333333, 20.2222222);
        expect(a.toString(3), equals('LatLng(10.333, 20.222)'));
      });
    });

    group('#distanceTo', () {
      test('calculates distance in meters', () {
        final a = new LatLng(50.5, 30.5);
        final b = new LatLng(50, 1);

        expect(((a.distanceTo(b) / 1000).round() - 2084).abs() < 5, isTrue);
      });
    });

    group('L.latLng factory', () {
      test('returns LatLng instance as is', () {
        final a = new LatLng(50, 30);

        expect(new LatLng.latLng(a), equals(a));
      });

      test('accepts an array of coordinates', () {
        expect(new LatLng([50, 30]), equals(new LatLng(50, 30)));
      });

      test('passes null or undefined as is', () {
        expect(new LatLng.latLng(null), isNull);
        //expect(L.latLng(null)).to.eql(null);
      });

      test('creates a LatLng object from two coordinates', () {
        expect(new LatLng(50, 30), equals(new LatLng(50, 30)));
      });

      test('accepts an object with lat/lng', () {
        expect(new LatLng.map({'lat': 50, 'lng': 30}), equals(new LatLng(50, 30)));
      });

      test('accepts an object with lat/lon', () {
        expect(new LatLng.map({'lat': 50, 'lon': 30}), equals(new LatLng(50, 30)));
      });
    });
  });
}