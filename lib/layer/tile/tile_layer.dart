part of leaflet.layer.tile;

class TileLayerOptions {
  /**
   * Minimum zoom number.
   */
  num minZoom = 0;

  /**
   * Maximum zoom number.
   */
  num maxZoom = 18;

  /**
   * Maximum zoom number the tiles source has available. If it is specified,
   * the tiles on all zoom levels higher than maxNativeZoom will be loaded
   * from maxZoom level and auto-scaled.
   */
  num maxNativeZoom;

  /**
   * Tile size (width and height in pixels, assuming tiles are square).
   */
  num tileSize  = 256;

  /**
   * Subdomains of the tile service. Can be passed in the form of one string
   * (where each letter is a subdomain name) or an array of strings.
   */
  List<String> subdomains = ['abc'];

  /**
   * URL to the tile image to show in place of the tile that failed to load.
   */
  String errorTileUrl  = '';

  /**
   * e.g. "© Mapbox" — the string used by the attribution control, describes
   * the layer data.
   */
  String attribution = '';

  /**
   * If true, inverses Y axis numbering for tiles (turn this on for TMS
   * services).
   */
  bool tms = false;

  /**
   * If set to true, the tile coordinates won't be wrapped by world width
   * (-180 to 180 longitude) or clamped to lie within world height (-90 to 90).
   * Use this if you use Leaflet for maps that don't reflect the real world
   * (e.g. game, indoor or photo maps).
   */
  bool continuousWorld = false;

  /**
   * If set to true, the tiles just won't load outside the world width
   * (-180 to 180 longitude) instead of repeating.
   */
  bool noWrap = false;

  /**
   * The zoom number used in tile URLs will be offset with this value.
   */
  num zoomOffset  = 0;

  /**
   * If set to true, the zoom number used in tile URLs will be reversed
   * (maxZoom - zoom instead of zoom)
   */
  bool zoomReverse = false;

  /**
   * The opacity of the tile layer.
   */
  num opacity = 1.0;

  /**
   * The explicit zIndex of the tile layer. Not set by default.
   */
  num zIndex;

  /**
   * If true, all the tiles that are not visible after panning are removed
   * (for better performance). true by default on mobile WebKit, otherwise
   * false.
   */
  bool unloadInvisibleTiles;

  /**
   * If false, new tiles are loaded during panning, otherwise only after it
   * (for better performance). true by default on mobile WebKit, otherwise
   * false.
   */
  bool updateWhenIdle;

  /**
   * If true and user is on a retina display, it will request four tiles of
   * half the specified size and a bigger zoom level in place of one to
   * utilize the high resolution.
   */
  bool detectRetina;

  /**
   * If true, all the tiles that are not visible after panning are placed in
   * a reuse queue from which they will be fetched when new tiles become
   * visible (as opposed to dynamically creating new ones). This will in
   * theory keep memory usage low and eliminate the need for reserving new
   * memory whenever a new tile is needed.
   */
  bool reuseTiles = false;

  /**
   * When this option is set, the TileLayer only loads tiles that are in the
   * given geographical bounds.
   */
  LatLngBounds bounds;
}

/**
 * TileLayer is used for standard xyz-numbered tile layers.
 */
class TileLayer extends Object with core.Events implements Layer {

  String _url;
  BaseMap _map;
  bool _animated;

//  final Map<String, Object> options = {
//    'minZoom': 0,
//    'maxZoom': 18,
//    'tileSize': 256,
//    'subdomains': 'abc',
//    'errorTileUrl': '',
//    'attribution': '',
//    'zoomOffset': 0,
//    'opacity': 1,
//    /*
//    maxNativeZoom: null,
//    zIndex: null,
//    tms: false,
//    continuousWorld: false,
//    noWrap: false,
//    zoomReverse: false,
//    detectRetina: false,
//    reuseTiles: false,
//    bounds: false,
//    */
//    'unloadInvisibleTiles': core.Browser.mobile,
//    'updateWhenIdle': core.Browser.mobile
//  };
  final TileLayerOptions options;

