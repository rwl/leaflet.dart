part of leaflet.layer;

class ImageOverlayOptions {
  /// The opacity of the image overlay.
  num opacity = 1.0;

  /// The attribution text of the image overlay.
  String attribution = '';
}

/// ImageOverlay is used to overlay images over the map (to specific
/// geographical bounds).
class ImageOverlay extends Layer {//with Events {

  ImageOverlayOptions options;

  String _url;
  LatLngBounds _bounds;
  LeafletMap _map;
  ImageElement _image;
  StreamSubscription<MapEvent> _viewResetSubscription, _zoomAnimSubscription;

  ImageOverlay(String url, LatLngBounds bounds, [this.options=null]) {
    if (options == null) {
      options = new ImageOverlayOptions();
    }
    _url = url;
    _bounds = new LatLngBounds.latLngBounds(bounds);
  }

  /// Adds the overlay to the map.
  void onAdd(LeafletMap map) {
    _map = map;

    if (_image == null) {
      _initImage();
    }

    map.panes['overlayPane'].append(_image);

    //map.on(EventType.VIEWRESET, _reset);
    _viewResetSubscription = map.onViewReset.listen(_reset);

    if (map.options.zoomAnimation) {// && Browser.any3d) {
      //map.on(EventType.ZOOMANIM, _animateZoom);
      _zoomAnimSubscription = map.onZoomAnim.listen(_animateZoom);
    }

    _reset();
  }

  void onRemove(LeafletMap map) {
    //map.panes['overlayPane'].removeChild(_image);
    _image.remove();

    //map.off(EventType.VIEWRESET, _reset);
    _viewResetSubscription.cancel();

    if (map.options.zoomAnimation) {
      //map.off(EventType.ZOOMANIM, _animateZoom);
      _zoomAnimSubscription.cancel();
    }
  }

  void addTo(LeafletMap map) {
    map.addLayer(this);
  }

  /// Sets the opacity of the overlay.
  void setOpacity(num opacity) {
    options.opacity = opacity;
    _updateOpacity();
  }

  /// Brings the layer to the top of all overlays.
  ///
  /// TODO remove bringToFront/bringToBack duplication from TileLayer/Path
  void bringToFront() {
    if (_image != null) {
      _map.panes['overlayPane'].append(_image);
    }
  }

  /// Brings the layer to the bottom of all overlays.
  void bringToBack() {
    final pane = _map.panes['overlayPane'];
    if (_image != null) {
      pane.insertBefore(_image, pane.firstChild);
    }
  }

  /// Changes the URL of the image.
  void setUrl(String url) {
    _url = url;
    _image.src = _url;
  }

  String getAttribution() {
    return options.attribution;
  }

  void _initImage() {
    _image = dom.create('img', 'leaflet-image-layer');

    if (_map.options.zoomAnimation) {// && browser.any3d) {
      _image.classes.add('leaflet-zoom-animated');
    } else {
      _image.classes.add('leaflet-zoom-hide');
    }

    _updateOpacity();

    // TODO: createImage util method to remove duplication
//    L.extend(_image, {
//      'galleryimg': 'no',
//      'onselectstart': Util.falseFn,
//      'onmousemove': Util.falseFn,
//      'onload': bind(_onImageLoad, this),
//      'src': _url
//    });
  }

  void _animateZoom(ZoomAnimEvent e) {
    final map = _map,
        image = _image,
        scale = map.getZoomScale(e.zoom),
        nw = _bounds.getNorthWest(),
        se = _bounds.getSouthEast(),

        topLeft = map.latLngToNewLayerPoint(nw, e.zoom, e.center),
        size = map.latLngToNewLayerPoint(se, e.zoom, e.center) - topLeft,
        origin = topLeft + (size * ((1 / 2) * (1 - 1 / scale)));

    image.style.transform/*[dom.TRANSFORM]*/ = dom.getTranslateString(origin) + ' scale($scale) ';
  }

  void _reset([_]) {
    final image = _image,
        topLeft = _map.latLngToLayerPoint(_bounds.getNorthWest()),
        size = _map.latLngToLayerPoint(_bounds.getSouthEast()) - topLeft;

    dom.setPosition(image, topLeft);

    image.style.width = '${size.x}px';
    image.style.height = '${size.y}px';
  }

  /*void _onImageLoad() {
    fire(EventType.LOAD);
  }*/

  void _updateOpacity() {
    _image.style.opacity = '${options.opacity}';
  }
}
