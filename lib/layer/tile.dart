part of leaflet;

const osmTileUrl = 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
const mapQuestUrl = 'http://otile{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png';

/*
class TileLayerOptions {
  /// Minimum zoom number. Default: 0
  num minZoom;

  /// Maximum zoom number. Default: 18
  num maxZoom;

  /// Maximum zoom number the tiles source has available. If it is specified,
  /// the tiles on all zoom levels higher than maxNativeZoom will be loaded
  /// from maxZoom level and auto-scaled.
  num maxNativeZoom;

  /// Tile size (width and height in pixels, assuming tiles are square).
  num tileSize;

  /// Subdomains of the tile service. E.g: 'a', 'b', 'c'
  List<String> subdomains;

  /// URL to the tile image to show in place of the tile that failed to load.
  String errorTileUrl;

  /// e.g. "© Mapbox" — the string used by the attribution control, describes
  /// the layer data.
  String attribution;

  /// If true, inverses Y axis numbering for tiles (turn this on for TMS
  /// services).
  bool tms;

  /// If set to true, the tile coordinates won't be wrapped by world width
  /// (-180 to 180 longitude) or clamped to lie within world height (-90 to 90).
  /// Use this if you use Leaflet for maps that don't reflect the real world
  /// (e.g. game, indoor or photo maps).
  bool continuousWorld;

  /// If set to true, the tiles just won't load outside the world width
  /// (-180 to 180 longitude) instead of repeating. Default: false
  bool noWrap;

  /// The zoom number used in tile URLs will be offset with this value.
  num zoomOffset;

  /// If set to true, the zoom number used in tile URLs will be reversed
  /// (maxZoom - zoom instead of zoom)
  bool zoomReverse;

  /// The opacity of the tile layer. Default: 1.0
  num opacity;

  /// The explicit zIndex of the tile layer. Not set by default.
  num zIndex;

  /// If true, all the tiles that are not visible after panning are removed
  /// (for better performance). true by default on mobile WebKit, otherwise
  /// false.
  bool unloadInvisibleTiles;

  /// If false, new tiles are loaded during panning, otherwise only after it
  /// (for better performance). true by default on mobile WebKit, otherwise
  /// false. Default: false
  bool updateWhenIdle;

  /// If true and user is on a retina display, it will request four tiles of
  /// half the specified size and a bigger zoom level in place of one to
  /// utilize the high resolution. Default: true
  bool detectRetina;

  /// If true, all the tiles that are not visible after panning are placed in
  /// a reuse queue from which they will be fetched when new tiles become
  /// visible (as opposed to dynamically creating new ones). This will in
  /// theory keep memory usage low and eliminate the need for reserving new
  /// memory whenever a new tile is needed. Default: false
  bool reuseTiles;

  /// When this option is set, the TileLayer only loads tiles that are in the
  /// given geographical bounds.
  LatLngBounds bounds;

  Map<String, dynamic> _toJsonMap() {
    var m = {};
    if (minZoom != null) m['minZoom'] = minZoom;
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    if (maxNativeZoom != null) m['maxNativeZoom'] = maxNativeZoom;
    if (tileSize != null) m['tileSize'] = tileSize;
    if (subdomains != null) m['subdomains'] = subdomains;
    if (errorTileUrl != null) m['errorTileUrl'] = errorTileUrl;
    if (attribution != null) m['attribution'] = attribution;
    if (tms != null) m['tms'] = tms;
    if (continuousWorld != null) m['continuousWorld'] = continuousWorld;
    if (noWrap != null) m['noWrap'] = noWrap;
    if (zoomOffset != null) m['zoomOffset'] = zoomOffset;
    if (zoomReverse != null) m['zoomReverse'] = zoomReverse;
    if (opacity != null) m['opacity'] = opacity;
    if (zIndex != null) m['zIndex'] = zIndex;
    if (unloadInvisibleTiles != null) m['unloadInvisibleTiles'] =
        unloadInvisibleTiles;
    if (updateWhenIdle != null) m['updateWhenIdle'] = updateWhenIdle;
    if (detectRetina != null) m['detectRetina'] = detectRetina;
    if (reuseTiles != null) m['reuseTiles'] = reuseTiles;
    return m;
  }

  JsObject jsify() => new JsObject.jsify(_toJsonMap());
}
*/

