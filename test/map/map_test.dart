library leaflet.map.test;

import 'dart:async' show Future, Completer;
import 'dart:html' show document;
import 'dart:html' as html show Event, MouseEvent, Element;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/map/map.dart' show LeafletMap, MapOptions,
    ZoomPanOptions, containerProp;
import 'package:leaflet/geo/geo.dart' show LatLng, LatLngBounds;
import 'package:leaflet/core/core.dart' show Event, EventType, MapEvent, LayerEvent;
import 'package:leaflet/layer/layer.dart' show Layer;
import 'package:leaflet/layer/tile/tile.dart' show TileLayer, TileLayerOptions;

mapTest() {
  group('Map', () {
    LeafletMap map;
    bool called;
    Completer<bool> comp1, comp2;
    Function c1, c2;

    setUp(() {
      map = new LeafletMap(document.createElement('div'));
      called = false;
      comp1 = new Completer();
      comp2 = new Completer();
      c1 = () {
        if (!comp1.isCompleted) {
          comp1.complete(false);
        }
      };
      c2 = () {
        if (!comp2.isCompleted) {
          comp2.complete(false);
        }
      };
    });

//    tearDown(() {
//      if (!comp1.isCompleted) {
//        comp1.complete(false);
//      }
//      if (!comp2.isCompleted) {
//        comp2.complete(false);
//      }
//    });

    group('remove', () {
      test('fires an unload event if loaded', () {
        final container = document.createElement('div'),
          map = new LeafletMap(container)..setView(new LatLng(0, 0), 0);
        map.onUnload.listen((_) {
          comp1.complete(true);
        });
        map.remove();
        expect(comp1.future, completion(isTrue));
      });

      test('fires no unload event if not loaded', () {
        final container = document.createElement('div'),
            map = new LeafletMap(container);
        map.onUnload.listen((_) {
          comp1.complete(true);
        });
        map.remove();
        expect(comp1.future, completion(isFalse));
        new Future.delayed(new Duration(milliseconds: 33), c1);
      });

      group('corner case checking', () {
        test('throws an exception upon reinitialization', () {
          final container = document.createElement('div'),
            map = new LeafletMap(container);
          expect(() {
            new LeafletMap(container);
          }, throws);
          map.remove();
        });

        test('throws an exception if a container is not found', () {
          expect(() {
            new LeafletMap.query('#nonexistentdivelement');
          }, throws);
          map.remove();
        });
      });

      test('undefines container._leaflet', () {
        final container = document.createElement('div'),
            map = new LeafletMap(container);
        expect(containerProp[container], isNotNull);
        map.remove();
        expect(containerProp[container], isNull);
      });

      test('unbinds events', () {
        final container = document.createElement('div'),
            map = new LeafletMap(container)..setView(new LatLng(0, 0), 1);

        final fn = (_) {
          comp1.complete(true);
        };
        map.onClick.listen(fn);
        map.onDblClick.listen(fn);
        map.onMouseDown.listen(fn);
        map.onMouseUp.listen(fn);
        map.onMouseMove.listen(fn);
        map.remove();

        container.dispatchEvent(new html.MouseEvent('click'));
        container.dispatchEvent(new html.MouseEvent('dblclick'));
        container.dispatchEvent(new html.MouseEvent('mousedown'));
        container.dispatchEvent(new html.MouseEvent('mouseup'));
        container.dispatchEvent(new html.MouseEvent('mousemove'));

        expect(comp1.future, completion(isFalse));
        new Future.delayed(new Duration(milliseconds: 33), c1);
      });
    });


    group('getCenter', () {
      test('throws if not set before', () {
        expect(() => map.getCenter(), throwsException);
      });

      test('returns a precise center when zoomed in after being set', () {
        final center = new LatLng(10, 10);
        map.setView(center, 1);
        map.setZoom(19);
        expect(map.getCenter(), equals(center));
      });

      test('returns correct center after invalidateSize (#1919)', () {
        map.setView(new LatLng(10, 10), 1);
        map.invalidateSize();
        expect(map.getCenter(), isNot(equals(new LatLng(10, 10))));
      });
    });

    group('whenReady', () {
      group('when the map has not yet been loaded', () {
        test('calls the callback when the map is loaded', () {
          map.whenReady((_) {
            if (!comp1.isCompleted) {
              comp1.complete(true);
            }
            comp2.complete(true);
          });
          expect(comp1.future, completion(isFalse));
          new Future.delayed(new Duration(milliseconds: 33), c1).then((_) {
            map.setView(new LatLng(0, 0), 1);
            expect(comp2.future, completion(isTrue));
            new Future.delayed(new Duration(milliseconds: 33), c2);
          });
        });
      });

      group('when the map has already been loaded', () {
        test('calls the callback immediately', () {
          map.setView(new LatLng(0, 0), 1);
          map.whenReady((_) {
            comp1.complete(true);
          });

          expect(comp1.future, completion(isTrue));
        });
      });/*
    });

    group('setView', () {
      test('sets the view of the map', () {
        expect(map..setView(new LatLng(51.505, -0.09), 13), equals(map));
        expect(map.getZoom(), equals(13));
        expect(map.getCenter().distanceTo(new LatLng(51.505, -0.09)),
            lessThan(5));
      });
      test('can be passed without a zoom specified', () {
        map.setZoom(13);
        expect(map..setView(new LatLng(51.605, -0.11), null), equals(map));
        expect(map.getZoom(), equals(13));
        expect(map.getCenter().distanceTo(new LatLng(51.605, -0.11)),
            lessThan(5));
      });
    });

    group('getBounds', () {
      test('is safe to call from within a moveend callback during initial '
          'load (#1027)', () {
        map.onMoveEnd.listen((MapEvent e) {
          map.getBounds();
        });

        map.setView(new LatLng(51.505, -0.09), 13);
      });
    });

    group('setMaxBounds', () {
      test('aligns pixel-wise map view center with maxBounds center if it '
          'cannot move view bounds inside maxBounds (#1908)', () {
        final container = map.getContainer();
        // Large view, cannot fit within maxBounds.
        container.style.width = container.style.height = '1000px';
        document.body.append(container);
        // maxBounds
        final bounds = new LatLngBounds.between(
            new LatLng(51.5, -0.05), new LatLng(51.55, 0.05));
        map.setMaxBounds(bounds/*, {'animate': false}*/);
        // Set view outside.
        map.setView(new LatLng(53.0, 0.15), 12/*, {'animate': false}*/);
        // Get center of bounds in pixels.
        var boundsCenter = map.project(bounds.getCenter()).rounded();
        expect(map.project(map.getCenter()).rounded(), equals(boundsCenter));
        //document.body.removeChild(container);
        container.remove();
      });
      test('moves map view within maxBounds by changing one coordinate', () {
        var container = map.getContainer();
        // Small view, can fit within maxBounds.
        container.style.width = container.style.height = '200px';
        document.body.append(container);
        // maxBounds
        final bounds =
            new LatLngBounds.between(new LatLng(51, -0.2), new LatLng(52, 0.2));
        map.setMaxBounds(bounds/*, {'animate': false}*/);
        // Set view outside maxBounds on one direction only
        // leaves untouched the other coordinate (that is not already centered).
        final initCenter = new LatLng(53.0, 0.1);
        map.setView(initCenter, 16, new ZoomPanOptions()..animate = false/*, {'animate': false}*/);
        // one pixel coordinate hasn't changed, the other has
        final pixelCenter = map.project(map.getCenter()).rounded();
        final pixelInit = map.project(initCenter).rounded();
        expect(pixelCenter.x, equals(pixelInit.x));
        expect(pixelCenter.y, equals(pixelInit.y));
        // The view is inside the bounds.
        expect(bounds.containsBounds(map.getBounds()), isTrue);
        //document.body.removeChild(container);
        container.remove();
      });
    });

    group('getMinZoom and getMaxZoom', () {
      group('#getMinZoom', () {
        test('returns 0 if not set by Map options or TileLayer options', () {
          final map = new LeafletMap(document.createElement('div'));
          expect(map.getMinZoom(), equals(0));
        });
      });

      test('minZoom and maxZoom options overrides any minZoom and maxZoom set '
          'on layers', () {

        final map = new LeafletMap(document.createElement('div'),
            new MapOptions()..minZoom=2..maxZoom=20);

        new TileLayer('{z}{x}{y}',
            new TileLayerOptions()..minZoom = 4..maxZoom = 10).addTo(map);
        new TileLayer('{z}{x}{y}',
            new TileLayerOptions()..minZoom = 6..maxZoom = 17).addTo(map);
        new TileLayer('{z}{x}{y}',
            new TileLayerOptions()..minZoom = 0..maxZoom = 22).addTo(map);

        expect(map.getMinZoom(), equals(2));
        expect(map.getMaxZoom(), equals(20));
      });
    });

    group('addLayer', () {
      test('calls layer.onAdd immediately if the map is ready', () {
        var layer = new TestLayer();
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        expect(layer.addCalled, isTrue);
      });

      test('calls layer.onAdd when the map becomes ready', () {
        var layer = new TestLayer();
        map.addLayer(layer);
        expect(layer.addCalled, isFalse);
        map.setView(new LatLng(0, 0), 0);
        expect(layer.addCalled, isTrue);
      });

      test('does not call layer.onAdd if the layer is removed before the map becomes ready', () {
        var layer = new TestLayer();
        map.addLayer(layer);
        map.removeLayer(layer);
        map.setView(new LatLng(0, 0), 0);
        expect(layer.addCalled, isFalse);
      });

      test('fires a layeradd event immediately if the map is ready', () {
        var layer = new TestLayer();
        map.onLayerAdd.listen((_) {
          called = true;
        });
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        expect(called, isTrue);
      });

      test('fires a layeradd event when the map becomes ready', () {
        var layer = new TestLayer();
        map.onLayerAdd.listen((_) {
          called = true;
        });
        map.addLayer(layer);
        expect(called, isFalse);
        map.setView(new LatLng(0, 0), 0);
        expect(called, isTrue);
      });

      test('does not fire a layeradd event if the layer is removed before the map becomes ready', () {
        var layer = new TestLayer();
        map.onLayerAdd.listen((_) {
          called = true;
        });
        map.addLayer(layer);
        map.removeLayer(layer);
        map.setView(new LatLng(0, 0), 0);
        expect(called, isFalse);
      });

      test('adds the layer before firing layeradd', (/*done*/) {
        var layer = new TestLayer();
        map.onLayerAdd.listen((LayerEvent e) {
          expect(map.hasLayer(layer), isTrue);
//          done();
        });
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
      });

      group('When the first layer is added to a map', () {
        test('fires a zoomlevelschange event', () {
          map.onZoomLevelsChange.listen((_) {
            called = true;
          });
          expect(called, isFalse);
          new TileLayer('{z}{x}{y}', new TileLayerOptions()
            ..minZoom = 0
            ..maxZoom = 10).addTo(map);
          expect(called, isTrue);
        });
      });

      group('when a new layer with greater zoomlevel coverage than the current layer is added to a map', () {
        test('fires a zoomlevelschange event', () {
          new TileLayer('{z}{x}{y}', new TileLayerOptions()
            ..minZoom = 0
            ..maxZoom = 10).addTo(map);
          map.onZoomLevelsChange.listen((_) {
            called = true;
          });
          expect(called, isFalse);
          new TileLayer('{z}{x}{y}', new TileLayerOptions()
            ..minZoom = 0
            ..maxZoom = 15).addTo(map);
          expect(called, isTrue);
        });
      });

      group('when a new layer with the same or lower zoomlevel coverage as the current layer is added to a map', () {
        test('fires no zoomlevelschange event', () {
          new TileLayer('{z}{x}{y}', new TileLayerOptions()
            ..minZoom = 0
            ..maxZoom = 10).addTo(map);
          map.onZoomLevelsChange.listen((_) {
            called = true;
          });
          expect(called, isFalse);
          new TileLayer('{z}{x}{y}', new TileLayerOptions()
            ..minZoom = 0
            ..maxZoom = 10).addTo(map);
          expect(called, isFalse);
          new TileLayer('{z}{x}{y}', new TileLayerOptions()
            ..minZoom = 0
            ..maxZoom = 5).addTo(map);
          expect(called, isFalse);
        });
      });
    });

    group('removeLayer', () {
      test('calls layer.onRemove if the map is ready', () {
        final layer = new TestLayer();
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(layer.removeCalled, isTrue);
      });

      test('does not call layer.onRemove if the layer was not added', () {
        var layer = new TestLayer();
        map.setView(new LatLng(0, 0), 0);
        map.removeLayer(layer);
        expect(layer.removeCalled, isFalse);
      });

      test('does not call layer.onRemove if the map is not ready', () {
        var layer = new TestLayer();
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(layer.removeCalled, isFalse);
      });

      test('fires a layerremove event if the map is ready', () {
        var layer = new TestLayer();
        map.onLayerRemove.listen((_) {
          called = true;
        });
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(called, isTrue);
      });

      test('does not fire a layerremove if the layer was not added', () {
        var layer = new TestLayer();
        map.onLayerRemove.listen((_) {
          called = true;
        });
        map.setView(new LatLng(0, 0), 0);
        map.removeLayer(layer);
        expect(called, isFalse);
      });

      test('does not fire a layerremove if the map is not ready', () {
        var layer = new TestLayer();
        map.onLayerRemove.listen((_) {
          called = true;
        });
        map.addLayer(layer);
        map.removeLayer(layer);
        expect(called, isFalse);
      });

      test('removes the layer before firing layerremove', (/*done*/) {
        var layer = new TestLayer();
        map.onLayerRemove.listen((_) {
          expect(map.hasLayer(layer), isFalse);
//          done();
        });
        map.setView(new LatLng(0, 0), 0);
        map.addLayer(layer);
        map.removeLayer(layer);
      });

      group('when the last tile layer on a map is removed', () {
        test('fires a zoomlevelschange event', () {
          map.whenReady((_) {
            final tl = new TileLayer('{z}{x}{y}', new TileLayerOptions()
              ..minZoom = 0
              ..maxZoom = 10)..addTo(map);

            map.onZoomLevelsChange.listen((_) {
              called = true;
            });
            expect(called, isFalse);
            map.removeLayer(tl);
            expect(called, isTrue);
          });
        });
      });

      group('when a tile layer is removed from a map and it had greater zoom level coverage than the remainding layer', () {
        test('fires a zoomlevelschange event', () {
          map.whenReady((_) {
            final tl = new TileLayer('{z}{x}{y}', new TileLayerOptions()
              ..minZoom = 0
              ..maxZoom = 10)..addTo(map);
            final t2 = new TileLayer('{z}{x}{y}', new TileLayerOptions()
              ..minZoom = 0
              ..maxZoom = 15)..addTo(map);

            map.onZoomLevelsChange.listen((_) {
              called = true;
            });
            expect(called, isFalse);
            map.removeLayer(t2);
            expect(called, isTrue);
          });
        });
      });

      group('when a tile layer is removed from a map it and it had lesser or the sa,e zoom level coverage as the remainding layer(s)', () {
        test('fires no zoomlevelschange event', () {
          map.whenReady((_) {
            final tl = new TileLayer('{z}{x}{y}', new TileLayerOptions()
              ..minZoom = 0
              ..maxZoom = 10)..addTo(map);
            final t2 = new TileLayer('{z}{x}{y}', new TileLayerOptions()
              ..minZoom = 0
              ..maxZoom = 10)..addTo(map);
            final t3 = new TileLayer('{z}{x}{y}', new TileLayerOptions()
              ..minZoom = 0
              ..maxZoom = 5)..addTo(map);

            map.onZoomLevelsChange.listen((_) {
              called = true;
            });
            expect(called, isFalse);
            map.removeLayer(t2);
            expect(called, isFalse);
            map.removeLayer(t3);
            expect(called, isFalse);
          });
        });
      });
    });

    group('eachLayer', () {
      test('returns self', () {
        expect(map..eachLayer((Layer l) {}), equals(map));
      });

      test('calls the provided function for each layer', () {
        final t1 = new TileLayer('{z}{x}{y}')..addTo(map);
        final t2 = new TileLayer('{z}{x}{y}')..addTo(map);

        final args = [];
        map.eachLayer((Layer l) {
          args.add(l);
        });

        expect(args, hasLength(2));
        expect(args[0], equals(t1));
        expect(args[1], equals(t2));
      });

      /*test('calls the provided function with the provided context', () {
        final t1 = new TileLayer('{z}{x}{y}')..addTo(map);

        map.eachLayer(spy, map);

        expect(spy.thisValues[0], equals(map));
      });*/
    });

    group('invalidateSize', () {
      html.Element container;
      int origWidth = 100;
//        clock;

      setUp(() {
        container = map.getContainer();
        container.style.width = '${origWidth}px';
        document.body.append(container);
        map.setView(new LatLng(0, 0), 0);
        map.invalidateSize(pan: false);
//        clock = sinon.useFakeTimers();
      });

      tearDown(() {
        //document.body.removeChild(container);
        container.remove();
//        clock.restore();
      });

      test('pans by the right amount when growing in 1px increments', () {
        container.style.width = '${origWidth + 1}px';
        map.invalidateSize();
        expect(map.getMapPanePos().x, equals(1));

        container.style.width = '${origWidth + 2}px';
        map.invalidateSize();
        expect(map.getMapPanePos().x, equals(1));

        container.style.width = '${origWidth + 3}px';
        map.invalidateSize();
        expect(map.getMapPanePos().x, equals(2));
      });

      test('pans by the right amount when shrinking in 1px increments', () {
        container.style.width = '${origWidth - 1}px';
        map.invalidateSize();
        expect(map.getMapPanePos().x, equals(0));

        container.style.width = '${origWidth - 2}px';
        map.invalidateSize();
        expect(map.getMapPanePos().x, equals(-1));

        container.style.width = '${origWidth - 3}px';
        map.invalidateSize();
        expect(map.getMapPanePos().x, equals(-1));
      });

      test('pans back to the original position after growing by an odd size and back', () {
        container.style.width = '${origWidth + 5}px';
        map.invalidateSize();

        container.style.width = '${origWidth}px';
        map.invalidateSize();

        expect(map.getMapPanePos().x, equals(0));
      });

      test('emits no move event if the size has not changed', () {
        map.onMove.listen((_) {
          called = true;
        });

        map.invalidateSize();

        expect(called, isFalse);
      });

      test('emits a move event if the size has changed', () {
        map.onMove.listen((_) {
          called = true;
        });

        container.style.width = '${origWidth + 5}px';
        map.invalidateSize();

        expect(called, isTrue);
      });

      test('emits a moveend event if the size has changed', () {
        map.onMoveEnd.listen((_) {
          called = true;
        });

        container.style.width = '${origWidth + 5}px';
        map.invalidateSize();

        expect(called, isTrue);
      });

      test('debounces the moveend event if the debounceMoveend option is given', () {
        map.onMoveEnd.listen((_) {
          called = true;
        });

        container.style.width = '${origWidth + 5}px';
        map.invalidateSize(debounceMoveend: true);

        expect(called, isFalse);

//        clock.tick(200);

        expect(new Future.delayed(new Duration(milliseconds: 200)).then((_) {
          expect(called, isTrue);
        }), completes);
      });*/
    });
  });
}

class TestLayer extends Layer {
  bool removeCalled = false;
  bool addCalled = false;

  onAdd(LeafletMap map) {
    addCalled = true;
  }

  onRemove(LeafletMap map) {
    removeCalled = true;
  }
}

main() {
  //useHtmlEnhancedConfiguration();
  mapTest();
}