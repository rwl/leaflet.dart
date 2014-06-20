part of leaflet.layer.tile;

class WMSOptions extends TileLayerOptions {
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

  num width, height;
}

// WMS is used for putting WMS tile layers on the map.
class WMS extends TileLayer {
  /*var defaultWmsParams = {
    'service': 'WMS',
    'request': 'GetMap',
    'version': '1.1.1',
    'layers': '',
    'styles': '',
    'format': 'image/jpeg',
    'transparent': false
  };*/
  WMSOptions get wmsOptions => options as WMSOptions;

  WMS(String url, WMSOptions options) : super(url, options) {

//    var wmsParams = L.extend({}, this.defaultWmsParams),
    final tileSize = options.tileSize;// || this.options.tileSize;

    if (options.detectRetina && Browser.retina) {
      wmsOptions.width = wmsOptions.height = tileSize * 2;
    } else {
      wmsOptions.width = wmsOptions.height = tileSize;
    }

    /*for (var i in options) {
      // all keys that are not TileLayer options go to WMS params
      if (!this.options.hasOwnProperty(i) && i != 'crs') {
        wmsParams[i] = options[i];
      }
    }*/

//    this.wmsParams = wmsParams;

//    L.setOptions(this, options);
  }

  CRS _crs;
  double _wmsVersion;

  onAdd(BaseMap map) {

    this._crs = this.wmsOptions.crs != null ? wmsOptions.crs : map.stateOptions.crs;

    this._wmsVersion = double.parse(this.wmsOptions.version);

    //var projectionKey = this._wmsVersion >= 1.3 ? 'crs' : 'srs';
    if (_wmsVersion >= 1.3) {
      this.wmsOptions.crs = this._crs.code;
    } else {
      wmsOptions.srs = this._crs.code;
    }

    //L.TileLayer.prototype.onAdd.call(this, map);
    super.onAdd(map);
  }

  getTileUrl(tilePoint) { // (Point, Number) -> String

    final map = this._map,
        tileSize = this.options.tileSize,

        nwPoint = tilePoint.multiplyBy(tileSize),
        sePoint = nwPoint.add([tileSize, tileSize]),

        nw = this._crs.project(map.unproject(nwPoint, tilePoint.z)),
        se = this._crs.project(map.unproject(sePoint, tilePoint.z)),
        bbox = this._wmsVersion >= 1.3 && this._crs == EPSG4326 ?
            [se.y, nw.x, nw.y, se.x].join(',') :
            [nw.x, se.y, se.x, nw.y].join(','),

        url = core.template(this._url, {'s': this._getSubdomain(tilePoint)});

    return url + core.getParamString(this.wmsOptions, url, true) + '&BBOX=' + bbox;
  }

  /**
   * Merges an object with the new parameters and re-requests tiles on the
   * current screen (unless noRedraw was set to true).
   */
  setParams(WMSOptions params, bool noRedraw) {

    //L.extend(this.wmsParams, params);
    wmsOptions.merge(params);

    if (!noRedraw) {
      this.redraw();
    }
  }
}