part of leaflet.layer.tile;

class TileLayerOptions {
  // Minimum zoom number.
  num minZoom = 0;
  // Maximum zoom number.
  num maxZoom = 18;
  // Maximum zoom number the tiles source has available. If it is specified, the tiles on all zoom levels higher than maxNativeZoom will be loaded from maxZoom level and auto-scaled.
  num maxNativeZoom;
  // Tile size (width and height in pixels, assuming tiles are square).
  num tileSize  = 256;
  // Subdomains of the tile service. Can be passed in the form of one string (where each letter is a subdomain name) or an array of strings.
  List<String> subdomains = ['abc'];
  // URL to the tile image to show in place of the tile that failed to load.
  String errorTileUrl  = '';
  // e.g. "© Mapbox" — the string used by the attribution control, describes the layer data.
  String attribution = '';
  // If true, inverses Y axis numbering for tiles (turn this on for TMS services).
  bool tms = false;
  // If set to true, the tile coordinates won't be wrapped by world width (-180 to 180 longitude) or clamped to lie within world height (-90 to 90). Use this if you use Leaflet for maps that don't reflect the real world (e.g. game, indoor or photo maps).
  bool continuousWorld = false;
  // If set to true, the tiles just won't load outside the world width (-180 to 180 longitude) instead of repeating.
  bool noWrap = false;
  // The zoom number used in tile URLs will be offset with this value.
  num zoomOffset  = 0;
  // If set to true, the zoom number used in tile URLs will be reversed (maxZoom - zoom instead of zoom)
  bool zoomReverse = false;
  // The opacity of the tile layer.
  num opacity = 1.0;
  // The explicit zIndex of the tile layer. Not set by default.
  num zIndex;
  // If true, all the tiles that are not visible after panning are removed (for better performance). true by default on mobile WebKit, otherwise false.
  bool unloadInvisibleTiles;
  // If false, new tiles are loaded during panning, otherwise only after it (for better performance). true by default on mobile WebKit, otherwise false.
  bool updateWhenIdle;
  // If true and user is on a retina display, it will request four tiles of half the specified size and a bigger zoom level in place of one to utilize the high resolution.
  bool detectRetina;
  // If true, all the tiles that are not visible after panning are placed in a reuse queue from which they will be fetched when new tiles become visible (as opposed to dynamically creating new ones). This will in theory keep memory usage low and eliminate the need for reserving new memory whenever a new tile is needed.
  bool reuseTiles = false;
  // When this option is set, the TileLayer only loads tiles that are in the given geographical bounds.
  LatLngBounds bounds;
}

// TileLayer is used for standard xyz-numbered tile layers.
class TileLayer extends Object with core.Events {

  String _url;
  BaseMap _map;
  bool _animated;

  final Map<String, Object> options = {
    'minZoom': 0,
    'maxZoom': 18,
    'tileSize': 256,
    'subdomains': 'abc',
    'errorTileUrl': '',
    'attribution': '',
    'zoomOffset': 0,
    'opacity': 1,
    /*
    maxNativeZoom: null,
    zIndex: null,
    tms: false,
    continuousWorld: false,
    noWrap: false,
    zoomReverse: false,
    detectRetina: false,
    reuseTiles: false,
    bounds: false,
    */
    'unloadInvisibleTiles': core.Browser.mobile,
    'updateWhenIdle': core.Browser.mobile
  };

  TileLayer(String url, Map<String, Object> options) {
    this.options.addAll(options);

    // detecting retina displays, adjusting tileSize and zoom levels
    if (options['detectRetina'] && core.Browser.retina && options['maxZoom'] > 0) {

      options['tileSize'] = (options['tileSize'] / 2).floor();
      options['zoomOffset']++;

      if (options['minZoom'] > 0) {
        options['minZoom']--;
      }
      this.options['maxZoom']--;
    }

    if (options.containsKey('bounds')) {
      options['bounds'] = new LatLngBounds.latLngBounds(options['bounds']);
    }

    this._url = url;

    var subdomains = this.options['subdomains'];

    if (subdomains is String) {
      this.options['subdomains'] = subdomains.split('');
    }
  }

