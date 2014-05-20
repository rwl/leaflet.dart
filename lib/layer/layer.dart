library leaflet.layer;

import 'dart:html';
import 'dart:math' as math show min, max;

import '../core/core.dart' as core;
import '../core/core.dart' show EventType, Browser;
import '../dom/dom.dart';
import '../map/map.dart';
import '../geo/geo.dart';
import '../geometry/geometry.dart' as geom;
import './marker/marker.dart';

part 'feature_group.dart';
part 'geo_json.dart';
part 'image_overlay.dart';
part 'layer_group.dart';
part 'popup.dart';

// Represents an object attached to a particular location (or a set of
// locations) on a map.
abstract class Layer {
  // Should contain code that creates DOM elements for the overlay, adds them
  // to map panes where they should belong and puts listeners on relevant map
  // events. Called on map.addLayer(layer).
  onAdd(BaseMap map);

  // Should contain all clean up code that removes the overlay's elements from
  // the DOM and removes listeners previously added in onAdd. Called on
  // map.removeLayer(layer).
  onRemove(BaseMap map);
}
