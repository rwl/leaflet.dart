import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('TileLayer', () {
    var tileUrl = '';

    group('#getMaxZoom, #getMinZoom', () {
      var map;
      setUp(() {
        map = L.map(document.createElement('div'));
      });
      group('when a tilelayer is added to a map with no other layers', () {
        test('has the same zoomlevels as the tilelayer', () {
          var maxZoom = 10,
            minZoom = 5;

          map.setView([0, 0], 1);

          L.tileLayer(tileUrl, {
            maxZoom: maxZoom,
            minZoom: minZoom
          }).addTo(map);

          expect(map.getMaxZoom()).to.be(maxZoom);
          expect(map.getMinZoom()).to.be(minZoom);
        });
      });

      group('accessing a tilelayer\'s properties', () {
        test('provides a container', () {
          map.setView([0, 0], 1);

          var layer = L.tileLayer(tileUrl).addTo(map);
          expect(layer.getContainer()).to.be.ok();
        });
      });

      group('when a tilelayer is added to a map that already has a tilelayer', () {
        test('has its zoomlevels updated to fit the new layer', () {
          map.setView([0, 0], 1);

          L.tileLayer(tileUrl, {minZoom: 10, maxZoom: 15}).addTo(map);
          expect(map.getMinZoom()).to.be(10);
          expect(map.getMaxZoom()).to.be(15);

          L.tileLayer(tileUrl, {minZoom: 5, maxZoom: 10}).addTo(map);
          expect(map.getMinZoom()).to.be(5);  // changed
          expect(map.getMaxZoom()).to.be(15); // unchanged

          L.tileLayer(tileUrl, {minZoom: 10, maxZoom: 20}).addTo(map);
          expect(map.getMinZoom()).to.be(5);  // unchanged
          expect(map.getMaxZoom()).to.be(20); // changed


          L.tileLayer(tileUrl, {minZoom: 0, maxZoom: 25}).addTo(map);
          expect(map.getMinZoom()).to.be(0); // changed
          expect(map.getMaxZoom()).to.be(25); // changed
        });
      });
      group('when a tilelayer is removed from a map', () {
        test('has its zoomlevels updated to only fit the layers it currently has', () {
          var tiles = [  L.tileLayer(tileUrl, {minZoom: 10, maxZoom: 15}).addTo(map),
                   L.tileLayer(tileUrl, {minZoom: 5, maxZoom: 10}).addTo(map),
                   L.tileLayer(tileUrl, {minZoom: 10, maxZoom: 20}).addTo(map),
                   L.tileLayer(tileUrl, {minZoom: 0, maxZoom: 25}).addTo(map)
                ];
          map.whenReady(() {
            expect(map.getMinZoom()).to.be(0);
            expect(map.getMaxZoom()).to.be(25);

            map.removeLayer(tiles[0]);
            expect(map.getMinZoom()).to.be(0);
            expect(map.getMaxZoom()).to.be(25);

            map.removeLayer(tiles[3]);
            expect(map.getMinZoom()).to.be(5);
            expect(map.getMaxZoom()).to.be(20);

            map.removeLayer(tiles[2]);
            expect(map.getMinZoom()).to.be(5);
            expect(map.getMaxZoom()).to.be(10);

            map.removeLayer(tiles[1]);
            expect(map.getMinZoom()).to.be(0);
            expect(map.getMaxZoom()).to.be(Infinity);
          });
        });
      });
    });
  });
}