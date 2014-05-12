library leaflet.layer.marker;

import 'dart:html';

import '../../core/core.dart';
import '../../map/map.dart';
import '../../geo/geo.dart';
import '../../dom/dom.dart';

part 'default_icon.dart';
part 'div_icon.dart';
part 'icon.dart';
part 'marker_drag.dart';
part 'popup_marker.dart';

// Marker is used to display clickable/draggable icons on the map.
class Marker extends Object with Events {

  LatLng _latlng;
  BaseMap _map;
  var dragging;
  var _icon, _shadow;
  var _zIndex;

  final Map<String, Object> options = {
    'icon': new Icon.Default(),
    'title': '',
    'alt': '',
    'clickable': true,
    'draggable': false,
    'keyboard': true,
    'zIndexOffset': 0,
    'opacity': 1,
    'riseOnHover': false,
    'riseOffset': 250
  };

  Marker(LatLng latlng, Map<String, Object> options) {
    this.options.addAll(options);
    this._latlng = new LatLng.latLng(latlng);
  }

  onAdd(BaseMap map) {
    this._map = map;

    map.on('viewreset', this.update, this);

    this._initIcon();
    this.update();
    this.fire('add');

    if (map.options['zoomAnimation'] && map.options['markerZoomAnimation']) {
      map.on('zoomanim', this._animateZoom, this);
    }
  }

  addTo(BaseMap map) {
    map.addLayer(this);
    return this;
  }

  onRemove(BaseMap map) {
    if (this.dragging) {
      this.dragging.disable();
    }

    this._removeIcon();
    this._removeShadow();

    this.fire('remove');

    map.off({
      'viewreset': this.update,
      'zoomanim': this._animateZoom
    }, this);

    this._map = null;
  }

  getLatLng() {
    return this._latlng;
  }

  setLatLng(latlng) {
    this._latlng = new LatLng.latLng(latlng);

    this.update();

    return this.fire('move', { 'latlng': this._latlng });
  }

  setZIndexOffset(offset) {
    this.options['zIndexOffset'] = offset;
    this.update();

    return this;
  }

  setIcon(icon) {

    this.options['icon'] = icon;

    if (this._map != null) {
      this._initIcon();
      this.update();
    }

    if (this._popup != null) {
      this.bindPopup(this._popup);
    }

    return this;
  }

  update() {
    if (this._icon != null) {
      var pos = this._map.latLngToLayerPoint(this._latlng).round();
      this._setPos(pos);
    }

    return this;
  }

  _initIcon() {
    final options = this.options;
    final map = this._map;
    final animation = (map.options['zoomAnimation'] && map.options['markerZoomAnimation']);
    final classToAdd = animation ? 'leaflet-zoom-animated' : 'leaflet-zoom-hide';

    final icon = options['icon'].createIcon(this._icon);
    bool addIcon = false;

    // if we're not reusing the icon, remove the old one and init new one
    if (icon != this._icon) {
      if (this._icon) {
        this._removeIcon();
      }
      addIcon = true;

      if (options.containsKey('title')) {
        icon.title = options['title'];
      }

      if (options.containsKey('alt')) {
        icon.alt = options['alt'];
      }
    }

    L.DomUtil.addClass(icon, classToAdd);

    if (options.containsKey('keyboard')) {
      icon.tabIndex = '0';
    }

    this._icon = icon;

    this._initInteraction();

    if (options.containsKey('riseOnHover')) {
      DomEvent
        .on(icon, 'mouseover', this._bringToFront, this)
        .on(icon, 'mouseout', this._resetZIndex, this);
    }

    final newShadow = options['icon'].createShadow(this._shadow);
    bool addShadow = false;

    if (newShadow != this._shadow) {
      this._removeShadow();
      addShadow = true;
    }

    if (newShadow != null) {
      DomUtil.addClass(newShadow, classToAdd);
    }
    this._shadow = newShadow;


    if (options['opacity'] < 1) {
      this._updateOpacity();
    }


    final panes = this._map.panes;

    if (addIcon) {
      panes['markerPane'].append(this._icon);
    }

    if (newShadow != null && addShadow) {
      panes['shadowPane'].append(this._shadow);
    }
  }

