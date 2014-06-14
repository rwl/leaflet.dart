part of leaflet.layer.vector;

class PathOptions {
  /**
   * Whether to draw stroke along the path. Set it to false to disable borders on polygons or circles.
   */
  bool stroke = true;

  /**
   * Stroke color.
   */
  String color = '#03f';

  /**
   * Stroke width in pixels.
   */
  num weight  = 5;

  /**
   * Stroke opacity.
   */
  num opacity = 0.5;

  /**
   * Whether to fill the path with color. Set it to false to disable filling on polygons or circles.
   */
  bool fill;

  /**
   * Same as color Fill color.
   */
  String fillColor;

  /**
   * Fill opacity.
   */
  num fillOpacity = 0.2;

  /**
   * A string that defines the stroke dash pattern. Doesn't work on canvas-powered layers (e.g. Android 2).
   */
  String  dashArray;

  /**
   * A string that defines shape to be used at the end of the stroke.
   */
  String lineCap;

  /**
   * A string that defines shape to be used at the corners of the stroke.
   */
  String lineJoin;

  /**
   * If false, the vector will not emit mouse events and will act as a part of the underlying map.
   */
  bool clickable = true;

  /**
   * Sets the pointer-events attribute on the path if SVG backend is used.
   */
  String pointerEvents;

  /**
   * Custom class name set on an element.
   */
  String className = '';
}

/**
 * Path is a base class for rendering vector paths on a map. Inherited by Polyline, Circle, etc.
 */
abstract class Path extends Object with Events {

  // how much to extend the clip area around the map view
  // (relative to its size, e.g. 0.5 is half the screen in each direction)
  // set it so that SVG element doesn't exceed 1280px (vectors flicker on dragend if it is)
  static var CLIP_PADDING = (() {
    var max = Browser.mobile ? 1280 : 2000,
        target = (max / math.max(window.outerWidth, window.outerHeight) - 1) / 2;
    return math.max(0, math.min(0.5, target));
  })();

  /*Map<String, Object> options = {
    'stroke': true,
    'color': '#0033ff',
    'dashArray': null,
    'lineCap': null,
    'lineJoin': null,
    'weight': 5,
    'opacity': 0.5,

    'fill': false,
    'fillColor': null, //same as color by default
    'fillOpacity': 0.2,

    'clickable': true
  };*/
  PathOptions options;

  BaseMap _map;
  var _container, _stroke, _fill;

  Path(this.options) ;

  onAdd(BaseMap map) {
    _map = map;

    if (_container == null) {
      this._initElements();
      this._initEvents();
    }

    projectLatlngs();
    this._updatePath();

    if (_container != null) {
      _map._pathRoot.append(_container);
    }

    fire(EventType.ADD);

    map.on(EventType.VIEWRESET, projectLatlngs, this);
    map.on(EventType.MOVEEND, this._updatePath, this);
  }

  /**
   * Adds the layer to the map.
   */
  addTo(BaseMap map) {
    map.addLayer(this);
    return this;
  }

  onRemove(BaseMap map) {
    map._pathRoot.removeChild(_container);

    // Need to fire remove event before we set _map to null as the event hooks might need the object
    fire(EventType.REMOVE);
    _map = null;

    if (Browser.vml) {
      _container = null;
      _stroke = null;
      _fill = null;
    }

    map.off(EventType.VIEWRESET, projectLatlngs, this);
    map.off(EventType.MOVEEND, this._updatePath, this);
  }

  projectLatlngs() {
    // do all projection stuff here
  }

  /**
   * Changes the appearance of a Path based on the options in the Path options object.
   */
  setStyle(PathOptions style) {
    options = style;

    if (_container) {
      _updateStyle();
    }

    return this;
  }

  /**
   * Redraws the layer. Sometimes useful after you changed the coordinates that the path uses.
   */
  redraw() {
    if (_map != null) {
      projectLatlngs();
      this._updatePath();
    }
    return this;
  }

  /**
   * Binds a popup with a particular HTML content to a click on this path.
   */
  bindPopupHtml(String html, PopupOptions options);

  bindPopupElement(Element el);

  /**
   * Binds a given popup object to the path.
   */
  bindPopup(Popup popup, PopupOptions options);

  /**
   * Unbinds the popup previously bound to the path with bindPopup.
   */
  unbindPopup();

  /**
   * Opens the popup previously bound by the bindPopup method in the given point, or in one of the path's points if not specified.
   */
  openPopup(LatLng latlng);

  /**
   * Closes the path's bound popup if it is opened.
   */
  closePopup();

  /**
   * Returns the LatLngBounds of the path.
   */
  LatLngBounds getBounds();

  /**
   * Brings the layer to the top of all path layers.
   */
  void bringToFront();

  /**
   * Brings the layer to the bottom of all path layers.
   */
  void bringToBack();

}