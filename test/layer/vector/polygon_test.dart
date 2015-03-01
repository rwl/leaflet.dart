part of leaflet.layer.vector.test;

polygonTest() {
  group('Polygon', () {

    final c = document.createElement('div');
    c.style.width = '400px';
    c.style.height = '400px';
    var map = new LeafletMap(c);
    map.setView(new LatLng(55.8, 37.6), 6);

    group('initialize', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
          new LatLng(1, 2),
          new LatLng(3, 4),
          new LatLng(1, 2)
        ];
        final sourceLatLngs = new List.from(originalLatLngs);

        final polygon = new Polygon(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
        expect(polygon.latlngs, isNot(equals(sourceLatLngs)));
      });

      test('can be called with an empty array', () {
        final polygon = new Polygon([]);
        expect(polygon.getLatLngs(), equals([]));
      });

      test('can be initialized with holes', () {
//        final originalLatLngs = [
//          [ //external rink
//            new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)
//          ], [ //hole
//            new LatLng(2, 3), new LatLng(2, 4), new LatLng(3, 4)
//          ]
//        ];
        final originalLatLngs = [ //external rink
            new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)
          ];
        final holes = [
          [ //hole
            new LatLng(2, 3), new LatLng(2, 4), new LatLng(3, 4)
          ]
        ];

        final polygon = new Polygon(originalLatLngs, null, holes);

        //getLatLngs() returns only external ring
        expect(polygon.getLatLngs(), equals([
          new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)
        ]));
      });
    });

    group('setLatLngs', () {
      test('doesn\'t overwrite the given latlng array', () {
        final originalLatLngs = [
          new LatLng(1, 2),
          new LatLng(3, 4)
        ];
        final sourceLatLngs = new List.from(originalLatLngs);

        final polygon = new Polygon(sourceLatLngs);

        polygon.setLatLngs(sourceLatLngs);

        expect(sourceLatLngs, equals(originalLatLngs));
      });

      test('can be set external ring and holes', () {
        final latLngs = [ //external rink
            new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)
          ];
        final holes = [
          [ //hole
            new LatLng(2, 3), new LatLng(2, 4), new LatLng(3, 4)
          ]
        ];

        final polygon = new Polygon([]);
        polygon.setLatLngs(latLngs);
        polygon.setHoles(holes);

        //getLatLngs() returns only external ring
        expect(polygon.getLatLngs(), equals([
          new LatLng(0, 10), new LatLng(10, 10), new LatLng(10, 0)
        ]));
      });
    });

    group('spliceLatLngs', () {
      test('splices the internal latLngs', () {
        final latLngs = [
          new LatLng(1, 2),
          new LatLng(3, 4),
          new LatLng(5, 6)
        ];

        final polygon = new Polygon(latLngs);

        polygon.spliceLatLngs(1, 1, [new LatLng(7, 8)]);

        final ll = polygon.latlngs;
        final expected = [new LatLng(1, 2), new LatLng(7, 8), new LatLng(5, 6)];
        expect(ll, equals(expected));
      });
    });
  });
}