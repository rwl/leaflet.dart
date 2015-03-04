part of leaflet.layer.tile;

class WMSOptions extends TileLayerOptions {
  /// Comma-separated list of WMS layers to show (required).
  String layers = '';

  /// Comma-separated list of WMS styles.
  String styles  = '';

  /// WMS image format (use 'image/png' for layers with transparency).
  String format = 'image/jpeg';

  /// If true, the WMS service will return images with transparency.
  bool transparent = false;

  /// Version of the WMS service to use.
  String version = '1.1.1';

  /// Coordinate Reference System to use for the WMS requests, defaults to
  /// map CRS. Don't change this if you're not sure what it means.
  CRS crs, srs;

  num width, height;

//  void merge(WMSOptions other) {
//  }

  getParamString([String existingUrl=null, bool uppercase=false]) {
    var params = [];

    encode(String s) => Uri.encodeComponent(uppercase ? s.toUpperCase() : s);

    if (layers != null) {
      params.add('${encode('layers')}=${Uri.encodeComponent(layers)}');
    }
    if (styles != null) {
      params.add('${encode('styles')}=${Uri.encodeComponent(styles)}');
    }
    if (format != null) {
      params.add('${encode('format')}=${Uri.encodeComponent(format)}');
    }
    if (layers != null) {
      params.add('${encode('transparent')}=${Uri.encodeComponent(transparent.toString())}');
    }
    if (version != null) {
      params.add('${encode('version')}=${Uri.encodeComponent(version)}');
    }
    if (crs != null) {
      params.add('${encode('crs')}=${Uri.encodeComponent(crs.code)}');
    } else if (srs != null) {
      params.add('${encode('srs')}=${Uri.encodeComponent(srs.code)}');
    }
    if (width != null) {
      params.add('${encode('width')}=${Uri.encodeComponent(width.toString())}');
    }
    if (height != null) {
      params.add('${encode('height')}=${Uri.encodeComponent(height.toString())}');
    }

    return ((existingUrl == null || existingUrl.indexOf('?') == -1) ? '?' : '&') + params.join('&');
  }
}

/// WMS is used for putting WMS tile layers on the map.
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

//    var wmsParams = L.extend({}, defaultWmsParams),
    final tileSize = options.tileSize;// || options.tileSize;

    if (options.detectRetina && browser.retina) {
      wmsOptions.width = wmsOptions.height = tileSize * 2;
    } else {
      wmsOptions.width = wmsOptions.height = tileSize;
    }

    /*for (var i in options) {
      // all keys that are not TileLayer options go to WMS params
      if (!options.hasOwnProperty(i) && i != 'crs') {
        wmsParams[i] = options[i];
      }
    }*/

//    wmsParams = wmsParams;

//    L.setOptions(this, options);
  }

  CRS _crs;
  semver.Version _wmsVersion;
  static final _wms13 = new semver.Version(1, 3, 0);

  onAdd(LeafletMap map) {

    _crs = wmsOptions.crs != null ? wmsOptions.crs : map.options.crs;

    _wmsVersion = new semver.Version.parse(wmsOptions.version);

    //var projectionKey = _wmsVersion >= 1.3 ? 'crs' : 'srs';
    if (_wmsVersion >= _wms13) {
      wmsOptions.crs = _crs;//.code;
    } else {
      wmsOptions.srs = _crs;//.code;
    }

    //L.TileLayer.prototype.onAdd.call(this, map);
    super.onAdd(map);
  }

  getTileUrl(Point2D tilePoint) { // (Point, Number) -> String
    var tileSize = options.tileSize;

    var nwPoint = tilePoint * tileSize;
    var sePoint = nwPoint + new Point2D(tileSize, tileSize);

    var nw = _crs.project(_map.unproject(nwPoint, tilePoint.z));
    var se = _crs.project(_map.unproject(sePoint, tilePoint.z));
    var bbox = _wmsVersion >= _wms13 && _crs == EPSG4326 ?
            [se.y, nw.x, nw.y, se.x].join(',') :
            [nw.x, se.y, se.x, nw.y].join(',');

    var url = core.template(_url, {'s': _getSubdomain(tilePoint)});

    return url + wmsOptions.getParamString(url, true) + '&BBOX=$bbox';
  }

  /// Merges an object with the new parameters and re-requests tiles on the
  /// current screen (unless noRedraw was set to true).
  /*setParams(WMSOptions params, bool noRedraw) {

    //L.extend(wmsParams, params);
    wmsOptions.merge(params);

    if (!noRedraw) {
      redraw();
    }
  }*/
}