  Element _container;
  Map _tiles;

  TileLayer(this._url, this.options) {
    // detecting retina displays, adjusting tileSize and zoom levels
    if (options.detectRetina && Browser.retina && options.maxZoom > 0) {

      options.tileSize = (options.tileSize / 2).floor();
      options.zoomOffset++;

      if (options.minZoom > 0) {
        options.minZoom--;
      }
      options.maxZoom--;
    }

    if (options.bounds != null) {
      options.bounds = new LatLngBounds.latLngBounds(options.bounds);
    }

    /*var subdomains = options.subdomains;

    if (subdomains is String) {
      options['subdomains'] = subdomains.split('');
    }*/
  }

  void onAdd(BaseMap map) {
    _map = map;
    _animated = map._zoomAnimated;

    // create a container div for tiles
    _initContainer();

    // set up events
    map.on(EventType.VIEWRESET, this._animateZoom, this);
    map.on(EventType.MOVEEND, this._update, this);
//    map.on({
//      'viewreset': this._reset,
//      'moveend': this._update
//    }, this);

    if (_animated) {
      map.on(EventType.ZOOMANIM, this._animateZoom, this);
      map.on(EventType.ZOOMEND, this._endZoomAnim, this);
//      map.on({
//        'zoomanim': this._animateZoom,
//        'zoomend': this._endZoomAnim
//      }, this);
    }

    if (!options.updateWhenIdle) {
      _limitedUpdate = Util.limitExecByInterval(this._update, 150, this);
      map.on(EventType.MOVE, this._limitedUpdate, this);
    }

    _reset();
    _update();
  }

  Function _limitedUpdate;

  /**
   * Adds the layer to the map.
   */
  void addTo(BaseMap map) {
    map.addLayer(this);
  }

  void onRemove(BaseMap map) {
    //_container.parentNode.removeChild(_container);
    _container.remove();

    map.off(EventType.VIEWRESET, this._reset, this);
    map.off(EventType.MOVEEND, this._update, this);
//    map.off({
//      'viewreset': this._reset,
//      'moveend': this._update
//    }, this);

    if (_animated) {
      map.off(EventType.ZOOMANIM, this._animateZoom, this);
      map.off(EventType.ZOOMEND, this._endZoomAnim, this);
//      map.off({
//        'zoomanim': this._animateZoom,
//        'zoomend': this._endZoomAnim
//      }, this);
    }

    if (!options.updateWhenIdle) {
      map.off(EventType.MOVE, this._limitedUpdate, this);
    }

    _container = null;
    _map = null;
  }

  /**
   * Brings the tile layer to the top of all tile layers.
   */
  void bringToFront() {
    final pane = _map.panes['tilePane'];

    if (_container != null) {
      pane.append(_container);
      _setAutoZIndex(pane, math.max);
    }
  }

  /**
   * Brings the tile layer to the bottom of all tile layers.
   */
  void bringToBack() {
    final pane = _map.panes['tilePane'];

    if (_container != null) {
      pane.insertBefore(_container, pane.firstChild);
      _setAutoZIndex(pane, math.min);
    }
  }

  String getAttribution() {
    return options.attribution;
  }

  /**
   * Returns the HTML element that contains the tiles for this layer.
   */
  Element getContainer() {
    return _container;
  }

  /**
   * Changes the opacity of the tile layer.
   */
  void setOpacity(num opacity) {
    options.opacity = opacity;

    if (_map != null) {
      _updateOpacity();
    }
  }

  /**
   * Sets the zIndex of the tile layer.
   */
  void setZIndex(num zIndex) {
    options.zIndex = zIndex;
    _updateZIndex();
  }

  /**
   * Updates the layer's URL template and redraws it.
   */
  void setUrl(String url, [bool noRedraw=false]) {
    _url = url;

    if (!noRedraw) {
      redraw();
    }
  }

