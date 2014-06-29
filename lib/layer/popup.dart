part of leaflet.layer;

class PopupOptions {
  /**
   * Max width of the popup.
   */
  num maxWidth  = 300;

  /**
   * Min width of the popup.
   */
  num minWidth  = 50;

  /**
   * If set, creates a scrollable container of the given height inside a popup if its content exceeds it.
   */
  num maxHeight;

  /**
   * Set it to false if you don't want the map to do panning animation to fit the opened popup.
   */
  bool autoPan = true;

  /**
   * Set it to true if you want to prevent users from panning the popup off of the screen while it is open.
   */
  bool keepInView  = false;

  /**
   * Controls the presense of a close button in the popup.
   */
  bool closeButton = true;

  /**
   * The offset of the popup position. Useful to control the anchor of the popup when opening it on some overlays.
   */
  Point2D offset  = new Point2D(0, 6);

  /**
   * The margin between the popup and the top left corner of the map view after autopanning was performed.
   */
  Point2D autoPanPaddingTopLeft;

  /**
   * The margin between the popup and the bottom right corner of the map view after autopanning was performed.
   */
  Point2D autoPanPaddingBottomRight;

  /**
   * Equivalent of setting both top left and bottom right autopan padding to the same value.
   */
  Point2D autoPanPadding = new Point2D(5, 5);

  /**
   * Whether to animate the popup on zoom. Disable it if you have problems with Flash content inside popups.
   */
  bool zoomAnimation = true;

  /**
   * Set it to false if you want to override the default behavior of the popup closing when user clicks the map (set globally by the Map closePopupOnClick option).
   */
  bool closeOnClick;

  /**
   * A custom class name to assign to the popup.
   */
  String className = '';
}

/**
 * Popup is used for displaying popups on the map.
 */
class Popup extends Layer with Events {

  /*Map<String, Object> options = {
    'minWidth': 50,
    'maxWidth': 300,
    // 'maxHeight': null,
    'autoPan': true,
    'closeButton': true,
    'offset': [0, 7],
    'autoPanPadding': [5, 5],
    // 'autoPanPaddingTopLeft': null,
    // 'autoPanPaddingBottomRight': null,
    'keepInView': false,
    'className': '',
    'zoomAnimation': true
  };*/
  final PopupOptions options;

  Events _source;
  bool _animated, _isOpen;
  LeafletMap _map;
  Element _container;
  LatLng _latlng;
  var _content;
  var _closeButton;
  Element _contentNode;
  var _wrapper;
  var _tip, _tipContainer;
  var _containerWidth, _containerBottom, _containerLeft;

  Popup(this.options, [this._source=null]) {
    _animated = Browser.any3d && options.zoomAnimation;
    _isOpen = false;
  }

  onAdd(LeafletMap map) {
    _map = map;

    if (_container == null) {
      _initLayout();
    }

    final bool animFade = map.animationOptions.fadeAnimation;

    if (animFade) {
      _container.style.opacity= '0';
    }
    map.panes['popupPane'].append(_container);

    _getEvents().forEach((EventType et, Function a) {
      map.on(et, a);
    });

    update();

    if (animFade) {
      _container.style.opacity = '1';
    }

    fire(EventType.OPEN);

    map.fireEvent(new PopupEvent(EventType.POPUPOPEN, this));

    if (_source != null) {
      _source.fireEvent(new PopupEvent(EventType.POPUPOPEN, this));
    }
  }

  // Adds the popup to the map.
  addTo(LeafletMap map) {
    map.addLayer(this);
    return this;
  }

  // Adds the popup to the map and closes the previous one.
  openOn(LeafletMap map) {
    map.openPopup(this);
    return this;
  }

  void onRemove(LeafletMap map) {
    //map.panes['popupPane'].removeChild(_container);
    _container.remove();

    final fn = (var x) => false;
    fn(_container.offsetWidth); // force reflow

    _getEvents().forEach((EventType et, Function a) {
      map.off(et, a);
    });

    if (map.animationOptions.fadeAnimation) {
      _container.style.opacity = '0';
    }

    _map = null;

    fire(EventType.CLOSE);

    map.fireEvent(new PopupEvent(EventType.POPUPCLOSE, this));

    if (_source != null) {
      _source.fireEvent(new PopupEvent(EventType.POPUPCLOSE, this));
    }
  }

  // Returns the geographical point of popup.
  LatLng getLatLng() {
    return _latlng;
  }

  // Sets the geographical point where the popup will open.
  void setLatLng(LatLng latlng) {
    _latlng = new LatLng.latLng(latlng);
    if (_map != null) {
      _updatePosition();
      _adjustPan();
    }
  }

  // Returns the content of the popup.
  Object getContent() {
    return _content;
  }

  // Sets the HTML content of the popup.
  void setContent(var content) {
    _content = content;
    update();
  }

  // Updates the popup content, layout and position. Useful for updating the
  // popup after something inside changed, e.g. image loaded.
  update() {
    if (_map == null) { return; }

    _container.style.visibility = 'hidden';

    _updateContent();
    _updateLayout();
    _updatePosition();

    _container.style.visibility = '';

    _adjustPan();
  }

  Map<EventType, Function>_getEvents() {
    final events = {
      EventType.VIEWRESET: _updatePosition
    };

    if (_animated) {
      events[EventType.ZOOMANIM] = _zoomAnimation;
    }
    if (options.closeOnClick != null ? options.closeOnClick : _map.interactionOptions.closePopupOnClick) {
      events[EventType.PRECLICK] = _close;
    }
    if (options.keepInView) {
      events[EventType.MOVEEND] = _adjustPan;
    }

    return events;
  }