  onAdd(BaseMap map) {
    this._map = map;
    this._animated = map._zoomAnimated;

    // create a container div for tiles
    this._initContainer();

    // set up events
    map.on({
      'viewreset': this._reset,
      'moveend': this._update
    }, this);

    if (this._animated) {
      map.on({
        'zoomanim': this._animateZoom,
        'zoomend': this._endZoomAnim
      }, this);
    }

    if (!this.options.updateWhenIdle) {
      this._limitedUpdate = L.Util.limitExecByInterval(this._update, 150, this);
      map.on('move', this._limitedUpdate, this);
    }

    this._reset();
    this._update();
  }

  addTo(map) {
    map.addLayer(this);
    return this;
  }

  onRemove(map) {
    this._container.parentNode.removeChild(this._container);

    map.off({
      'viewreset': this._reset,
      'moveend': this._update
    }, this);

    if (this._animated) {
      map.off({
        'zoomanim': this._animateZoom,
        'zoomend': this._endZoomAnim
      }, this);
    }

    if (!this.options.updateWhenIdle) {
      map.off('move', this._limitedUpdate, this);
    }

    this._container = null;
    this._map = null;
  }

  bringToFront() {
    var pane = this._map._panes.tilePane;

    if (this._container) {
      pane.appendChild(this._container);
      this._setAutoZIndex(pane, Math.max);
    }

    return this;
  }

  bringToBack() {
    var pane = this._map._panes.tilePane;

    if (this._container) {
      pane.insertBefore(this._container, pane.firstChild);
      this._setAutoZIndex(pane, Math.min);
    }

    return this;
  }

  getAttribution() {
    return this.options.attribution;
  }

  getContainer() {
    return this._container;
  }

  setOpacity(opacity) {
    this.options.opacity = opacity;

    if (this._map) {
      this._updateOpacity();
    }

    return this;
  }

  setZIndex(zIndex) {
    this.options.zIndex = zIndex;
    this._updateZIndex();

    return this;
  }

  setUrl(url, noRedraw) {
    this._url = url;

    if (!noRedraw) {
      this.redraw();
    }

    return this;
  }

  redraw() {
    if (this._map) {
      this._reset({hard: true});
      this._update();
    }
    return this;
  }

  _updateZIndex() {
    if (this._container && this.options.zIndex != null) {
      this._container.style.zIndex = this.options.zIndex;
    }
  }

  _setAutoZIndex(pane, compare) {

    var layers = pane.children,
        edgeZIndex = -compare(Infinity, -Infinity), // -Infinity for max, Infinity for min
        zIndex, i, len;

    len = layers.length;
    for (i = 0; i < len; i++) {

      if (layers[i] != this._container) {
        zIndex = parseInt(layers[i].style.zIndex, 10);

        if (!isNaN(zIndex)) {
          edgeZIndex = compare(edgeZIndex, zIndex);
        }
      }
    }

    this.options.zIndex = this._container.style.zIndex =
            (isFinite(edgeZIndex) ? edgeZIndex : 0) + compare(1, -1);
  }

  _updateOpacity() {
    var i,
        tiles = this._tiles;

    if (L.Browser.ielt9) {
      for (i in tiles) {
        L.DomUtil.setOpacity(tiles[i], this.options.opacity);
      }
    } else {
      L.DomUtil.setOpacity(this._container, this.options.opacity);
    }
  }

  _initContainer() {
    var tilePane = this._map._panes.tilePane;

    if (!this._container) {
      this._container = L.DomUtil.create('div', 'leaflet-layer');

      this._updateZIndex();

      if (this._animated) {
        var className = 'leaflet-tile-container';

        this._bgBuffer = L.DomUtil.create('div', className, this._container);
        this._tileContainer = L.DomUtil.create('div', className, this._container);

      } else {
        this._tileContainer = this._container;
      }

      tilePane.appendChild(this._container);

      if (this.options.opacity < 1) {
        this._updateOpacity();
      }
    }
  }

  _reset(e) {
    for (var key in this._tiles) {
      this.fire('tileunload', {'tile': this._tiles[key]});
    }

    this._tiles = {};
    this._tilesToLoad = 0;

    if (this.options.reuseTiles) {
      this._unusedTiles = [];
    }

    this._tileContainer.innerHTML = '';

    if (this._animated && e && e.hard) {
      this._clearBgBuffer();
    }

    this._initContainer();
  }

  _getTileSize() {
    var map = this._map,
        zoom = map.getZoom() + this.options.zoomOffset,
        zoomN = this.options.maxNativeZoom,
        tileSize = this.options.tileSize;

    if (zoomN && zoom > zoomN) {
      tileSize = Math.round(map.getZoomScale(zoom) / map.getZoomScale(zoomN) * tileSize);
    }

    return tileSize;
  }