  /**
   * Causes the layer to clear all the tiles and request them again.
   */
  void redraw() {
    if (_map != null) {
      _reset(true);
      _update();
    }
  }

  void _updateZIndex() {
    if (_container && options.zIndex != null) {
      _container.style.zIndex = options.zIndex.toString();
    }
  }

  void _setAutoZIndex(Element pane, Function compare) {

    final layers = pane.children;
    num edgeZIndex = -compare(double.INFINITY, double.NEGATIVE_INFINITY); // -Infinity for max, Infinity for min
    num zIndex;

    for (int i = 0; i < layers.length; i++) {

      if (layers[i] != _container) {
        zIndex = int.parse(layers[i].style.zIndex, radix: 10);

        if (!zIndex.isNaN) {
          edgeZIndex = compare(edgeZIndex, zIndex);
        }
      }
    }

    options.zIndex = (edgeZIndex.isFinite ? edgeZIndex : 0) + compare(1, -1);
    _container.style.zIndex = options.zIndex.toString();
  }

  void _updateOpacity() {
    final tiles = _tiles;

    if (Browser.ielt9) {
      for (var i in tiles) {
        DomUtil.setOpacity(tiles[i], options.opacity);
      }
    } else {
      DomUtil.setOpacity(_container, options.opacity);
    }
  }

  Element _bgBuffer, _tileContainer;

  void _initContainer() {
    final tilePane = _map.panes['tilePane'];

    if (_container == null) {
      _container = DomUtil.create('div', 'leaflet-layer');

      _updateZIndex();

      if (_animated) {
        final className = 'leaflet-tile-container';

        _bgBuffer = DomUtil.create('div', className, _container);
        _tileContainer = DomUtil.create('div', className, _container);

      } else {
        _tileContainer = _container;
      }

      tilePane.append(_container);

      if (options.opacity < 1) {
        _updateOpacity();
      }
    }
  }

  int _tilesToLoad;
  List _unusedTiles;

  void _reset([bool hard = false]/*[core.Event e = null]*/) {
    for (var key in _tiles) {
      fire(EventType.TILEUNLOAD, {'tile': _tiles[key]});
    }

    _tiles = {};
    _tilesToLoad = 0;

    if (options.reuseTiles) {
      _unusedTiles = [];
    }

    _tileContainer.setInnerHtml('');

    if (_animated && hard) {
      _clearBgBuffer();
    }

    _initContainer();
  }

  num _getTileSize() {
    final map = _map,
        zoom = map.getZoom() + options.zoomOffset,
        zoomN = options.maxNativeZoom;
    num tileSize = options.tileSize;

    if (zoomN && zoom > zoomN) {
      tileSize = (map.getZoomScale(zoom) / map.getZoomScale(zoomN) * tileSize).round();
    }

    return tileSize;
  }

  void _update() {

    if (_map == null) { return; }

    final map = _map,
        bounds = map.getPixelBounds(),
        zoom = map.getZoom(),
        tileSize = _getTileSize();

    if (zoom > options.maxZoom || zoom < options.minZoom) {
      return;
    }

    final tileBounds = new LatLngBounds(
            bounds.min.divideBy(tileSize)._floor(),
            bounds.max.divideBy(tileSize)._floor());

    _addTilesFromCenterOut(tileBounds);

    if (options.unloadInvisibleTiles || options.reuseTiles) {
      _removeOtherTiles(tileBounds);
    }
  }

