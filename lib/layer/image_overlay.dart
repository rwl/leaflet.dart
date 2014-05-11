part of leaflet.layer;

// ImageOverlay is used to overlay images over the map (to specific geographical bounds).
class ImageOverlay extends Object with Events {
  var options = {
    'opacity': 1
  };

  ImageOverlay(url, bounds, options) { // (String, LatLngBounds, Object)
    this._url = url;
    this._bounds = L.latLngBounds(bounds);

    L.setOptions(this, options);
  }

  onAdd(map) {
    this._map = map;

    if (!this._image) {
      this._initImage();
    }

    map._panes.overlayPane.appendChild(this._image);

    map.on('viewreset', this._reset, this);

    if (map.options.zoomAnimation && L.Browser.any3d) {
      map.on('zoomanim', this._animateZoom, this);
    }

    this._reset();
  }

  onRemove(map) {
    map.getPanes().overlayPane.removeChild(this._image);

    map.off('viewreset', this._reset, this);

    if (map.options.zoomAnimation) {
      map.off('zoomanim', this._animateZoom, this);
    }
  }

  addTo(map) {
    map.addLayer(this);
    return this;
  }

  setOpacity(opacity) {
    this.options.opacity = opacity;
    this._updateOpacity();
    return this;
  }

  // TODO remove bringToFront/bringToBack duplication from TileLayer/Path
  bringToFront() {
    if (this._image) {
      this._map._panes.overlayPane.appendChild(this._image);
    }
    return this;
  }

  bringToBack() {
    var pane = this._map._panes.overlayPane;
    if (this._image) {
      pane.insertBefore(this._image, pane.firstChild);
    }
    return this;
  }

  setUrl(url) {
    this._url = url;
    this._image.src = this._url;
  }

  getAttribution() {
    return this.options.attribution;
  }

  _initImage() {
    this._image = L.DomUtil.create('img', 'leaflet-image-layer');

    if (this._map.options.zoomAnimation && L.Browser.any3d) {
      L.DomUtil.addClass(this._image, 'leaflet-zoom-animated');
    } else {
      L.DomUtil.addClass(this._image, 'leaflet-zoom-hide');
    }

    this._updateOpacity();

    //TODO createImage util method to remove duplication
    L.extend(this._image, {
      'galleryimg': 'no',
      'onselectstart': L.Util.falseFn,
      'onmousemove': L.Util.falseFn,
      'onload': L.bind(this._onImageLoad, this),
      'src': this._url
    });
  }

  _animateZoom(e) {
    var map = this._map,
        image = this._image,
        scale = map.getZoomScale(e.zoom),
        nw = this._bounds.getNorthWest(),
        se = this._bounds.getSouthEast(),

        topLeft = map._latLngToNewLayerPoint(nw, e.zoom, e.center),
        size = map._latLngToNewLayerPoint(se, e.zoom, e.center)._subtract(topLeft),
        origin = topLeft._add(size._multiplyBy((1 / 2) * (1 - 1 / scale)));

    image.style[L.DomUtil.TRANSFORM] =
            L.DomUtil.getTranslateString(origin) + ' scale(' + scale + ') ';
  }

  _reset() {
    var image   = this._image,
        topLeft = this._map.latLngToLayerPoint(this._bounds.getNorthWest()),
        size = this._map.latLngToLayerPoint(this._bounds.getSouthEast())._subtract(topLeft);

    L.DomUtil.setPosition(image, topLeft);

    image.style.width  = size.x + 'px';
    image.style.height = size.y + 'px';
  }

  _onImageLoad() {
    this.fire('load');
  }

  _updateOpacity() {
    L.DomUtil.setOpacity(this._image, this.options.opacity);
  }
}