  _update() {

    if (!this._map) { return; }

    var map = this._map,
        bounds = map.getPixelBounds(),
        zoom = map.getZoom(),
        tileSize = this._getTileSize();

    if (zoom > this.options.maxZoom || zoom < this.options.minZoom) {
      return;
    }

    var tileBounds = L.bounds(
            bounds.min.divideBy(tileSize)._floor(),
            bounds.max.divideBy(tileSize)._floor());

    this._addTilesFromCenterOut(tileBounds);

    if (this.options.unloadInvisibleTiles || this.options.reuseTiles) {
      this._removeOtherTiles(tileBounds);
    }
  }

  _addTilesFromCenterOut(bounds) {
    var queue = [],
        center = bounds.getCenter();

    var j, i, point;

    for (j = bounds.min.y; j <= bounds.max.y; j++) {
      for (i = bounds.min.x; i <= bounds.max.x; i++) {
        point = new L.Point(i, j);

        if (this._tileShouldBeLoaded(point)) {
          queue.push(point);
        }
      }
    }

    var tilesToLoad = queue.length;

    if (tilesToLoad == 0) { return; }

    // load tiles in order of their distance to center
    queue.sort((a, b) {
      return a.distanceTo(center) - b.distanceTo(center);
    });

    var fragment = document.createDocumentFragment();

    // if its the first batch of tiles to load
    if (!this._tilesToLoad) {
      this.fire('loading');
    }

    this._tilesToLoad += tilesToLoad;

    for (i = 0; i < tilesToLoad; i++) {
      this._addTile(queue[i], fragment);
    }

    this._tileContainer.appendChild(fragment);
  }

  _tileShouldBeLoaded(tilePoint) {
    if (this._tiles.contains(tilePoint.x + ':' + tilePoint.y)) {
      return false; // already loaded
    }

    var options = this.options;

    if (!options.continuousWorld) {
      var limit = this._getWrapTileNum();

      // don't load if exceeds world bounds
      if ((options.noWrap && (tilePoint.x < 0 || tilePoint.x >= limit.x)) ||
        tilePoint.y < 0 || tilePoint.y >= limit.y) { return false; }
    }

    if (options.bounds) {
      var tileSize = options.tileSize,
          nwPoint = tilePoint.multiplyBy(tileSize),
          sePoint = nwPoint.add([tileSize, tileSize]),
          nw = this._map.unproject(nwPoint),
          se = this._map.unproject(sePoint);

      // TODO temporary hack, will be removed after refactoring projections
      // https://github.com/Leaflet/Leaflet/issues/1618
      if (!options.continuousWorld && !options.noWrap) {
        nw = nw.wrap();
        se = se.wrap();
      }

      if (!options.bounds.intersects([nw, se])) { return false; }
    }

    return true;
  }

  _removeOtherTiles(bounds) {
    var kArr, x, y, key;

    for (key in this._tiles) {
      kArr = key.split(':');
      x = parseInt(kArr[0], 10);
      y = parseInt(kArr[1], 10);

      // remove tile if it's out of bounds
      if (x < bounds.min.x || x > bounds.max.x || y < bounds.min.y || y > bounds.max.y) {
        this._removeTile(key);
      }
    }
  }

  _removeTile(key) {
    var tile = this._tiles[key];

    this.fire('tileunload', {'tile': tile, 'url': tile.src});

    if (this.options.reuseTiles) {
      L.DomUtil.removeClass(tile, 'leaflet-tile-loaded');
      this._unusedTiles.push(tile);

    } else if (tile.parentNode == this._tileContainer) {
      this._tileContainer.removeChild(tile);
    }

    // for https://github.com/CloudMade/Leaflet/issues/137
    if (!L.Browser.android) {
      tile.onload = null;
      tile.src = L.Util.emptyImageUrl;
    }

    delete(this._tiles[key]);
  }

  _addTile(tilePoint, container) {
    var tilePos = this._getTilePos(tilePoint);

    // get unused tile - or create a new tile
    var tile = this._getTile();

    /*
    Chrome 20 layouts much faster with top/left (verify with timeline, frames)
    Android 4 browser has display issues with top/left and requires transform instead
    (other browsers don't currently care) - see debug/hacks/jitter.html for an example
    */
    L.DomUtil.setPosition(tile, tilePos, L.Browser.chrome);

    this._tiles[tilePoint.x + ':' + tilePoint.y] = tile;

    this._loadTile(tile, tilePoint);

    if (tile.parentNode != this._tileContainer) {
      container.appendChild(tile);
    }
  }

