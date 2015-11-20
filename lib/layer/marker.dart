part of leaflet;
/*
class MarkerOptions {
  /// Icon class to use for rendering the marker. See Icon documentation for
  /// details on how to customize the marker icon. Set to new Icon.Default()
  /// by default.
  Icon icon;

  /// If false, the marker will not emit mouse events and will act as a part
  /// of the underlying map.
  bool clickable;

  /// Whether the marker is draggable with mouse/touch or not. Default: false
  bool draggable;

  /// Whether the marker can be tabbed to with a keyboard and clicked by
  /// pressing enter. Default: true
  bool keyboard;

  /// Text for the browser tooltip that appear on marker hover (no tooltip by
  /// default).
  String title;

  /// Text for the alt attribute of the icon image (useful for accessibility).
  String alt;

  /// By default, marker images zIndex is set automatically based on its
  /// latitude. Use this option if you want to put the marker on top of all
  /// others (or below), specifying a high value like 1000 (or high negative
  /// value, respectively).
  num zIndexOffset;

  /// The opacity of the marker. Default: 1.0
  num opacity;

  /// If true, the marker will get on top of others when you hover the mouse
  /// over it.
  bool riseOnHover;

  /// The z-index offset used for the riseOnHover feature. Default: 250
  num riseOffset;

  Point2D offset;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (icon != null) m['icon'] = icon._icon;
    if (clickable != null) m['clickable'] = clickable;
    if (draggable != null) m['draggable'] = draggable;
    if (keyboard != null) m['keyboard'] = keyboard;
    if (title != null) m['title'] = title;
    if (alt != null) m['alt'] = alt;
    if (zIndexOffset != null) m['zIndexOffset'] = zIndexOffset;
    if (opacity != null) m['opacity'] = opacity;
    if (riseOnHover != null) m['riseOnHover'] = riseOnHover;
    if (riseOffset != null) m['riseOffset'] = riseOffset;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}
*/

/// Marker is used to display clickable/draggable icons on the map.
class Marker implements Layer {
  JsObject _L, _layer;

  Marker(LatLng latlng,
      {

      /// Icon class to use for rendering the marker. See Icon documentation for
      /// details on how to customize the marker icon. Set to new Icon.Default()
      /// by default.
      Icon icon,

      /// If false, the marker will not emit mouse events and will act as a part
      /// of the underlying map.
      bool clickable,

      /// Whether the marker is draggable with mouse/touch or not. Default: false
      bool draggable,

      /// Whether the marker can be tabbed to with a keyboard and clicked by
      /// pressing enter. Default: true
      bool keyboard,

      /// Text for the browser tooltip that appear on marker hover (no tooltip by
      /// default).
      String title,

      /// Text for the alt attribute of the icon image (useful for accessibility).
      String alt,

      /// By default, marker images zIndex is set automatically based on its
      /// latitude. Use this option if you want to put the marker on top of all
      /// others (or below), specifying a high value like 1000 (or high negative
      /// value, respectively).
      num zIndexOffset,

      /// The opacity of the marker. Default: 1.0
      num opacity,

      /// If true, the marker will get on top of others when you hover the mouse
      /// over it.
      bool riseOnHover,

      /// The z-index offset used for the riseOnHover feature. Default: 250
      num riseOffset,
      Point2D offset}) {
    _L = context['L'];

    var m = {};
    if (icon != null) m['icon'] = icon._icon;
    if (clickable != null) m['clickable'] = clickable;
    if (draggable != null) m['draggable'] = draggable;
    if (keyboard != null) m['keyboard'] = keyboard;
    if (title != null) m['title'] = title;
    if (alt != null) m['alt'] = alt;
    if (zIndexOffset != null) m['zIndexOffset'] = zIndexOffset;
    if (opacity != null) m['opacity'] = opacity;
    if (riseOnHover != null) m['riseOnHover'] = riseOnHover;
    if (riseOffset != null) m['riseOffset'] = riseOffset;
    if (offset != null) m['offset'] = offset;

    var args = [latlng._latlng, new JsObject.jsify(m)];
    _layer = _L.callMethod('marker', args);
  }
}
