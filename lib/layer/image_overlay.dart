part of leaflet.layer;

class ImageOverlayOptions {
  /**
   * The opacity of the image overlay.
   */
  num opacity = 1.0;

  /**
   * The attribution text of the image overlay.
   */
  String attribution = '';
}

/**
 * ImageOverlay is used to overlay images over the map (to specific geographical bounds).
 */
class ImageOverlay extends Object with core.Events {

  ImageOverlayOptions options;

  /*Map<String, Object> options = {
    'opacity': 1
  };*/

  String _url;
  LatLngBounds _bounds;
  BaseMap _map;
  var _image;

  ImageOverlay(String url, LatLngBounds bounds, this.options) {
    this._url = url;
    this._bounds = new LatLngBounds.latLngBounds(bounds);
  }

  /**
   * Adds the overlay to the map.
   */
  onAdd(BaseMap map) {
    this._map = map;

    if (this._image == null) {
      this._initImage();
    }

    map.panes['overlayPane'].append(this._image);

    map.on(EventType.VIEWRESET, this._reset, this);

    if (map.animationOptions.zoomAnimation && Browser.any3d) {
      map.on(EventType.ZOOMANIM, this._animateZoom, this);
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

  /**
   * Sets the opacity of the overlay.
   */
  setOpacity(opacity) {
    this.options.opacity = opacity;
    this._updateOpacity();
    return this;
  }

  /**
   * Brings the layer to the top of all overlays.
   *
   * TODO remove bringToFront/bringToBack duplication from TileLayer/Path
   */
  bringToFront() {
    if (this._image) {
      this._map.panes['overlayPane'].append(this._image);
    }
    return this;
  }

  /**
   * Brings the layer to the bottom of all overlays.
   */
  bringToBack() {
    final pane = this._map.panes['overlayPane'];
    if (this._image) {
      pane.insertBefore(this._image, pane.firstChild);
    }
    return this;
  }

  /**
   * Changes the URL of the image.
   */
  setUrl(String url) {
    this._url = url;
    this._image.src = this._url;
  }

  getAttribution() {
    return this.options.attribution;
  }

  _initImage() {
    this._image = DomUtil.create('img', 'leaflet-image-layer');

    if (this._map.animationOptions.zoomAnimation && Browser.any3d) {
      DomUtil.addClass(this._image, 'leaflet-zoom-animated');
    } else {
      DomUtil.addClass(this._image, 'leaflet-zoom-hide');
    }

    this._updateOpacity();

    // TODO: createImage util method to remove duplication
//    L.extend(this._image, {
//      'galleryimg': 'no',
//      'onselectstart': Util.falseFn,
//      'onmousemove': Util.falseFn,
//      'onload': bind(this._onImageLoad, this),
//      'src': this._url
//    });
  }

  _animateZoom(e) {
    var map = this._map,
        image = this._image,
        scale = map.getZoomScale(e.zoom),
        nw = this._bounds.getNorthWest(),
        se = this._bounds.getSouthEast(),

        topLeft = map.latLngToNewLayerPoint(nw, e.zoom, e.center),
        size = map.latLngToNewLayerPoint(se, e.zoom, e.center)._subtract(topLeft),
        origin = topLeft._add(size._multiplyBy((1 / 2) * (1 - 1 / scale)));

    image.style[DomUtil.TRANSFORM] =
            DomUtil.getTranslateString(origin) + ' scale($scale) ';
  }

  _reset() {
    var image   = this._image,
        topLeft = this._map.latLngToLayerPoint(this._bounds.getNorthWest()),
        size = this._map.latLngToLayerPoint(this._bounds.getSouthEast())._subtract(topLeft);

    DomUtil.setPosition(image, topLeft);

    image.style.width  = size.x + 'px';
    image.style.height = size.y + 'px';
  }

  _onImageLoad() {
    this.fire(EventType.LOAD);
  }

  _updateOpacity() {
    DomUtil.setOpacity(this._image, this.options.opacity);
  }
}