part of leaflet;

/// Represents an object attached to a particular location (or a set of
/// locations) on a map.
abstract class Layer {
  /// For internal use.
  JsObject get layer;

  /// Should contain code that creates DOM elements for the overlay, adds them
  /// to map panes where they should belong and puts listeners on relevant map
  /// events. Called on map.addLayer(layer).
//  onAdd(LeafletMap map);

  /// Should contain all clean up code that removes the overlay's elements from
  /// the DOM and removes listeners previously added in onAdd. Called on
  /// map.removeLayer(layer).
//  onRemove(LeafletMap map);

//  String getAttribution();
}

class _AbstractLayer implements Layer {
  final JsObject layer;
  _AbstractLayer._(this.layer);
}

/// LayerGroup is a class to combine several layers into one so that
/// you can manipulate the group (e.g. add/remove it) as one layer.
class LayerGroup implements Layer {
  final JsObject layer;

  /// For internal use.
  LayerGroup.wrap(this.layer);

  /// Iterates over the layers of the group.
  void eachLayer(fn(Layer layer)) {
    _fn(JsObject l) {
      var ll = new _AbstractLayer._(l);
      fn(ll);
    }
    layer.callMethod('eachLayer', [_fn]);
  }
}

/// FeatureGroup extends LayerGroup by introducing mouse events and
/// additional methods shared between a group of interactive layers
/// (like vectors or markers).
class FeatureGroup extends LayerGroup {
  /// Create a layer group, optionally given an initial set of layers.
  factory FeatureGroup([List<Layer> layers]) {
    var L = context['L'];
    var args = [];
    if (layers != null) {
      args.add(layers.map((l) => l.layer).toList());
    }
    var layer = L.callMethod('featureGroup', args);
    return new FeatureGroup._(layer);
  }

  FeatureGroup._(JsObject layer) : super.wrap(layer);

  void addLayer(Layer l) {
    layer.callMethod('addLayer', [l.layer]);
  }

  void bindPopup(String content, [PopupOptions options]) {
    var args = [content];
    if (options != null) {
      args.add(options.jsify());
    }
    layer.callMethod('bindPopup', args);
  }
}

class PopupOptions {
  /// Max width of the popup. Default: 300
  num maxWidth;

  /// Min width of the popup. Default: 50
  num minWidth;

  /// If set, creates a scrollable container of the given height inside a
  /// popup if its content exceeds it.
  num maxHeight;

  /// Set it to false if you don't want the map to do panning animation to
  /// fit the opened popup.
  bool autoPan;

  /// Set it to true if you want to prevent users from panning the popup off
  /// of the screen while it is open.
  bool keepInView;

  /// Controls the presense of a close button in the popup. Default: true
  bool closeButton;

  /// The offset of the popup position. Useful to control the anchor of the
  /// popup when opening it on some overlays.
  Point2D offset;

  /// The margin between the popup and the top left corner of the map view
  /// after autopanning was performed.
  Point2D autoPanPaddingTopLeft;

  /// The margin between the popup and the bottom right corner of the map
  /// view after autopanning was performed.
  Point2D autoPanPaddingBottomRight;

  /// Equivalent of setting both top left and bottom right autopan padding to
  /// the same value.
  Point2D autoPanPadding;

  /// Whether to animate the popup on zoom. Disable it if you have problems
  /// with Flash content inside popups.
  bool zoomAnimation = true;

  /// Set it to false if you want to override the default behavior of the
  /// popup closing when user clicks the map (set globally by the Map
  /// closePopupOnClick option).
  bool closeOnClick;

  /// A custom class name to assign to the popup.
  String className = '';
  LatLngBounds bounds;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (maxWidth != null) m['maxWidth'] = maxWidth;
    if (minWidth != null) m['minWidth'] = minWidth;
    if (maxHeight != null) m['maxHeight'] = maxHeight;
    if (autoPan != null) m['autoPan'] = autoPan;
    if (keepInView != null) m['keepInView'] = keepInView;
    if (closeButton != null) m['closeButton'] = closeButton;
    if (offset != null) m['offset'] = offset;
    if (autoPanPaddingTopLeft != null) m['autoPanPaddingTopLeft'] =
        autoPanPaddingTopLeft;
    if (autoPanPaddingBottomRight != null) m['autoPanPaddingBottomRight'] =
        autoPanPaddingBottomRight;
    if (autoPanPadding != null) m['autoPanPadding'] = autoPanPadding;
    if (zoomAnimation != null) m['zoomAnimation'] = zoomAnimation;
    if (closeOnClick != null) m['closeOnClick'] = closeOnClick;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}