  _getZoomForUrl() {

    var options = this.options,
        zoom = this._map.getZoom();

    if (options.zoomReverse) {
      zoom = options.maxZoom - zoom;
    }

    zoom += options.zoomOffset;

    return options.maxNativeZoom ? Math.min(zoom, options.maxNativeZoom) : zoom;
  }

  _getTilePos(tilePoint) {
    var origin = this._map.getPixelOrigin(),
        tileSize = this._getTileSize();

    return tilePoint.multiplyBy(tileSize).subtract(origin);
  }

  // image-specific code (override to implement e.g. Canvas or SVG tile layer)

  getTileUrl(tilePoint) {
    return L.Util.template(this._url, L.extend({
      s: this._getSubdomain(tilePoint),
      z: tilePoint.z,
      x: tilePoint.x,
      y: tilePoint.y
    }, this.options));
  }

  _getWrapTileNum() {
    var crs = this._map.options.crs,
        size = crs.getSize(this._map.getZoom());
    return size.divideBy(this._getTileSize())._floor();
  }

  _adjustTilePoint(tilePoint) {

    var limit = this._getWrapTileNum();

    // wrap tile coordinates
    if (!this.options.continuousWorld && !this.options.noWrap) {
      tilePoint.x = ((tilePoint.x % limit.x) + limit.x) % limit.x;
    }

    if (this.options.tms) {
      tilePoint.y = limit.y - tilePoint.y - 1;
    }

    tilePoint.z = this._getZoomForUrl();
  }

  _getSubdomain(tilePoint) {
    var index = Math.abs(tilePoint.x + tilePoint.y) % this.options.subdomains.length;
    return this.options.subdomains[index];
  }

  _getTile() {
    if (this.options.reuseTiles && this._unusedTiles.length > 0) {
      var tile = this._unusedTiles.pop();
      this._resetTile(tile);
      return tile;
    }
    return this._createTile();
  }

  // Override if data stored on a tile needs to be cleaned up before reuse
  _resetTile(/*tile*/) {}

  _createTile() {
    var tile = L.DomUtil.create('img', 'leaflet-tile');
    tile.style.width = tile.style.height = this._getTileSize() + 'px';
    tile.galleryimg = 'no';

    tile.onselectstart = tile.onmousemove = L.Util.falseFn;

    if (L.Browser.ielt9 && this.options.opacity != null) {
      L.DomUtil.setOpacity(tile, this.options.opacity);
    }
    // without this hack, tiles disappear after zoom on Chrome for Android
    // https://github.com/Leaflet/Leaflet/issues/2078
    if (L.Browser.mobileWebkit3d) {
      tile.style.WebkitBackfaceVisibility = 'hidden';
    }
    return tile;
  }

  _loadTile(tile, tilePoint) {
    tile._layer  = this;
    tile.onload  = this._tileOnLoad;
    tile.onerror = this._tileOnError;

    this._adjustTilePoint(tilePoint);
    tile.src     = this.getTileUrl(tilePoint);

    this.fire('tileloadstart', {
      'tile': tile,
      'url': tile.src
    });
  }

  _tileLoaded() {
    this._tilesToLoad--;

    if (this._animated) {
      L.DomUtil.addClass(this._tileContainer, 'leaflet-zoom-animated');
    }

    if (!this._tilesToLoad) {
      this.fire('load');

      if (this._animated) {
        // clear scaled tiles after all new tiles are loaded (for performance)
        clearTimeout(this._clearBgBufferTimer);
        this._clearBgBufferTimer = setTimeout(L.bind(this._clearBgBuffer, this), 500);
      }
    }
  }

  _tileOnLoad() {
    var layer = this._layer;

    //Only if we are loading an actual image
    if (this.src != L.Util.emptyImageUrl) {
      L.DomUtil.addClass(this, 'leaflet-tile-loaded');

      layer.fire('tileload', {
        'tile': this,
        'url': this.src
      });
    }

    layer._tileLoaded();
  }

  _tileOnError() {
    var layer = this._layer;

    layer.fire('tileerror', {
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