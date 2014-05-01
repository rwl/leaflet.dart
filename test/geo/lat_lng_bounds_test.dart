import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('LatLngBounds', () {
    var a, c;

    setUp(() {
      a = new L.LatLngBounds(
          new L.LatLng(14, 12),
          new L.LatLng(30, 40));
      c = new L.LatLngBounds();
    });

    group('constructor', () {
      it('instantiates either passing two latlngs or an array of latlngs', () {
        var b = new L.LatLngBounds([
                                    new L.LatLng(14, 12),
                                    new L.LatLng(30, 40)
                                    ]);
        expect(b).to.eql(a);
        expect(b.getNorthWest()).to.eql(new L.LatLng(30, 12));
      });
    });

    group('#extend', () {
      it('extends the bounds by a given point', () {
        a.extend(new L.LatLng(20, 50));
        expect(a.getNorthEast()).to.eql(new L.LatLng(30, 50));
      });

      it('extends the bounds by given bounds', () {
        a.extend([[20, 50], [8, 40]]);
        expect(a.getSouthEast()).to.eql(new L.LatLng(8, 50));
      });

      it('extends the bounds by undefined', () {
        expect(a.extend()).to.eql(a);
      });

      it('extends the bounds by raw object', () {
        a.extend({lat: 20, lng: 50});
        expect(a.getNorthEast()).to.eql(new L.LatLng(30, 50));
      });
    });

    group('#getCenter', () {
      it('returns the bounds center', () {
        expect(a.getCenter()).to.eql(new L.LatLng(22, 26));
      });
    });

    group('#pad', () {
      it('pads the bounds by a given ratio', () {
        var b = a.pad(0.5);

        expect(b).to.eql(L.latLngBounds([[6, -2], [38, 54]]));
      });
    });

    group('#equals', () {
      it('returns true if bounds equal', () {
        expect(a.equals([[14, 12], [30, 40]])).to.eql(true);
        expect(a.equals([[14, 13], [30, 40]])).to.eql(false);
        expect(a.equals(null)).to.eql(false);
      });
    });

    group('#isValid', () {
      it('returns true if properly set up', () {
        expect(a.isValid()).to.be.ok();
      });
      it('returns false if is invalid', () {
        expect(c.isValid()).to.not.be.ok();
      });
      it('returns true if extended', () {
        c.extend([0, 0]);
        expect(c.isValid()).to.be.ok();
      });
    });

    group('#getWest', () {
      it('returns a proper bbox west value', () {
        expect(a.getWest()).to.eql(12);
      });
    });

    group('#getSouth', () {
      it('returns a proper bbox south value', () {
        expect(a.getSouth()).to.eql(14);
      });

    });

    group('#getEast', () {
      it('returns a proper bbox east value', () {
        expect(a.getEast()).to.eql(40);
      });

    });

    group('#getNorth', () {
      it('returns a proper bbox north value', () {
        expect(a.getNorth()).to.eql(30);
      });

    });

    group('#toBBoxString', () {
      it('returns a proper left,bottom,right,top bbox', () {
        expect(a.toBBoxString()).to.eql('12,14,40,30');
      });

    });

    group('#getNorthWest', () {
      it('returns a proper north-west LatLng', () {
        expect(a.getNorthWest()).to.eql(new L.LatLng(a.getNorth(), a.getWest()));
      });

    });

    group('#getSouthEast', () {
      it('returns a proper south-east LatLng', () {
        expect(a.getSouthEast()).to.eql(new L.LatLng(a.getSouth(), a.getEast()));
      });
    });

    group('#contains', () {
      it('returns true if contains latlng point', () {
        expect(a.contains([16, 20])).to.eql(true);
        expect(L.latLngBounds(a).contains([5, 20])).to.eql(false);
      });

      it('returns true if contains bounds', () {
        expect(a.contains([[16, 20], [20, 40]])).to.eql(true);
        expect(a.contains([[16, 50], [8, 40]])).to.eql(false);
      });
    });

    group('#intersects', () {
      it('returns true if intersects the given bounds', () {
        expect(a.intersects([[16, 20], [50, 60]])).to.eql(true);
        expect(a.contains([[40, 50], [50, 60]])).to.eql(false);
      });
    });

  });
}