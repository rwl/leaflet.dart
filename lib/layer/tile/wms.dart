part of leaflet.layer.tile;

class WMSOptions {
  /**
   * Comma-separated list of WMS layers to show (required).
   */
  String layers = '';

  /**
   * Comma-separated list of WMS styles.
   */
  String styles  = '';

  /**
   * WMS image format (use 'image/png' for layers with transparency).
   */
  String format = 'image/jpeg';

  /**
   * If true, the WMS service will return images with transparency.
   */
  bool transparent = false;

  /**
   * Version of the WMS service to use.
   */
  String version = '1.1.1';

  /**
   * Coordinate Reference System to use for the WMS requests, defaults to
   * map CRS. Don't change this if you're not sure what it means.
   */
  CRS crs;
}

// WMS is used for putting WMS tile layers on the map.
class WMS extends TileLayer {
  var defaultWmsParams = {
    'service': 'WMS',
    'request': 'GetMap',
    'version': '1.1.1',
    'layers': '',
    'styles': '',
    'format': 'image/jpeg',
    'transparent': false
  };

  WMS(url, options) { // (String, Object)

    this._url = url;

    var wmsParams = L.extend({}, this.defaultWmsParams),
        tileSize = options.tileSize || this.options.tileSize;

    if (options.detectRetina && L.Browser.retina) {
      wmsParams.width = wmsParams.height = tileSize * 2;
    } else {
      wmsParams.width = wmsParams.height = tileSize;
    }

    for (var i in options) {
      // all keys that are not TileLayer options go to WMS params
      if (!this.options.hasOwnProperty(i) && i != 'crs') {
        wmsParams[i] = options[i];
      }
    }

    this.wmsParams = wmsParams;

    L.setOptions(this, options);
  }

  onAdd(map) {

    this._crs = this.options.crs || map.options.crs;

    this._wmsVersion = parseFloat(this.wmsParams.version);

    var projectionKey = this._wmsVersion >= 1.3 ? 'crs' : 'srs';
    this.wmsParams[projectionKey] = this._crs.code;

    L.TileLayer.prototype.onAdd.call(this, map);
  }

  getTileUrl(tilePoint) { // (Point, Number) -> String

    var map = this._map,
        tileSize = this.options.tileSize,

        nwPoint = tilePoint.multiplyBy(tileSize),
        sePoint = nwPoint.add([tileSize, tileSize]),

        nw = this._crs.project(map.unproject(nwPoint, tilePoint.z)),
        se = this._crs.project(map.unproject(sePoint, tilePoint.z)),
        bbox = this._wmsVersion >= 1.3 && this._crs == L.CRS.EPSG4326 ?
            [se.y, nw.x, nw.y, se.x].join(',') :
            [nw.x, se.y, se.x, nw.y].join(','),

        url = L.Util.template(this._url, {s: this._getSubdomain(tilePoint)});

    return url + L.Util.getParamString(this.wmsParams, url, true) + '&BBOX=' + bbox;
  }

  setParams(params, noRedraw) {

    L.extend(this.wmsParams, params);

    if (!noRedraw) {
      this.redraw();
    }

    return this;
  }
}