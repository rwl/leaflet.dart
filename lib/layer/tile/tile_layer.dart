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
  LeafletMap _map;
  bool _animated;
  Timer _clearBgBufferTimer;

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
  TileLayerOptions options;

  Element _container;
  Map _tiles;

  TileLayer([this._url="", this.options=null]) {
    if (options == null) {
      options = new TileLayerOptions();
    }

    // detecting retina displays, adjusting tileSize and zoom levels
    if (options.detectRetina == true && browser.retina == true &&
        options.maxZoom > 0) {

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

  void onAdd(LeafletMap map) {
    print("TileLayer.onAdd");
    _map = map;
    _animated = map.zoomAnimated;

    // create a container div for tiles
    _initContainer();

    // set up events
    // this is the wrong handler type
    map.on(EventType.VIEWRESET, _reset);
    map.on(EventType.MOVEEND, _update);
//    map.on({
//      'viewreset': _reset,
//      'moveend': _update
//    }, this);

    if (_animated == true) {
      map.on(EventType.ZOOMANIM, _animateZoom);
      map.on(EventType.ZOOMEND, _endZoomAnim);
//      map.on({
//        'zoomanim': _animateZoom,
//        'zoomend': _endZoomAnim
//      }, this);
    }

    if (options.updateWhenIdle != true) {
      //_limitedUpdate = limitExecByInterval(_update, 150, this);
      _limitedUpdate = () {
        //new Future.delayed(const Duration(milliseconds: 150), _update);
        new Timer(const Duration(milliseconds: 150), _update);
      };
      map.on(EventType.MOVE, _limitedUpdate);
    }

    _reset();
    _update();
  }

  Function _limitedUpdate;

  /**
   * Adds the layer to the map.
   */
  void addTo(LeafletMap map) {
    map.addLayer(this);
  }

  void onRemove(LeafletMap map) {
    //_container.parentNode.removeChild(_container);
    _container.remove();

    map.off(EventType.VIEWRESET, _reset);
    map.off(EventType.MOVEEND, _update);
//    map.off({
//      'viewreset': _reset,
//      'moveend': _update
//    }, this);

    if (_animated == true) {
      map.off(EventType.ZOOMANIM, _animateZoom);
      map.off(EventType.ZOOMEND, _endZoomAnim);
//      map.off({
//        'zoomanim': _animateZoom,
//        'zoomend': _endZoomAnim
//      }, this);
    }

    if (!options.updateWhenIdle) {
      map.off(EventType.MOVE, _limitedUpdate);
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
    if (_container != null && options.zIndex != null) {
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
    _container.style.opacity = '$options.opacity';
  }

  Element _bgBuffer, _tileContainer;

  void _initContainer() {
    final tilePane = _map.panes['tilePane'];

    if (_container == null) {
      _container = dom.create('div', 'leaflet-layer');

      _updateZIndex();

      if (_animated == true) {
        final className = 'leaflet-tile-container';

        _bgBuffer = dom.create('div', className, _container);
        _tileContainer = dom.create('div', className, _container);

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

  void _reset([Object obj, Event e, bool hard = false]) {
    if (_tiles != null) {
      for (var key in _tiles.keys) {
        fireEvent(new TileEvent(EventType.TILEUNLOAD, _tiles[key], null));
      }
    }

    _tiles = {};
    _tilesToLoad = 0;

    if (options.reuseTiles) {
      _unusedTiles = [];
    }

    _tileContainer.setInnerHtml('');

    if (_animated == true && hard) {
      _clearBgBuffer();
    }

    _initContainer();
  }

  num _getTileSize() {
    final map = _map,
        zoom = map.getZoom() + options.zoomOffset,
        zoomN = options.maxNativeZoom;
    num tileSize = options.tileSize;

    if (zoomN != null && zoom > zoomN) {
      tileSize = (map.getZoomScale(zoom) / map.getZoomScale(zoomN) * tileSize).round();
    }

    return tileSize;
  }

  void _update([Object obj=null, Event e=null]) {

    if (_map == null) { return; }

    final map = _map,
        bounds = map.getPixelBounds(),
        zoom = map.getZoom(),
        tileSize = _getTileSize();

    if (zoom > options.maxZoom || zoom < options.minZoom) {
      return;
    }

    final tileBounds = new Bounds.between(
            (bounds.min / tileSize).floored(),
            (bounds.max / tileSize).floored());

    _addTilesFromCenterOut(tileBounds);

    if (options.unloadInvisibleTiles == true || options.reuseTiles == true) {
      _removeOtherTiles(tileBounds);
    }
  }

  void _addTilesFromCenterOut(Bounds bounds) {
    final queue = new List<Point2D>(),
        center = bounds.getCenter();

    for (num j = bounds.min.y; j <= bounds.max.y; j++) {
      for (num i = bounds.min.x; i <= bounds.max.x; i++) {
        final point = new Point2D(i, j);

        if (_tileShouldBeLoaded(point)) {
          queue.add(point);
        }
      }
    }

    final tilesToLoad = queue.length;

    if (tilesToLoad == 0) { return; }

    // load tiles in order of their distance to center
    queue.sort((Point2D a, Point2D b) {
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

  bool _tileShouldBeLoaded(Point2D tilePoint) {
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
          nwPoint = tilePoint * tileSize,
          sePoint = nwPoint + new Point2D(tileSize, tileSize);
      LatLng nw = _map.unproject(nwPoint),
          se = _map.unproject(sePoint);

      // TODO temporary hack, will be removed after refactoring projections
      // https://github.com/Leaflet/Leaflet/issues/1618
      if (!options.continuousWorld && !options.noWrap) {
        nw = nw.wrap();
        se = se.wrap();
      }

      if (!options.bounds.intersects(new LatLngBounds.between(nw, se))) {
        return false;
      }
    }

    return true;
  }

  void _removeOtherTiles(Bounds bounds) {
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

    fireEvent(new TileEvent(EventType.TILEUNLOAD, tile, tile.src));

    if (options.reuseTiles) {
      tile.classes.remove('leaflet-tile-loaded');
      _unusedTiles.add(tile);

    } else if (tile.parentNode == _tileContainer) {
      //_tileContainer.removeChild(tile);
      tile.remove();
    }

    _tiles.remove(key);
  }

  void _addTile(Point2D tilePoint, Node container) {
    final tilePos = _getTilePos(tilePoint);

    // get unused tile - or create a new tile
    final tile = _getTile();

    /*
    Chrome 20 layouts much faster with top/left (verify with timeline, frames)
    Android 4 browser has display issues with top/left and requires transform instead
    (other browsers don't currently care) - see debug/hacks/jitter.html for an example
    */
    dom.setPosition(tile, tilePos);

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

    return (options.maxNativeZoom != null && options.maxNativeZoom != 0)
        ? math.min(zoom, options.maxNativeZoom)
        : zoom;
  }

  Point2D _getTilePos(Point2D tilePoint) {
    final origin = _map.getPixelOrigin(),
        tileSize = _getTileSize();

    return (tilePoint * tileSize) - origin;
  }

  // image-specific code (override to implement e.g. Canvas or SVG tile layer)

  String getTileUrl(Point2D tilePoint) {
    return core.template(_url, {
      's': _getSubdomain(tilePoint),
      // TODO: type these as int in Point2D?
      'z': tilePoint.z.toInt(),
      'x': tilePoint.x.toInt(),
      'y': tilePoint.y.toInt()
    }); //..addAll(options));
  }

  Point2D _getWrapTileNum() {
    final crs = _map.options.crs,
        size = crs.getSize(_map.getZoom());
    return (size / _getTileSize())..floored();
  }

  void _adjustTilePoint(Point2D tilePoint) {

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

  String _getSubdomain(Point2D tilePoint) {
    int index = (tilePoint.x + tilePoint.y).abs().toInt() %
        options.subdomains.length;
    return options.subdomains[index];
  }

  Element _getTile() {
    if (options.reuseTiles && _unusedTiles.length > 0) {
      final tile = _unusedTiles.removeLast();
      _resetTile(tile);
      return tile;
    }
    return _createTile();
  }

  // Override if data stored on a tile needs to be cleaned up before reuse
  _resetTile(tile) {}

  Element _createTile() {
    final tile = dom.create('img', 'leaflet-tile');
    tile.style.width = tile.style.height = '${_getTileSize()}px';

    tile.onSelectStart.listen((html.Event e) {});
    tile.onMouseMove.listen((html.Event e) {});

    // without this hack, tiles disappear after zoom on Chrome for Android
    // https://github.com/Leaflet/Leaflet/issues/2078
    if (false) { //browser.mobileWebkit3d == true) {
      //tile.style.WebkitBackfaceVisibility = 'hidden';
      tile.style.backfaceVisibility = 'hidden';
    }
    return tile;
  }

  Expando<TileLayer> _layerForImage = new Expando<TileLayer>();

  void _loadTile(ImageElement tile, Point2D tilePoint) {
    _layerForImage[tile]  = this;
    tile.onLoad.listen(_tileOnLoad);
    tile.onError.listen(_tileOnError);

    _adjustTilePoint(tilePoint);
    tile.src = getTileUrl(tilePoint);

    fireEvent(new TileEvent(EventType.TILELOADSTART, tile, tile.src));
  }

  void _tileLoaded() {
    print("_tileLoaded");
    _tilesToLoad--;

    if (_animated == true) {
      _tileContainer.classes.add('leaflet-zoom-animated');
    }

    if (_tilesToLoad == 0) {
      fire(EventType.LOAD);

      if (_animated == true) {
        // clear scaled tiles after all new tiles are loaded (for performance)
        //clearTimeout(_clearBgBufferTimer);
        //_clearBgBufferTimer = setTimeout(bind(_clearBgBuffer, this), 500);
        if (_clearBgBufferTimer != null) {
          _clearBgBufferTimer.cancel();
        }
        _clearBgBufferTimer = new Timer(const Duration(milliseconds: 500), () {
          _clearBgBuffer();
        });
      }
    }
  }

  void _tileOnLoad(html.Event e) {
    var img = e.target;

    // What is this mess with 'this'? Should tile layer be a custom element?

    // Only if we are loading an actual image.
    //if (this.src != core.emptyImageUrl) {
    if (img.src != core.emptyImageUrl) {
      // TODO: why was leaflet adding a class to an object?
      img.classes.add('leaflet-tile-loaded');

      //fireEvent(new TileEvent(EventType.TILELOAD, this, this.src));
      fireEvent(new TileEvent(EventType.TILELOAD, img, img.src));
    }

    _tileLoaded();
  }

  void _tileOnError(e) {
    print("tile load error: $e");
    /*final layer = _layer;

    layer.fireEvent(new TileEvent(EventType.TILEERROR, this, this.src));

    var newUrl = layer.options.errorTileUrl;
    if (newUrl) {
      this.src = newUrl;
    }

    layer._tileLoaded();*/
  }


  /* Zoom animation logic for TileLayer */

  bool _animating;

  void _animateZoom(ZoomEvent e) {
    if (!_animating) {
      _animating = true;
      _prepareBgBuffer();
    }

    final bg = _bgBuffer,
        initialTransform = e.delta != null ? dom.getTranslateString(e.delta) : bg.style.transform,
        scaleStr = dom.getScaleString(e.scale, e.origin);

    bg.style.transform = e.backwards ?
        '$scaleStr $initialTransform' :
        '$initialTransform $scaleStr';
  }

  void _endZoomAnim(ZoomEvent e) {
    final front = _tileContainer,
        bg = _bgBuffer;

    front.style.visibility = '';
    front.parentNode.append(front); // Bring to fore

    // force reflow
    final falseFn = (var x) => false;
    falseFn(bg.offsetWidth);

    _animating = false;
  }

  void _clearBgBuffer() {
    final map = _map;

    if (map != null && map.animatingZoom == false && map.touchZoom.zooming == false) {
      _bgBuffer.setInnerHtml('');
      _bgBuffer.style.transform/*[dom.TRANSFORM]*/ = '';
    }
  }

  void _prepareBgBuffer() {

    final front = _tileContainer;
    Element bg = _bgBuffer;

    // if foreground layer doesn't have many tiles but bg layer does,
    // keep the existing bg layer and just zoom it some more

    final bgLoaded = _getLoadedTilesPercentage(bg),
        frontLoaded = _getLoadedTilesPercentage(front);

    if (bg != null && bgLoaded > 0.5 && frontLoaded < 0.5) {

      front.style.visibility = 'hidden';
      _stopLoadingImages(front);
      return;
    }

    // prepare the buffer to become the front tile pane
    bg.style.visibility = 'hidden';
    bg.style.transform/*[dom.TRANSFORM]*/ = '';

    // switch out the current layer to be the new bg layer (and vice-versa)
    _tileContainer = bg;
    bg = _bgBuffer = front;

    _stopLoadingImages(bg);

    //prevent bg buffer from clearing right after zoom
    //clearTimeout(_clearBgBufferTimer);
    if (_clearBgBufferTimer != null) {
      _clearBgBufferTimer.cancel();
    }
  }

  num _getLoadedTilesPercentage(Element container) {
    final tiles = container.querySelectorAll('img');
    int count = 0;

    final len = tiles.length;
    for (int i = 0; i < len; i++) {
      if (tiles[i].complete) {
        count++;
      }
    }
    return count / len;
  }

  /**
   * Stops loading all tiles in the background layer.
   */
  void _stopLoadingImages(Element container) {
    //var tiles = Array.prototype.slice.call(container.getElementsByTagName('img'));
    final tiles = container.querySelectorAll('img');

    final len = tiles.length;
    for (int i = 0; i < len; i++) {
      ImageElement tile = tiles[i];

      if (!tile.complete) {
        tile.onLoad.listen((html.Event e) {});
        tile.onError.listen((html.Event e) {});
        tile.src = core.emptyImageUrl;

        //tile.parentNode.removeChild(tile);
        tile.remove();
      }
    }
  }
}