import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/geo/geo.dart' show LatLngBounds, LatLng;


main() {
  useHtmlEnhancedConfiguration();

  group('LatLngBounds', () {
    LatLngBounds a, c;

    setUp(() {
      a = new LatLngBounds.between(
          new LatLng(14, 12),
          new LatLng(30, 40));
      c = new LatLngBounds.between();
    });

    group('constructor', () {
      test('instantiates either passing two latlngs or an array of latlngs', () {
        final b = new LatLngBounds([
                                    new LatLng(14, 12),
                                    new LatLng(30, 40)
                                    ]);
        expect(b, equals(a));
        expect(b.getNorthWest(), equals(new LatLng(30, 12)));
      });
    });

    group('#extend', () {
      test('extends the bounds by a given point', () {
        a.extend(new LatLng(20, 50));
        expect(a.getNorthEast(), equals(new LatLng(30, 50)));
      });

      test('extends the bounds by given bounds', () {
        a.extendBounds(new LatLngBounds.between(new LatLng(20, 50), new LatLng(8, 40)));
        expect(a.getSouthEast(), equals(new LatLng(8, 50)));
      });

      test('extends the bounds by undefined', () {
        a.extendBounds();
        expect(a, equals(a));
      });

      /*test('extends the bounds by raw object', () {
        a.extend({lat: 20, lng: 50});
        expect(a.getNorthEast()).to.eql(new L.LatLng(30, 50));
      });*/
    });

    group('#getCenter', () {
      test('returns the bounds center', () {
        expect(a.getCenter(), equals(new LatLng(22, 26)));
      });
    });

    group('#pad', () {
      test('pads the bounds by a given ratio', () {
        var b = a.pad(0.5);

        expect(b, equals(new LatLngBounds([new LatLng(6, -2), new LatLng(38, 54)])));
      });
    });

    group('#equals', () {
      test('returns true if bounds equal', () {
        expect(a == new LatLngBounds([new LatLng(14, 12), new LatLng(30, 40)]), isTrue);
        expect(a == new LatLngBounds([new LatLng(14, 13), new LatLng(30, 40)]), isFalse);
        expect(a == null, isFalse);
      });
    });

    group('#isValid', () {
      test('returns true if properly set up', () {
        expect(a.isValid(), isTrue);
      });
      test('returns false if is invalid', () {
        expect(c.isValid(), isFalse);
      });
      test('returns true if extended', () {
        c.extend(new LatLng(0, 0));
        expect(c.isValid(), isTrue);
      });
    });

    group('#getWest', () {
      test('returns a proper bbox west value', () {
        expect(a.getWest(), equals(12));
      });
    });

    group('#getSouth', () {
      test('returns a proper bbox south value', () {
        expect(a.getSouth(), equals(14));
      });
    });

    group('#getEast', () {
      test('returns a proper bbox east value', () {
        expect(a.getEast(), equals(40));
      });
    });

    group('#getNorth', () {
      test('returns a proper bbox north value', () {
        expect(a.getNorth(), equals(30));
      });
    });

    group('#toBBoxString', () {
      test('returns a proper left,bottom,right,top bbox', () {
        expect(a.toBBoxString(), equals('12,14,40,30'));
      });
    });

    group('#getNorthWest', () {
      test('returns a proper north-west LatLng', () {
        expect(a.getNorthWest(), equals(new LatLng(a.getNorth(), a.getWest())));
      });
    });

    group('#getSouthEast', () {
      test('returns a proper south-east LatLng', () {
        expect(a.getSouthEast(), equals(new LatLng(a.getSouth(), a.getEast())));
      });
    });

    group('#contains', () {
      test('returns true if contains latlng point', () {
        expect(a.contains(new LatLng(16, 20)), isTrue);
        expect(new LatLngBounds.latLngBounds(a).contains(new LatLng(5, 20)), isFalse);
      });

      test('returns true if contains bounds', () {
        expect(a.containsBounds(new LatLngBounds.between(new LatLng(16, 20), new LatLng(20, 40))), isTrue);
        expect(a.containsBounds(new LatLngBounds.between(new LatLng(16, 50), new LatLng(8, 40))), isFalse);
      });
    });

    group('#intersects', () {
      test('returns true if intersects the given bounds', () {
        expect(a.intersects(new LatLngBounds.between(new LatLng(16, 20), new LatLng(50, 60))), isTrue);
        expect(a.containsBounds(new LatLngBounds.between(new LatLng(40, 50), new LatLng(50, 60))), isFalse);
      });
    });

  });
}