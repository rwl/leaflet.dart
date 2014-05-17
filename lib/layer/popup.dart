part of leaflet.layer;

class PopupOptions {
  // Max width of the popup.
  num maxWidth  = 300;
  // Min width of the popup.
  num minWidth  = 50;
  // If set, creates a scrollable container of the given height inside a popup if its content exceeds it.
  num maxHeight;
  // Set it to false if you don't want the map to do panning animation to fit the opened popup.
  bool autoPan = true;
  // Set it to true if you want to prevent users from panning the popup off of the screen while it is open.
  bool keepInView  = false;
  // Controls the presense of a close button in the popup.
  bool closeButton = true;
  // The offset of the popup position. Useful to control the anchor of the popup when opening it on some overlays.
  Point offset  = new Point(0, 6);
  // The margin between the popup and the top left corner of the map view after autopanning was performed.
  Point autoPanPaddingTopLeft;
  // The margin between the popup and the bottom right corner of the map view after autopanning was performed.
  Point autoPanPaddingBottomRight;
  // Equivalent of setting both top left and bottom right autopan padding to the same value.
  Point autoPanPadding = new Point(5, 5);
  // Whether to animate the popup on zoom. Disable it if you have problems with Flash content inside popups.
  bool zoomAnimation = true;
  // Set it to false if you want to override the default behavior of the popup closing when user clicks the map (set globally by the Map closePopupOnClick option).
  bool closeOnClick;
  // A custom class name to assign to the popup.
  String className = '';
}

// Popup is used for displaying popups on the map.
class Popup extends Object with Events {

  Map<String, Object> options = {
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
  };

  var _source;
  bool _animated, _isOpen;
  BaseMap _map;
  var _container;
  LatLng _latlng;
  var _content;
  var _closeButton;
  Element _contentNode;
  var _wrapper;
  var _tip, _tipContainer;
  var _containerWidth, _containerBottom, _containerLeft;

  Popup(Map<String, Object> options, var source) {
    this.options.addAll(options);

    this._source = source;
    this._animated = Browser.any3d && this.options['zoomAnimation'];
    this._isOpen = false;
  }

  onAdd(BaseMap map) {
    this._map = map;

    if (this._container == null) {
      this._initLayout();
    }

    final bool animFade = map.options['fadeAnimation'];

    if (animFade) {
      DomUtil.setOpacity(this._container, 0);
    }
    map.panes['popupPane'].append(this._container);

    map.on(this._getEvents(), this);

    this.update();

    if (animFade) {
      DomUtil.setOpacity(this._container, 1);
    }

    this.fire('open');

    map.fire('popupopen', {'popup': this});

    if (this._source) {
      this._source.fire('popupopen', {'popup': this});
    }
  }

  addTo(BaseMap map) {
    map.addLayer(this);
    return this;
  }

  openOn(BaseMap map) {
    map.openPopup(this);
    return this;
  }

  onRemove(map) {
    map._panes.popupPane.removeChild(this._container);

    Util.falseFn(this._container.offsetWidth); // force reflow

    map.off(this._getEvents(), this);

    if (map.options['fadeAnimation']) {
      DomUtil.setOpacity(this._container, 0);
    }

    this._map = null;

    this.fire('close');

    map.fire('popupclose', {'popup': this});

    if (this._source) {
      this._source.fire('popupclose', {'popup': this});
    }
  }

  getLatLng() {
    return this._latlng;
  }

  setLatLng(LatLng latlng) {
    this._latlng = new LatLng.latLng(latlng);
    if (this._map != null) {
      this._updatePosition();
      this._adjustPan();
    }
    return this;
  }

  getContent() {
    return this._content;
  }

  setContent(content) {
    this._content = content;
    this.update();
    return this;
  }

  update() {
    if (this._map == null) { return; }

    this._container.style.visibility = 'hidden';

    this._updateContent();
    this._updateLayout();
    this._updatePosition();

    this._container.style.visibility = '';

    this._adjustPan();
  }

  _getEvents() {
    final events = {
      'viewreset': this._updatePosition
    };

    if (this._animated) {
      events['zoomanim'] = this._zoomAnimation;
    }
    if (this.options.containsKey('closeOnClick') ? this.options['closeOnClick'] : this._map.options['closePopupOnClick']) {
      events['preclick'] = this._close;
    }
    if (this.options.containsKey('keepInView')) {
      events['moveend'] = this._adjustPan;
    }

    return events;
  }