  _removeIcon() {
    if (this.options.containsKey('riseOnHover')) {
      DomEvent
          .off(this._icon, 'mouseover', this._bringToFront)
          .off(this._icon, 'mouseout', this._resetZIndex);
    }

    this._map.panes['markerPane'].removeChild(this._icon);

    this._icon = null;
  }

  _removeShadow() {
    if (this._shadow != null) {
      this._map.panes['shadowPane'].removeChild(this._shadow);
    }
    this._shadow = null;
  }

  _setPos(pos) {
    DomUtil.setPosition(this._icon, pos);

    if (this._shadow != null) {
      DomUtil.setPosition(this._shadow, pos);
    }

    this._zIndex = pos.y + this.options['zIndexOffset'];

    this._resetZIndex();
  }

  _updateZIndex(offset) {
    this._icon.style.zIndex = this._zIndex + offset;
  }

  _animateZoom(opt) {
    var pos = this._map.latLngToNewLayerPoint(this._latlng, opt.zoom, opt.center).round();

    this._setPos(pos);
  }

  _initInteraction() {

    if (!this.options.containsKey('clickable')) { return; }

    // TODO refactor into something shared with Map/Path/etc. to DRY it up

    final icon = this._icon;
    final events = ['dblclick', 'mousedown', 'mouseover', 'mouseout', 'contextmenu'];

    DomUtil.addClass(icon, 'leaflet-clickable');
    DomEvent.on(icon, 'click', this._onMouseClick, this);
    DomEvent.on(icon, 'keypress', this._onKeyPress, this);

    for (int i = 0; i < events.length; i++) {
      DomEvent.on(icon, events[i], this._fireMouseEvent, this);
    }

    if (Handler.MarkerDrag) {
      this.dragging = new Handler.MarkerDrag(this);

      if (this.options.containsKey('draggable')) {
        this.dragging.enable();
      }
    }
  }

  _onMouseClick(e) {
    final wasDragged = this.dragging != null && this.dragging.moved();

    if (this.hasEventListeners(e.type) || wasDragged) {
      DomEvent.stopPropagation(e);
    }

    if (wasDragged) { return; }

    if ((!this.dragging || !this.dragging._enabled) && this._map.dragging != null && this._map.dragging.moved()) {
      return;
    }

    this.fire(e.type, {
      'originalEvent': e,
      'latlng': this._latlng
    });
  }

  _onKeyPress(e) {
    if (e.keyCode == 13) {
      this.fire('click', {
        'originalEvent': e,
        'latlng': this._latlng
      });
    }
  }

  _fireMouseEvent(e) {

    this.fire(e.type, {
      'originalEvent': e,
      'latlng': this._latlng
    });

    // TODO proper custom event propagation
    // this line will always be called if marker is in a FeatureGroup
    if (e.type == 'contextmenu' && this.hasEventListeners(e.type)) {
      DomEvent.preventDefault(e);
    }
    if (e.type != 'mousedown') {
      DomEvent.stopPropagation(e);
    } else {
      DomEvent.preventDefault(e);
    }
  }

  setOpacity(opacity) {
    this.options['opacity'] = opacity;
    if (this._map != null) {
      this._updateOpacity();
    }

    return this;
  }

  _updateOpacity() {
    DomUtil.setOpacity(this._icon, this.options['opacity']);
    if (this._shadow != null) {
      DomUtil.setOpacity(this._shadow, this.options['opacity']);
    }
  }

  _bringToFront() {
    this._updateZIndex(this.options['riseOffset']);
  }

  _resetZIndex() {
    this._updateZIndex(0);
  }
}