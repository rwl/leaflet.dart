
// Path is a base class for rendering vector paths on a map. Inherited by Polyline, Circle, etc.
class Path extends Object with Events {
  // how much to extend the clip area around the map view
  // (relative to its size, e.g. 0.5 is half the screen in each direction)
  // set it so that SVG element doesn't exceed 1280px (vectors flicker on dragend if it is)
  static var CLIP_PADDING = (() {
    var max = L.Browser.mobile ? 1280 : 2000,
        target = (max / Math.max(window.outerWidth, window.outerHeight) - 1) / 2;
    return Math.max(0, Math.min(0.5, target));
  })();

  var options = {
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
  };

  Path(options) {
    L.setOptions(this, options);
  }

  onAdd(map) {
    this._map = map;

    if (!this._container) {
      this._initElements();
      this._initEvents();
    }

    this.projectLatlngs();
    this._updatePath();

    if (this._container) {
      this._map._pathRoot.appendChild(this._container);
    }

    this.fire('add');

    map.on({
      'viewreset': this.projectLatlngs,
      'moveend': this._updatePath
    }, this);
  }

  addTo(map) {
    map.addLayer(this);
    return this;
  }

  onRemove(map) {
    map._pathRoot.removeChild(this._container);

    // Need to fire remove event before we set _map to null as the event hooks might need the object
    this.fire('remove');
    this._map = null;

    if (L.Browser.vml) {
      this._container = null;
      this._stroke = null;
      this._fill = null;
    }

    map.off({
      'viewreset': this.projectLatlngs,
      'moveend': this._updatePath
    }, this);
  }

  projectLatlngs() {
    // do all projection stuff here
  }

  setStyle(style) {
    L.setOptions(this, style);

    if (this._container) {
      this._updateStyle();
    }

    return this;
  }

  redraw() {
    if (this._map) {
      this.projectLatlngs();
      this._updatePath();
    }
    return this;
  }
}