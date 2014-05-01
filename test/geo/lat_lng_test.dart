import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('LatLng', () {
    group('constructor', () {
      test('sets lat and lng', () {
        var a = new L.LatLng(25, 74);
        expect(a.lat).to.eql(25);
        expect(a.lng).to.eql(74);

        var b = new L.LatLng(-25, -74);
        expect(b.lat).to.eql(-25);
        expect(b.lng).to.eql(-74);
      });

      test('throws an error if invalid lat or lng', () {
        expect(() {
          var a = new L.LatLng(NaN, NaN);
        }).to.throwError();
      });

      test('does not set altitude if undefined', () {
        var a = new L.LatLng(25, 74);
        expect(typeof(a.alt)).to.eql('undefined');
      });

      test('sets altitude', () {
        var a = new L.LatLng(25, 74, 50);
        expect(a.alt).to.eql(50);

        var b = new L.LatLng(-25, -74, -50);
        expect(b.alt).to.eql(-50);
      });

    });

    group('#equals', () {
      test('returns true if compared objects are equal within a certain margin', () {
        var a = new L.LatLng(10, 20);
        var b = new L.LatLng(10 + 1.0E-10, 20 - 1.0E-10);
        expect(a.equals(b)).to.eql(true);
      });

      test('returns false if compared objects are not equal within a certain margin', () {
        var a = new L.LatLng(10, 20);
        var b = new L.LatLng(10, 23.3);
        expect(a.equals(b)).to.eql(false);
      });

      test('returns false if passed non-valid object', () {
        var a = new L.LatLng(10, 20);
        expect(a.equals(null)).to.eql(false);
      });
    });

    group('#wrap', () {
      test('wraps longitude to lie between -180 and 180 by default', () {
        var a = new L.LatLng(0, 190).wrap().lng;
        expect(a).to.eql(-170);

        var b = new L.LatLng(0, 360).wrap().lng;
        expect(b).to.eql(0);

        var c = new L.LatLng(0, 380).wrap().lng;
        expect(c).to.eql(20);

        var d = new L.LatLng(0, -190).wrap().lng;
        expect(d).to.eql(170);

        var e = new L.LatLng(0, -360).wrap().lng;
        expect(e).to.eql(0);

        var f = new L.LatLng(0, -380).wrap().lng;
        expect(f).to.eql(-20);

        var g = new L.LatLng(0, 90).wrap().lng;
        expect(g).to.eql(90);

        var h = new L.LatLng(0, 180).wrap().lng;
        expect(h).to.eql(180);
      });

      test('wraps longitude within the given range', () {
        var a = new L.LatLng(0, 190).wrap(-100, 100).lng;
        expect(a).to.eql(-10);
      });

    });

    group('#toString', () {
      test('formats a string', () {
        var a = new L.LatLng(10.333333333, 20.2222222);
        expect(a.toString(3)).to.eql('LatLng(10.333, 20.222)');
      });
    });

    group('#distanceTo', () {
      test('calculates distance in meters', () {
        var a = new L.LatLng(50.5, 30.5);
        var b = new L.LatLng(50, 1);

        expect(Math.abs(Math.round(a.distanceTo(b) / 1000) - 2084) < 5).to.eql(true);
      });
    });

    group('L.latLng factory', () {
      test('returns LatLng instance as is', () {
        var a = new L.LatLng(50, 30);

        expect(L.latLng(a)).to.eql(a);
      });

      test('accepts an array of coordinates', () {
        expect(L.latLng([50, 30])).to.eql(new L.LatLng(50, 30));
      });

      test('passes null or undefined as is', () {
        expect(L.latLng(undefined)).to.eql(undefined);
        expect(L.latLng(null)).to.eql(null);
      });

      test('creates a LatLng object from two coordinates', () {
        expect(L.latLng(50, 30)).to.eql(new L.LatLng(50, 30));
      });

      test('accepts an object with lat/lng', () {
        expect(L.latLng({lat: 50, lng: 30})).to.eql(new L.LatLng(50, 30));
      });

      test('accepts an object with lat/lon', () {
        expect(L.latLng({lat: 50, lon: 30})).to.eql(new L.LatLng(50, 30));
      });
    });
  });
}