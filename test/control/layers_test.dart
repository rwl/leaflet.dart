
import 'dart:html' show document;

import 'package:leaflet/map/map.dart' show LeafletMap;
import 'package:leaflet/core/core.dart' show EventType, Event, Action;
import 'package:leaflet/control/control.dart' show Layers;
import 'package:leaflet/layer/tile/tile.dart' show TileLayer;
import 'package:leaflet/layer/marker/marker.dart' show Marker;
import 'package:leaflet/geo/geo.dart' show LatLng;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';


main() {
  useHtmlEnhancedConfiguration();

  group('Control.Layers', () {
    LeafletMap map;

    bool called;
    List<Object> objs;
    List<Event> events;
    Action action = (Object obj, Event e) {
      called = true;
      objs.add(obj);
      events.add(e);
    };

    setUp(() {
      map = new LeafletMap(document.createElement('div'));
      called = false;
      objs = new List<Object>();
      events = new List<Event>();
    });

    group('baselayerchange event', () {
      test('is fired on input that changes the base layer', () {
        final baseLayers = {'Layer 1': new TileLayer(), 'Layer 2': new TileLayer()},
          layers = new Layers(baseLayers)..addTo(map);
          //spy = sinon.spy();


        map.on(EventType.BASELAYERCHANGE, action)
          ..whenReady(() {
            happen.click(layers.baseLayersList.querySelectorAll('input')[0]);

            expect(called, isTrue);
            expect(events[0].layer, equals(baseLayers['Layer 1']));
          });
      });

      test('is not fired on input that doesn\'t change the base layer', () {
        final overlays = {'Marker 1': new Marker(new LatLng(0, 0)),
                          'Marker 2': new Marker(new LatLng(0, 0))};
        final layers = new Layers({}, overlays)..addTo(map);
          //spy = sinon.spy();

        map.on(EventType.BASELAYERCHANGE, action);
        happen.click(layers._overlaysList.getElementsByTagName('input')[0]);

        expect(called, isFalse);
      });
    });

    group('updates', () {
      setUp(() {
        map.setView(new LatLng(0, 0), 14);
      });

      test('when an included layer is addded or removed', () {
        final baseLayer = new TileLayer(),
          overlay = new Marker(new LatLng(0, 0)),
          layers = new Layers({'Base': baseLayer}, {'Overlay': overlay})..addTo(map);

        //var spy = sinon.spy(layers, '_update');

        map.addLayer(overlay);
        map.removeLayer(overlay);

        expect(spy.called, isTrue);
        expect(spy.callCount, equals(2));
      });

      test('not when a non-included layer is added or removed', () {
        final baseLayer = new TileLayer(),
          overlay = new Marker(new LatLng(0, 0)),
          layers = new Layers({'Base': baseLayer})..addTo(map);

        //var spy = sinon.spy(layers, '_update');

        map.addLayer(overlay);
        map.removeLayer(overlay);

        expect(spy.called, isFalse);
      });
    });
  });
}