  void _addTilesFromCenterOut(LatLngBounds bounds) {
    final queue = new List<geom.Point>(),
        center = bounds.getCenter();

    for (num j = bounds.min.y; j <= bounds.max.y; j++) {
      for (i = bounds.min.x; i <= bounds.max.x; i++) {
        final point = new geom.Point(i, j);

        if (_tileShouldBeLoaded(point)) {
          queue.add(point);
        }
      }
    }

    final tilesToLoad = queue.length;

    if (tilesToLoad == 0) { return; }

    // load tiles in order of their distance to center
    queue.sort((geom.Point a, geom.Point b) {
      return a.distanceTo(center) - b.distanceTo(center);
    });

    var fragment = document.createDocumentFragment();

    // if its the first batch of tiles to load
    if (_tilesToLoad == 0) {
      fire(EventType.LOADING);
    }

    _tilesToLoad += tilesToLoad;

    for (int i = 0; i < tilesToLoad; i++) {
      _addTile(queue[i], fragment);
    }

    _tileContainer.append(fragment);
  }

  bool _tileShouldBeLoaded(geom.Point tilePoint) {
    if (_tiles.containsKey('${tilePoint.x}:${tilePoint.y}')) {
      return false; // already loaded
    }

    if (!options.continuousWorld) {
      final limit = _getWrapTileNum();

      // don't load if exceeds world bounds
      if ((options.noWrap && (tilePoint.x < 0 || tilePoint.x >= limit.x)) ||
          tilePoint.y < 0 || tilePoint.y >= limit.y) {
        return false;
      }
    }

    if (options.bounds != null) {
      final tileSize = options.tileSize,
          nwPoint = tilePoint.multiplyBy(tileSize),
          sePoint = nwPoint.add([tileSize, tileSize]);
      LatLng nw = _map.unproject(nwPoint),
          se = _map.unproject(sePoint);

      // TODO temporary hack, will be removed after refactoring projections
      // https://github.com/Leaflet/Leaflet/issues/1618
      if (!options.continuousWorld && !options.noWrap) {
        nw = nw.wrap();
        se = se.wrap();
      }

      if (!options.bounds.intersects([nw, se])) {
        return false;
      }
    }

    return true;
  }

  void _removeOtherTiles(bounds) {
//    var kArr, x, y, key;

    for (var key in _tiles) {
      final kArr = key.split(':');
      final x = int.parse(kArr[0], radix:10);
      final y = int.parse(kArr[1], radix:10);

      // remove tile if it's out of bounds
      if (x < bounds.min.x || x > bounds.max.x || y < bounds.min.y || y > bounds.max.y) {
        _removeTile(key);
      }
    }
  }

  void _removeTile(String key) {
    final tile = _tiles[key];

    fire(EventType.TILEUNLOAD, {'tile': tile, 'url': tile.src});

    if (options.reuseTiles) {
      DomUtil.removeClass(tile, 'leaflet-tile-loaded');
      _unusedTiles.add(tile);

    } else if (tile.parentNode == _tileContainer) {
      //_tileContainer.removeChild(tile);
      tile.remove();
    }

    // for https://github.com/CloudMade/Leaflet/issues/137
    if (!Browser.android) {
      tile.onload = null;
      tile.src = Util.emptyImageUrl;
    }

    _tiles.remove(key);
  }

  void _addTile(geom.Point tilePoint, Element container) {
    final tilePos = _getTilePos(tilePoint);

    // get unused tile - or create a new tile
    final tile = _getTile();

    /*
    Chrome 20 layouts much faster with top/left (verify with timeline, frames)
    Android 4 browser has display issues with top/left and requires transform instead
    (other browsers don't currently care) - see debug/hacks/jitter.html for an example
    */
    DomUtil.setPosition(tile, tilePos, Browser.chrome);

    _tiles['${tilePoint.x}:${tilePoint.y}'] = tile;

    _loadTile(tile, tilePoint);

    if (tile.parentNode != _tileContainer) {
      container.append(tile);
    }
  }

  num _getZoomForUrl() {
    num zoom = _map.getZoom();

    if (options.zoomReverse) {
      zoom = options.maxZoom - zoom;
    }

    zoom += options.zoomOffset;

    return options.maxNativeZoom != 0 ? math.min(zoom, options.maxNativeZoom) : zoom;
  }

