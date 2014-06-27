library leaflet.layer.marker;

import 'dart:html' show document, Element, ImageElement, DivElement, KeyboardEvent;

import '../../core/core.dart' show Browser, EventType, Event, Events, Handler, LocationEvent;
import '../../map/map.dart';
import '../../geo/geo.dart';
import '../../geometry/geometry.dart' show Point2D;
import '../../dom/dom.dart' as dom;
import '../layer.dart' show Layer, GeoJSON, Popup;

part 'default_icon.dart';
part 'div_icon.dart';
part 'icon.dart';
part 'marker_drag.dart';

class MarkerOptions {
  /**
   * Icon class to use for rendering the marker. See Icon documentation for
   * details on how to customize the marker icon. Set to new Icon.Default()
   * by default.
   */
  Icon icon;

  /**
   * If false, the marker will not emit mouse events and will act as a part
   * of the underlying map.
   */
  bool clickable = true;

  /**
   * Whether the marker is draggable with mouse/touch or not.
   */
  bool draggable = false;

  /**
   * Whether the marker can be tabbed to with a keyboard and clicked by
   * pressing enter.
   */
  bool keyboard = true;

  /**
   * Text for the browser tooltip that appear on marker hover (no tooltip by
   * default).
   */
  String  title = '';

  /**
   * Text for the alt attribute of the icon image (useful for accessibility).
   */
  String  alt = '';

  /**
   * By default, marker images zIndex is set automatically based on its
   * latitude. Use this option if you want to put the marker on top of all
   * others (or below), specifying a high value like 1000 (or high negative
   * value, respectively).
   */
  num zIndexOffset  = 0;

  /**
   * The opacity of the marker.
   */
  num opacity = 1.0;

  /**
   * If true, the marker will get on top of others when you hover the mouse over it.
   */
  bool riseOnHover  = false;

  /**
   * The z-index offset used for the riseOnHover feature.
   */
  num riseOffset  = 250;

  Point2D offset;
}


/**
 * Marker is used to display clickable/draggable icons on the map.
 */
class Marker extends Layer with Events {

  LatLng _latlng;
  LeafletMap _map;
  MarkerDrag dragging;
  var _icon, _shadow;
  var _zIndex;

  /*final Map<String, Object> options = {
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
  };*/
  MarkerOptions options;

  Marker(LatLng latlng, [this.options=null]) {
    if (options == null) {
      options = new MarkerOptions();
    }
    _latlng = new LatLng.latLng(latlng);
  }

  void onAdd(LeafletMap map) {
    _map = map;

    map.on(EventType.VIEWRESET, update, this);

    _initIcon();
    update();
    fire(EventType.ADD);

    if (map.animationOptions.zoomAnimation && map.animationOptions.markerZoomAnimation) {
      map.on(EventType.ZOOMANIM, _animateZoom, this);
    }
  }

  /**
   * Adds the marker to the map.
   */
  void addTo(LeafletMap map) {
    map.addLayer(this);
  }

  void onRemove(LeafletMap map) {
    if (dragging != null) {
      dragging.disable();
    }

    _removeIcon();
    _removeShadow();

    fire(EventType.REMOVE);

    map.off(EventType.VIEWRESET, update, this);
    map.off(EventType.ZOOMANIM, _animateZoom, this);

    _map = null;
  }

  // Returns the current geographical position of the marker.
  LatLng getLatLng() {
    return _latlng;
  }

  // Changes the marker position to the given point.
  void setLatLng(LatLng latlng) {
    _latlng = new LatLng.latLng(latlng);

    update();

    fire(EventType.MOVE, { 'latlng': _latlng });
  }

  // Changes the zIndex offset of the marker.
  void setZIndexOffset(num offset) {
    options.zIndexOffset = offset;
    update();
  }

  // Changes the marker icon.
  void setIcon(Icon icon) {
    options.icon = icon;

    if (_map != null) {
      _initIcon();
      update();
    }

    if (_popup != null) {
      bindPopup(_popup);
    }
  }

  // Updates the marker position, useful if coordinates of its latLng object
  // were changed directly.
  void update([Object obj=null, Event e=null]) {
    if (_icon != null) {
      final pos = _map.latLngToLayerPoint(_latlng).rounded();
      _setPos(pos);
    }
  }

  void _initIcon() {
    final map = _map;
    final animation = (map.animationOptions.zoomAnimation && map.animationOptions.markerZoomAnimation);
    final classToAdd = animation ? 'leaflet-zoom-animated' : 'leaflet-zoom-hide';

    final icon = options.icon.createIcon(_icon);
    bool addIcon = false;

    // if we're not reusing the icon, remove the old one and init new one
    if (icon != _icon) {
      if (_icon) {
        _removeIcon();
      }
      addIcon = true;

      if (options.title != null) {
        icon.title = options.title;
      }

      if (options.alt != null) {
        icon.alt = options.alt;
      }
    }

    dom.addClass(icon, classToAdd);

    if (options.keyboard) {
      icon.tabIndex = '0';
    }

    _icon = icon;

    _initInteraction();

    if (options.riseOnHover) {
      dom.on(icon, 'mouseover', _bringToFront, this);
      dom.on(icon, 'mouseout', _resetZIndex, this);
    }

    final newShadow = options.icon.createShadow(_shadow);
    bool addShadow = false;

    if (newShadow != _shadow) {
      _removeShadow();
      addShadow = true;
    }

    if (newShadow != null) {
      dom.addClass(newShadow, classToAdd);
    }
    _shadow = newShadow;


    if (options.opacity < 1) {
      _updateOpacity();
    }


    final panes = _map.panes;

    if (addIcon) {
      panes['markerPane'].append(_icon);
    }

    if (newShadow != null && addShadow) {
      panes['shadowPane'].append(_shadow);
    }
  }

