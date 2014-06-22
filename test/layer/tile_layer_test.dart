import 'dart:html' show document;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show BaseMap;
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/layer/tile/tile.dart' show TileLayer;

main() {
  useHtmlEnhancedConfiguration();

  group('TileLayer', () {
    String tileUrl = '';

    group('#getMaxZoom, #getMinZoom', () {
      BaseMap map;
      setUp(() {
        map = new BaseMap(document.createElement('div'));
      });
      group('when a tilelayer is added to a map with no other layers', () {
        test('has the same zoomlevels as the tilelayer', () {
          final maxZoom = 10,
            minZoom = 5;

          map.setView(new LatLng(0, 0), 1);

          new TileLayer(tileUrl, {
            'maxZoom': maxZoom,
            'minZoom': minZoom
          })..addTo(map);

          expect(map.getMaxZoom(), equals(maxZoom));
          expect(map.getMinZoom(), equals(minZoom));
        });
      });

      group('accessing a tilelayer\'s properties', () {
        test('provides a container', () {
          map.setView(new LatLng(0, 0), 1);

          final layer = new TileLayer(tileUrl)..addTo(map);
          expect(layer.getContainer(), isNotNull);
        });
      });

      group('when a tilelayer is added to a map that already has a tilelayer', () {
        test('has its zoomlevels updated to fit the new layer', () {
          map.setView(new LatLng(0, 0), 1);

          new TileLayer(tileUrl, {'minZoom': 10, 'maxZoom': 15})..addTo(map);
          expect(map.getMinZoom(), equals(10));
          expect(map.getMaxZoom(), equals(15));

          new TileLayer(tileUrl, {'minZoom': 5, 'maxZoom': 10})..addTo(map);
          expect(map.getMinZoom(), equals(5));  // changed
          expect(map.getMaxZoom(), equals(15)); // unchanged

          new TileLayer(tileUrl, {'minZoom': 10, 'maxZoom': 20})..addTo(map);
          expect(map.getMinZoom(), equals(5));  // unchanged
          expect(map.getMaxZoom(), equals(20)); // changed


          new TileLayer(tileUrl, {'minZoom': 0, 'maxZoom': 25})..addTo(map);
          expect(map.getMinZoom(), equals(0)); // changed
          expect(map.getMaxZoom(), equals(25)); // changed
        });
      });
      group('when a tilelayer is removed from a map', () {
        test('has its zoomlevels updated to only fit the layers it currently has', () {
          final tiles = [  new TileLayer(tileUrl, {'minZoom': 10, 'maxZoom': 15})..addTo(map),
                   new TileLayer(tileUrl, {'minZoom': 5, 'maxZoom': 10})..addTo(map),
                   new TileLayer(tileUrl, {'minZoom': 10, 'maxZoom': 20})..addTo(map),
                   new TileLayer(tileUrl, {'minZoom': 0, 'maxZoom': 25})..addTo(map)
                ];
          map.whenReady(() {
            expect(map.getMinZoom(), equals(0));
            expect(map.getMaxZoom(), equals(25));

            map.removeLayer(tiles[0]);
            expect(map.getMinZoom(), equals(0));
            expect(map.getMaxZoom(), equals(25));

            map.removeLayer(tiles[3]);
            expect(map.getMinZoom(), equals(5));
            expect(map.getMaxZoom(), equals(20));

            map.removeLayer(tiles[2]);
            expect(map.getMinZoom(), equals(5));
            expect(map.getMaxZoom(), equals(10));

            map.removeLayer(tiles[1]);
            expect(map.getMinZoom(), equals(0));
            expect(map.getMaxZoom(), equals(double.INFINITY));
          });
        });
      });
    });
  });
}