  _close() {
    if (this._map != null) {
      this._map.closePopup(this);
    }
  }

  _initLayout() {
    var prefix = 'leaflet-popup',
      containerClass = prefix + ' ' + this.options['className'] + ' leaflet-zoom-' +
              (this._animated ? 'animated' : 'hide'),
      container = this._container = DomUtil.create('div', containerClass),
      closeButton;

    if (this.options.containsKey('closeButton')) {
      closeButton = this._closeButton =
              DomUtil.create('a', prefix + '-close-button', container);
      closeButton.href = '#close';
      closeButton.innerHTML = '&#215;';
      DomEvent.disableClickPropagation(closeButton);

      DomEvent.on(closeButton, 'click', this._onCloseButtonClick, this);
    }

    var wrapper = this._wrapper =
            DomUtil.create('div', prefix + '-content-wrapper', container);
    DomEvent.disableClickPropagation(wrapper);

    this._contentNode = DomUtil.create('div', prefix + '-content', wrapper);

    DomEvent.disableScrollPropagation(this._contentNode);
    DomEvent.on(wrapper, 'contextmenu', L.DomEvent.stopPropagation);

    this._tipContainer = DomUtil.create('div', prefix + '-tip-container', container);
    this._tip = DomUtil.create('div', prefix + '-tip', this._tipContainer);
  }

  _updateContent() {
    if (!this._content) { return; }

    if (this._content is String) {
      this._contentNode.setInnerHtml(this._content);
    } else {
      while (this._contentNode.hasChildNodes()) {
        this._contentNode.removeChild(this._contentNode.firstChild);
      }
      this._contentNode.append(this._content);
    }
    this.fire('contentupdate');
  }

  _updateLayout() {
    var container = this._contentNode,
        style = container.style;

    style.width = '';
    style.whiteSpace = 'nowrap';

    var width = container.offsetWidth;
    width = math.min(width, this.options['maxWidth']);
    width = math.max(width, this.options['minWidth']);

    style.width = (width + 1) + 'px';
    style.whiteSpace = '';

    style.height = '';

    var height = container.offsetHeight,
        maxHeight = this.options['maxHeight'],
        scrolledClass = 'leaflet-popup-scrolled';

    if (maxHeight && height > maxHeight) {
      style.height = maxHeight + 'px';
      DomUtil.addClass(container, scrolledClass);
    } else {
      DomUtil.removeClass(container, scrolledClass);
    }

    this._containerWidth = this._container.offsetWidth;
  }

  _updatePosition() {
    if (this._map == null) { return; }

    var pos = this._map.latLngToLayerPoint(this._latlng),
        animated = this._animated,
        offset = new Point(this.options['offset']);

    if (animated) {
      DomUtil.setPosition(this._container, pos);
    }

    this._containerBottom = -offset.y - (animated ? 0 : pos.y);
    this._containerLeft = -(this._containerWidth / 2).round() + offset.x + (animated ? 0 : pos.x);

    // bottom position the popup in case the height of the popup changes (images loading etc)
    this._container.style.bottom = this._containerBottom + 'px';
    this._container.style.left = this._containerLeft + 'px';
  }

  _zoomAnimation(opt) {
    var pos = this._map.latLngToNewLayerPoint(this._latlng, opt.zoom, opt.center);

    DomUtil.setPosition(this._container, pos);
  }

  _adjustPan() {
    if (!this.options.containsKey('autoPan')) { return; }

    final map = this._map;
    var containerHeight = this._container.offsetHeight,
        containerWidth = this._containerWidth;

    final layerPos = new Point(this._containerLeft, -containerHeight - this._containerBottom);

    if (this._animated) {
      layerPos._add(DomUtil.getPosition(this._container));
    }

    final containerPos = map.layerPointToContainerPoint(layerPos),
        padding = new Point(options['autoPanPadding']),
        paddingTL = new Point(options.containsKey('autoPanPaddingTopLeft') ? options['autoPanPaddingTopLeft'] : padding),
        paddingBR = new Point(options.containsKey('autoPanPaddingBottomRight') ? options['autoPanPaddingBottomRight'] : padding);
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

    if (dx || dy) {
      map
          .fire('autopanstart')
          .panBy([dx, dy]);
    }
  }

  _onCloseButtonClick(e) {
    this._close();
    DomEvent.stop(e);
  }
}