  /**
   * For internal use.
   */
  void close() {
    _close();
  }

  void _close() {
    if (_map != null) {
      _map.closePopup(this);
    }
  }

  void _initLayout() {
    final prefix = 'leaflet-popup',
      containerClass = prefix + ' ' + options.className + ' leaflet-zoom-' +
              (_animated ? 'animated' : 'hide'),
      container = _container = dom.create('div', containerClass);

    if (options.closeButton) {
      final closeButton = _closeButton =
              dom.create('a', prefix + '-close-button', container);
      closeButton.href = '#close';
      closeButton.setInnerHtml('&#215;');
      dom.disableClickPropagation(closeButton);

      //dom.on(closeButton, 'click', _onCloseButtonClick, this);
      closeButton.onClick.listen(_onCloseButtonClick);
    }

    final wrapper = _wrapper =
            dom.create('div', prefix + '-content-wrapper', container);
    dom.disableClickPropagation(wrapper);

    _contentNode = dom.create('div', prefix + '-content', wrapper);

    dom.disableScrollPropagation(_contentNode);
    //dom.on(wrapper, 'contextmenu', dom.stopPropagation);
    wrapper.onContextMenu.listen((html.Event e) { e.stopPropagation(); });

    _tipContainer = dom.create('div', prefix + '-tip-container', container);
    _tip = dom.create('div', prefix + '-tip', _tipContainer);
  }

  void _updateContent() {
    if (!_content) { return; }

    if (_content is String) {
      _contentNode.setInnerHtml(_content);
    } else {
      while (_contentNode.hasChildNodes()) {
        //_contentNode.removeChild(_contentNode.firstChild);
        _contentNode.firstChild.remove();
      }
      _contentNode.append(_content);
    }
    fire(EventType.CONTENTUPDATE);
  }

  void _updateLayout() {
    final container = _contentNode,
        style = container.style;

    style.width = '';
    style.whiteSpace = 'nowrap';

    var width = container.offsetWidth;
    width = math.min(width, options.maxWidth);
    width = math.max(width, options.minWidth);

    style.width = (width + 1) + 'px';
    style.whiteSpace = '';

    style.height = '';

    final height = container.offsetHeight,
        maxHeight = options.maxHeight,
        scrolledClass = 'leaflet-popup-scrolled';

    if (maxHeight && height > maxHeight) {
      style.height = '${maxHeight}px';
      container.classes.add(scrolledClass);
    } else {
      container.classes.remove(scrolledClass);
    }

    _containerWidth = _container.offsetWidth;
  }

  void _updatePosition() {
    if (_map == null) { return; }

    final pos = _map.latLngToLayerPoint(_latlng),
        animated = _animated,
        offset = new Point2D.point(options.offset);

    if (animated) {
      dom.setPosition(_container, pos);
    }

    _containerBottom = -offset.y - (animated ? 0 : pos.y);
    _containerLeft = -(_containerWidth / 2).round() + offset.x + (animated ? 0 : pos.x);

    // bottom position the popup in case the height of the popup changes (images loading etc)
    _container.style.bottom = _containerBottom + 'px';
    _container.style.left = _containerLeft + 'px';
  }

  void _zoomAnimation(num zoom, LatLng center) {
    var pos = _map.latLngToNewLayerPoint(_latlng, zoom, center);

    dom.setPosition(_container, pos);
  }

  void _adjustPan() {
    if (!options.autoPan) { return; }

    final map = _map;
    var containerHeight = _container.offsetHeight,
        containerWidth = _containerWidth;

    final layerPos = new Point2D(_containerLeft, -containerHeight - _containerBottom);

    if (_animated) {
      layerPos.add(dom.getPosition(_container));
    }

    final containerPos = map.layerPointToContainerPoint(layerPos),
        padding = new Point2D.point(options.autoPanPadding),
        paddingTL = new Point2D.point(options.autoPanPaddingTopLeft != null ? options.autoPanPaddingTopLeft : padding),
        paddingBR = new Point2D.point(options.autoPanPaddingBottomRight != null ? options.autoPanPaddingBottomRight : padding);
    final size = map.getSize();
    num dx = 0,
        dy = 0;

    if (containerPos.x + containerWidth + paddingBR.x > size.x) { // right
      dx = containerPos.x + containerWidth - size.x + paddingBR.x;
    }
    if (containerPos.x - dx - paddingTL.x < 0) { // left
      dx = containerPos.x - paddingTL.x;
    }
    if (containerPos.y + containerHeight + paddingBR.y > size.y) { // bottom
      dy = containerPos.y + containerHeight - size.y + paddingBR.y;
    }
    if (containerPos.y - dy - paddingTL.y < 0) { // top
      dy = containerPos.y - paddingTL.y;
    }

    if (dx != 0 || dy != 0) {
      map.fire(EventType.AUTOPANSTART);
      map.panBy([dx, dy]);
    }
  }

  void _onCloseButtonClick(html.MouseEvent e) {
    _close();
    dom.stop(e);
  }

  /**
   * For internal use.
   */
  bool get open => _isOpen;

  /**
   * For internal use.
   */
  void set open(bool isOpen) {
    _isOpen = isOpen;
  }
}