/// TileLayer is used for standard xyz-numbered tile layers.
class TileLayer implements Layer {
  JsObject _L, layer;
  TileLayer(
      {String url: '',

      /// Minimum zoom number. Default: 0
      num minZoom,

      /// Maximum zoom number. Default: 18
      num maxZoom,

      /// Maximum zoom number the tiles source has available. If it is specified,
      /// the tiles on all zoom levels higher than maxNativeZoom will be loaded
      /// from maxZoom level and auto-scaled.
      num maxNativeZoom,

      /// Tile size (width and height in pixels, assuming tiles are square).
      num tileSize,

      /// Subdomains of the tile service. E.g: 'a', 'b', 'c'
      List<String> subdomains,

      /// URL to the tile image to show in place of the tile that failed to load.
      String errorTileUrl,

      /// e.g. "© Mapbox" — the string used by the attribution control, describes
      /// the layer data.
      String attribution,

      /// If true, inverses Y axis numbering for tiles (turn this on for TMS
      /// services).
      bool tms,

      /// If set to true, the tile coordinates won't be wrapped by world width
      /// (-180 to 180 longitude) or clamped to lie within world height (-90 to 90).
      /// Use this if you use Leaflet for maps that don't reflect the real world
      /// (e.g. game, indoor or photo maps).
      bool continuousWorld,

      /// If set to true, the tiles just won't load outside the world width
      /// (-180 to 180 longitude) instead of repeating. Default: false
      bool noWrap,

      /// The zoom number used in tile URLs will be offset with this value.
      num zoomOffset,

      /// If set to true, the zoom number used in tile URLs will be reversed
      /// (maxZoom - zoom instead of zoom)
      bool zoomReverse,

      /// The opacity of the tile layer. Default: 1.0
      num opacity,

      /// The explicit zIndex of the tile layer. Not set by default.
      num zIndex,

      /// If true, all the tiles that are not visible after panning are removed
      /// (for better performance). true by default on mobile WebKit, otherwise
      /// false.
      bool unloadInvisibleTiles,

      /// If false, new tiles are loaded during panning, otherwise only after it
      /// (for better performance). true by default on mobile WebKit, otherwise
      /// false. Default: false
      bool updateWhenIdle,

      /// If true and user is on a retina display, it will request four tiles of
      /// half the specified size and a bigger zoom level in place of one to
      /// utilize the high resolution. Default: true
      bool detectRetina,

      /// If true, all the tiles that are not visible after panning are placed in
      /// a reuse queue from which they will be fetched when new tiles become
      /// visible (as opposed to dynamically creating new ones). This will in
      /// theory keep memory usage low and eliminate the need for reserving new
      /// memory whenever a new tile is needed. Default: false
      bool reuseTiles,

      /// When this option is set, the TileLayer only loads tiles that are in the
      /// given geographical bounds.
      LatLngBounds bounds}) {
    _L = context['L'];

    var m = {};
    if (minZoom != null) m['minZoom'] = minZoom;
    if (maxZoom != null) m['maxZoom'] = maxZoom;
    if (maxNativeZoom != null) m['maxNativeZoom'] = maxNativeZoom;
    if (tileSize != null) m['tileSize'] = tileSize;
    if (subdomains != null) m['subdomains'] = subdomains;
    if (errorTileUrl != null) m['errorTileUrl'] = errorTileUrl;
    if (attribution != null) m['attribution'] = attribution;
    if (tms != null) m['tms'] = tms;
    if (continuousWorld != null) m['continuousWorld'] = continuousWorld;
    if (noWrap != null) m['noWrap'] = noWrap;
    if (zoomOffset != null) m['zoomOffset'] = zoomOffset;
    if (zoomReverse != null) m['zoomReverse'] = zoomReverse;
    if (opacity != null) m['opacity'] = opacity;
    if (zIndex != null) m['zIndex'] = zIndex;
    if (unloadInvisibleTiles != null) m['unloadInvisibleTiles'] =
        unloadInvisibleTiles;
    if (updateWhenIdle != null) m['updateWhenIdle'] = updateWhenIdle;
    if (detectRetina != null) m['detectRetina'] = detectRetina;
    if (reuseTiles != null) m['reuseTiles'] = reuseTiles;

    var args = [url, new JsObject.jsify(m)];

    layer = _L.callMethod('tileLayer', args);
  }
}