  void _removeIcon() {
    if (options.riseOnHover) {
      dom.off(_icon, 'mouseover', _bringToFront);
      dom.off(_icon, 'mouseout', _resetZIndex);
    }

    //this._map.panes['markerPane'].removeChild(this._icon);
    _icon.remove();

    _icon = null;
  }

  void _removeShadow() {
    if (_shadow != null) {
      //this._map.panes['shadowPane'].removeChild(this._shadow);
      _shadow.remove();
    }
    _shadow = null;
  }

  void _setPos(pos) {
    dom.setPosition(_icon, pos);

    if (_shadow != null) {
      dom.setPosition(_shadow, pos);
    }

    _zIndex = pos.y + options.zIndexOffset;

    _resetZIndex();
  }

  void _updateZIndex(num offset) {
    _icon.style.zIndex = _zIndex + offset;
  }

  _animateZoom(num zoom, LatLng center) {
    final pos = _map.latLngToNewLayerPoint(_latlng, zoom, center).rounded();

    _setPos(pos);
  }

  void _initInteraction() {
    if (!options.clickable) { return; }

    // TODO refactor into something shared with Map/Path/etc. to DRY it up

    final icon = _icon;
    final events = [EventType.DBLCLICK, EventType.MOUSEDOWN, EventType.MOUSEOVER,
                    EventType.MOUSEOUT, EventType.CONTEXTMENU];

    dom.addClass(icon, 'leaflet-clickable');
    dom.on(icon, 'click', _onMouseClick, this);
    dom.on(icon, 'keypress', _onKeyPress, this);

    for (int i = 0; i < events.length; i++) {
      dom.on(icon, events[i], _fireMouseEvent, this);
    }

    //if (Handler.MarkerDrag) {
    dragging = new MarkerDrag(this);

    if (options.draggable) {
      dragging.enable();
    }
    //}
  }

  void _onMouseClick(Event e) {
    final wasDragged = dragging != null && dragging.moved();

    if (hasEventListeners(e.type) || wasDragged) {
      dom.stopPropagation(e);
    }

    if (wasDragged) { return; }

    if ((dragging == null || !dragging.enabled()) && _map.dragging != null && _map.dragging.moved()) {
      return;
    }

    fire(e.type, {
      'originalEvent': e,
      'latlng': _latlng
    });
  }

  void _onKeyPress(KeyboardEvent e) {
    if (e.keyCode == 13) {
      fire(EventType.CLICK, {
        'originalEvent': e,
        'latlng': _latlng
      });
    }
  }

  void _fireMouseEvent(Event e) {

    fire(e.type, {
      'originalEvent': e,
      'latlng': _latlng
    });

    // TODO proper custom event propagation
    // this line will always be called if marker is in a FeatureGroup
    if (e.type == 'contextmenu' && hasEventListeners(e.type)) {
      dom.preventDefault(e);
    }
    if (e.type != 'mousedown') {
      dom.stopPropagation(e);
    } else {
      dom.preventDefault(e);
    }
  }

  // Changes the opacity of the marker.
  void setOpacity(num opacity) {
    options.opacity = opacity;
    if (_map != null) {
      _updateOpacity();
    }
  }

  void _updateOpacity() {
    dom.setOpacity(_icon, options.opacity);
    if (_shadow != null) {
      dom.setOpacity(_shadow, options.opacity);
    }
  }

  void _bringToFront() {
    _updateZIndex(options.riseOffset);
  }

  void _resetZIndex() {
    _updateZIndex(0);
  }


  /* Popup extensions to Marker */

  Popup _popup;
  bool _popupHandlersAdded;

  openPopup() {
    if (_popup != null && _map != null && !_map.hasLayer(_popup)) {
      _popup.setLatLng(_latlng);
      _map.openPopup(_popup);
    }

    return this;
  }

  void closePopup([Object obj=null, Event e=null]) {
    if (_popup != null) {
      _popup.close();
    }
  }

  void togglePopup(Object obj, Event e) {
    if (_popup != null) {
      if (_popup.open) {
        closePopup();
      } else {
        openPopup();
      }
    }
  }

  void bindPopup(Popup popup, MarkerOptions options) {
    Point2D anchor = new Point2D(0, 0);
    if (options.icon.options.popupAnchor != null) {
      anchor = new Point2D.point(options.icon.options.popupAnchor);
    }

    anchor = anchor + this.options.offset;

    if (options != null && options.offset != null) {
      anchor = anchor + options.offset;
    }

    options = new MarkerOptions.from(options);
    options.offset = anchor;

    if (!_popupHandlersAdded) {
      this.on(EventType.CLICK, togglePopup, this);
      this.on(EventType.REMOVE, closePopup, this);
      this.on(EventType.MOVE, _movePopup, this);
      _popupHandlersAdded = true;
    }

    //if (content is Popup) {
      popup.options.addAll(options);
      _popup = popup;
    //} else {
    //  _popup = new Popup(options, this)
    //    ..setContent(content);
    //}
  }

  void setPopupContent(var content) {
    if (_popup != null) {
      _popup.setContent(content);
    }
  }

  void unbindPopup() {
    if (_popup != null) {
      _popup = null;
      this.off(EventType.CLICK, togglePopup, this);
      this.off(EventType.REMOVE, closePopup, this);
      this.off(EventType.MOVE, _movePopup, this);
      _popupHandlersAdded = false;
    }
  }

  Popup getPopup() {
    return _popup;
  }

  void _movePopup(Object obj, LocationEvent e) {
    _popup.setLatLng(e.latlng);
  }


  toGeoJSON() {
    return GeoJSON.getFeature(this, {
      'type': 'Point',
      'coordinates': GeoJSON.latLngToCoords(getLatLng())
    });
  }
}