  geom.Point _getTilePos(geom.Point tilePoint) {
    final origin = _map.getPixelOrigin(),
        tileSize = _getTileSize();

    return tilePoint.multiplyBy(tileSize).subtract(origin);
  }

  // image-specific code (override to implement e.g. Canvas or SVG tile layer)

  String getTileUrl(geom.Point tilePoint) {
    return Util.template(_url, extend({
      's': _getSubdomain(tilePoint),
      'z': tilePoint.z,
      'x': tilePoint.x,
      'y': tilePoint.y
    }, options));
  }

  geom.Point _getWrapTileNum() {
    final crs = _map.stateOptions.crs,
        size = crs.getSize(_map.getZoom());
    return size.divideBy(_getTileSize())._floor();
  }

  void _adjustTilePoint(geom.Point tilePoint) {

    final limit = _getWrapTileNum();

    // wrap tile coordinates
    if (!options.continuousWorld && !options.noWrap) {
      tilePoint.x = ((tilePoint.x % limit.x) + limit.x) % limit.x;
    }

    if (options.tms) {
      tilePoint.y = limit.y - tilePoint.y - 1;
    }

    tilePoint.z = _getZoomForUrl();
  }

  String _getSubdomain(geom.Point tilePoint) {
    var index = (tilePoint.x + tilePoint.y).abs() % options.subdomains.length;
    return options.subdomains[index];
  }

  Element _getTile() {
    if (options.reuseTiles && _unusedTiles.length > 0) {
      var tile = _unusedTiles.pop();
      _resetTile(tile);
      return tile;
    }
    return _createTile();
  }

  // Override if data stored on a tile needs to be cleaned up before reuse
  _resetTile(tile) {}

  Element _createTile() {
    final tile = DomUtil.create('img', 'leaflet-tile');
    tile.style.width = tile.style.height = _getTileSize() + 'px';
    tile.galleryimg = 'no';

    tile.onselectstart = tile.onmousemove = Util.falseFn;

    if (Browser.ielt9 && options.opacity != null) {
      DomUtil.setOpacity(tile, options.opacity);
    }
    // without this hack, tiles disappear after zoom on Chrome for Android
    // https://github.com/Leaflet/Leaflet/issues/2078
    if (Browser.mobileWebkit3d) {
      tile.style.WebkitBackfaceVisibility = 'hidden';
    }
    return tile;
  }

  void _loadTile(Element tile, geom.Point tilePoint) {
    tile._layer  = this;
    tile.onload  = _tileOnLoad;
    tile.onerror = _tileOnError;

    _adjustTilePoint(tilePoint);
    tile.src     = getTileUrl(tilePoint);

    fire(EventType.TILELOADSTART, {
      'tile': tile,
      'url': tile.src
    });
  }

  void _tileLoaded() {
    _tilesToLoad--;

    if (_animated) {
      DomUtil.addClass(_tileContainer, 'leaflet-zoom-animated');
    }

    if (_tilesToLoad == 0) {
      fire(EventType.LOAD);

      if (_animated) {
        // clear scaled tiles after all new tiles are loaded (for performance)
        clearTimeout(_clearBgBufferTimer);
        _clearBgBufferTimer = setTimeout(bind(_clearBgBuffer, this), 500);
      }
    }
  }

  void _tileOnLoad() {
    final layer = _layer;

    //Only if we are loading an actual image
    if (this.src != Util.emptyImageUrl) {
      DomUtil.addClass(this, 'leaflet-tile-loaded');

      layer.fire(EventType.TILELOAD, {
        'tile': this,
        'url': this.src
      });
    }

    layer._tileLoaded();
  }

  void _tileOnError() {
    final layer = _layer;

    layer.fire(EventType.TILEERROR, {
      'tile': this,
      'url': this.src
    });

    var newUrl = layer.options.errorTileUrl;
    if (newUrl) {
      this.src = newUrl;
    }

    layer._tileLoaded();
  }
}