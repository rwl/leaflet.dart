library leaflet.layer.marker;

import 'dart:html';

import '../../core/core.dart' as core;
import '../../core/core.dart' show EventType;
import '../../map/map.dart';
import '../../geo/geo.dart';
import '../../dom/dom.dart';

part 'default_icon.dart';
part 'div_icon.dart';
part 'icon.dart';
part 'marker_drag.dart';
part 'popup_marker.dart';

class MarkerOptions {
  // Icon class to use for rendering the marker. See Icon documentation for
  // details on how to customize the marker icon. Set to new Icon.Default()
  // by default.
  Icon icon;
  // If false, the marker will not emit mouse events and will act as a part
  // of the underlying map.
  bool clickable = true;
  // Whether the marker is draggable with mouse/touch or not.
  bool draggable = false;
  // Whether the marker can be tabbed to with a keyboard and clicked by
  // pressing enter.
  bool keyboard = true;
  // Text for the browser tooltip that appear on marker hover (no tooltip by
  // default).
  String  title = '';
  // Text for the alt attribute of the icon image (useful for accessibility).
  String  alt = '';
  // By default, marker images zIndex is set automatically based on its
  // latitude. Use this option if you want to put the marker on top of all
  // others (or below), specifying a high value like 1000 (or high negative
  // value, respectively).
  num zIndexOffset  = 0;
  // The opacity of the marker.
  num opacity = 1.0;
  // If true, the marker will get on top of others when you hover the mouse over it.
  bool riseOnHover  = false;
  // The z-index offset used for the riseOnHover feature.
  num riseOffset  = 250;
}



// Marker is used to display clickable/draggable icons on the map.
class Marker extends Object with core.Events {

  LatLng _latlng;
  BaseMap _map;
  core.Handler dragging;
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
  final MarkerOptions options;

  Marker(LatLng latlng, this.options) {
    _latlng = new LatLng.latLng(latlng);
  }

  void onAdd(BaseMap map) {
    _map = map;

    map.on(EventType.VIEWRESET, this.update, this);

    _initIcon();
    update();
    fire(EventType.ADD);

    if (map.animationOptions.zoomAnimation && map.animationOptions.markerZoomAnimation) {
      map.on(EventType.ZOOMANIM, this._animateZoom, this);
    }
  }

  // Adds the marker to the map.
  void addTo(BaseMap map) {
    map.addLayer(this);
  }

  void onRemove(BaseMap map) {
    if (dragging) {
      dragging.disable();
    }

    _removeIcon();
    _removeShadow();

    fire(EventType.REMOVE);

    map.off({
      'viewreset': this.update,
      'zoomanim': this._animateZoom
    }, this);

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
  void update() {
    if (_icon != null) {
      var pos = _map.latLngToLayerPoint(_latlng).round();
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

    DomUtil.addClass(icon, classToAdd);

    if (options.keyboard) {
      icon.tabIndex = '0';
    }

    _icon = icon;

    _initInteraction();

    if (options.riseOnHover) {
      DomEvent
        .on(icon, 'mouseover', _bringToFront, this)
        .on(icon, 'mouseout', _resetZIndex, this);
    }

    final newShadow = options.icon.createShadow(_shadow);
    bool addShadow = false;

    if (newShadow != _shadow) {
      _removeShadow();
      addShadow = true;
    }

    if (newShadow != null) {
      DomUtil.addClass(newShadow, classToAdd);
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
      DomEvent
          .off(_icon, 'mouseover', _bringToFront)
          .off(_icon, 'mouseout', _resetZIndex);
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
    DomUtil.setPosition(_icon, pos);

    if (_shadow != null) {
      DomUtil.setPosition(_shadow, pos);
    }

    _zIndex = pos.y + options.zIndexOffset;

    _resetZIndex();
  }

  void _updateZIndex(num offset) {
    _icon.style.zIndex = _zIndex + offset;
  }

  _animateZoom(num zoom, LatLng center) {
    final pos = _map.latLngToNewLayerPoint(_latlng, zoom, center).round();

    _setPos(pos);
  }

  void _initInteraction() {
    if (!options.clickable) { return; }

    // TODO refactor into something shared with Map/Path/etc. to DRY it up

    final icon = _icon;
    final events = [EventType.DBLCLICK, EventType.MOUSEDOWN, EventType.MOUSEOVER,
                    EventType.MOUSEOUT, EventType.CONTEXTMENU];

    DomUtil.addClass(icon, 'leaflet-clickable');
    DomEvent.on(icon, 'click', this._onMouseClick, this);
    DomEvent.on(icon, 'keypress', this._onKeyPress, this);

    for (int i = 0; i < events.length; i++) {
      DomEvent.on(icon, events[i], this._fireMouseEvent, this);
    }

    if (Handler.MarkerDrag) {
      dragging = new Handler.MarkerDrag(this);

      if (options.draggable) {
        dragging.enable();
      }
    }
  }

  void _onMouseClick(core.Event e) {
    final wasDragged = dragging != null && dragging.moved();

    if (hasEventListeners(e.type) || wasDragged) {
      DomEvent.stopPropagation(e);
    }

    if (wasDragged) { return; }

    if ((!dragging || !dragging._enabled) && _map.dragging != null && _map.dragging.moved()) {
      return;
    }

    fire(e.type, {
      'originalEvent': e,
      'latlng': _latlng
    });
  }

  void _onKeyPress(core.Event e) {
    if (e.keyCode == 13) {
      fire(EventType.CLICK, {
        'originalEvent': e,
        'latlng': _latlng
      });
    }
  }

  void _fireMouseEvent(core.Event e) {

    fire(e.type, {
      'originalEvent': e,
      'latlng': _latlng
    });

    // TODO proper custom event propagation
    // this line will always be called if marker is in a FeatureGroup
    if (e.type == 'contextmenu' && hasEventListeners(e.type)) {
      DomEvent.preventDefault(e);
    }
    if (e.type != 'mousedown') {
      DomEvent.stopPropagation(e);
    } else {
      DomEvent.preventDefault(e);
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
    DomUtil.setOpacity(_icon, options.opacity);
    if (_shadow != null) {
      DomUtil.setOpacity(_shadow, options.opacity);
    }
  }

  void _bringToFront() {
    _updateZIndex(options.riseOffset);
  }

  void _resetZIndex() {
    _updateZIndex(0);
  }
}