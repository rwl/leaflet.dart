library leaflet.layer.marker;

import 'dart:html' show document, Element, ImageElement, DivElement, Event;
import 'dart:html' as html;
import 'dart:async' show Stream, StreamController, StreamSubscription;

import '../../core/core.dart' show Browser, EventType, MapEvent, Events,
  Handler, LocationEvent, MouseEvent, DragEndEvent, PopupEvent, ZoomEvent;
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
  Icon icon = new DefaultIcon();

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
class Marker extends Layer {

  LatLng _latlng;
  LeafletMap _map;
  MarkerDrag dragging;
  ImageElement _icon, _shadow;
  int _zIndex;

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

  StreamSubscription<MapEvent> _viewResetSubscription, _zoomAnimSubscription;

  Marker(LatLng latlng, [this.options=null]) {
    if (options == null) {
      options = new MarkerOptions();
    }
    _latlng = new LatLng.latLng(latlng);
  }

  void onAdd(LeafletMap map) {
    _map = map;

    //map.on(EventType.VIEWRESET, update);
    _viewResetSubscription = map.onViewReset.listen(update);

    _initIcon();
    update();
    //fire(EventType.ADD);
    _addController.add(new MapEvent(EventType.ADD));

    if (map.options.zoomAnimation && map.options.markerZoomAnimation) {
      //map.on(EventType.ZOOMANIM, _animateZoom);
      _zoomAnimSubscription = map.onZoomStart.listen(_animateZoom);
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

    //fire(EventType.REMOVE);
    _removeController.add(new MapEvent(EventType.REMOVE));

    //map.off(EventType.VIEWRESET, update);
    //map.off(EventType.ZOOMANIM, _animateZoom);
    _viewResetSubscription.cancel();
    if (_zoomAnimSubscription != null) {
      _zoomAnimSubscription.cancel();
    }

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

    //fireEvent(new MouseEvent(EventType.MOVE, _latlng, null, null, null));
    _moveController.add(new MouseEvent(EventType.MOVE, _latlng, null, null, null));
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
  void update([Object obj=null, MapEvent e=null]) {
    if (_icon != null) {
      final pos = _map.latLngToLayerPoint(_latlng).rounded();
      _setPos(pos);
    }
  }

  StreamSubscription<html.MouseEvent> _mouseOverSubscription, _mouseOutSubscription;

  void _initIcon() {
    final map = _map;
    final animation = (map.options.zoomAnimation && map.options.markerZoomAnimation);
    final classToAdd = animation ? 'leaflet-zoom-animated' : 'leaflet-zoom-hide';

    final icon = options.icon.createIcon(_icon);
    bool addIcon = false;

    // if we're not reusing the icon, remove the old one and init new one
    if (icon != _icon) {
      if (_icon != null) {
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

    icon.classes.add(classToAdd);

    if (options.keyboard) {
      icon.tabIndex = 0;
    }

    _icon = icon;

    _initInteraction();

    if (options.riseOnHover) {
      //dom.on(icon, 'mouseover', _bringToFront);
      //dom.on(icon, 'mouseout', _resetZIndex);
      icon.onMouseOver.listen(_bringToFront);
      icon.onMouseOut.listen(_resetZIndex);
    }

    final newShadow = options.icon.createShadow(_shadow);
    bool addShadow = false;

    if (newShadow != _shadow) {
      _removeShadow();
      addShadow = true;
    }

    if (newShadow != null) {
      newShadow.classes.add(classToAdd);
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
//      dom.off(_icon, 'mouseover', _bringToFront);
//      dom.off(_icon, 'mouseout', _resetZIndex);
      _mouseOverSubscription.cancel();
      _mouseOutSubscription.cancel();
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

  void _updateZIndex(int offset) {
    _icon.style.zIndex = (_zIndex + offset).toString();
  }

//  _animateZoom(num zoom, LatLng center) {
//    final pos = _map.latLngToNewLayerPoint(_latlng, zoom, center).rounded();

  _animateZoom(MapEvent e) {
    final zoomEvent = e as ZoomEvent;
    final pos = _map.latLngToNewLayerPoint(_latlng, zoomEvent.zoom, zoomEvent.center).rounded();

    _setPos(pos);
  }

//  StreamSubscription<html.MouseEvent> _doubleClickSubscription,
//    _mouseDownSubscription, _mouseOverSubscription, _mouseOutSubscription,
//    _contextMenuSubscription;

  void _initInteraction() {
    if (!options.clickable) { return; }

    // TODO refactor into something shared with Map/Path/etc. to DRY it up

    final icon = _icon;
    //final events = [EventType.DBLCLICK, EventType.MOUSEDOWN, EventType.MOUSEOVER,
    //                EventType.MOUSEOUT, EventType.CONTEXTMENU];

    icon.classes.add('leaflet-clickable');
//    dom.on(icon, 'click', _onMouseClick, this);
//    dom.on(icon, 'keypress', _onKeyPress, this);
    icon.onClick.listen(_onMouseClick);
    icon.onKeyPress.listen(_onKeyPress);

    /*for (int i = 0; i < events.length; i++) {
      dom.on(icon, events[i], _fireMouseEvent, this);
    }*/
    /*_doubleClickSubscription = */icon.onDoubleClick.listen(_fireDoubleClickEvent);
    /*_mouseDownSubscription = */icon.onMouseDown.listen(_fireMouseDownEvent);
    /*_mouseOverSubscription = */icon.onMouseOver.listen(_fireMouseOverEvent);
    /*_mouseOutSubscription = */icon.onMouseOut.listen(_fireMouseOutEvent);
    /*_contextmenuSubscription = */icon.onContextMenu.listen(_fireContextMenuEvent);

    //if (Handler.MarkerDrag) {
    dragging = new MarkerDrag(this);

    if (options.draggable) {
      dragging.enable();
    }
    //}
  }

  void _onMouseClick(html.MouseEvent e) {
    final wasDragged = dragging != null && dragging.moved();

    final type = EventType.CLICK;//new EventType.from(e.type);
    //if (hasEventListeners(type) || wasDragged) {
    if (_clickController.hasListener || wasDragged) {
      //dom.stopPropagation(e);
      e.stopPropagation();
    }

    if (wasDragged) { return; }

    if ((dragging == null || !dragging.enabled()) && _map.dragging != null && _map.dragging.moved()) {
      return;
    }

    //fireEvent(new MouseEvent(type, _latlng, null, null, e));
    _clickController.add(new MouseEvent(type, _latlng, null, null, e));
  }

  void _onKeyPress(html.KeyboardEvent e) {
    if (e.keyCode == 13) {
      //fireEvent(new MouseEvent(EventType.CLICK, _latlng, null, null, e));
      _clickController.add(new MouseEvent(EventType.CLICK, _latlng, null, null, e));
    }
  }

  void _fireDoubleClickEvent(Event e) {
    _dblClickController.add(new MouseEvent(EventType.DBLCLICK, _latlng, null, null, e));
    e.stopPropagation();
  }

  void _fireMouseDownEvent(Event e) {
    _mouseDownController.add(new MouseEvent(EventType.MOUSEDOWN, _latlng, null, null, e));
    e.preventDefault();
  }

  void _fireMouseOverEvent(Event e) {
    _mouseOverController.add(new MouseEvent(EventType.MOUSEOVER, _latlng, null, null, e));
    e.stopPropagation();
  }

  void _fireMouseOutEvent(Event e) {
    _mouseOutController.add(new MouseEvent(EventType.MOUSEOUT, _latlng, null, null, e));
    e.stopPropagation();
  }

  void _fireContextMenuEvent(Event e) {
    _contextMenuController.add(new MouseEvent(EventType.CONTEXTMENU, _latlng, null, null, e));
    if (_contextMenuController.hasListener) {
      e.preventDefault();
    }
    e.stopPropagation();
  }

  /*void _fireMouseEvent(Event e, EventType type) {
    //final type = new EventType.from(e.type);
    fireEvent(new MouseEvent(type, _latlng, null, null, e));

    // TODO proper custom event propagation
    // this line will always be called if marker is in a FeatureGroup
    if (type == EventType.CONTEXTMENU && hasEventListeners(type)) {
      //dom.preventDefault(e);
      e.preventDefault();
    }
    if (type != EventType.MOUSEDOWN) {
      //dom.stopPropagation(e);
      e.stopPropagation();
    } else {
      //dom.preventDefault(e);
      e.preventDefault();
    }
  }*/

  // Changes the opacity of the marker.
  void setOpacity(num opacity) {
    options.opacity = opacity;
    if (_map != null) {
      _updateOpacity();
    }
  }

  void _updateOpacity() {
    _icon.style.opacity =  '${options.opacity}';
    if (_shadow != null) {
      _shadow.style.opacity = '${options.opacity}';
    }
  }

  void _bringToFront([html.MouseEvent e]) {
    _updateZIndex(options.riseOffset);
  }

  void _resetZIndex([html.MouseEvent e]) {
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

  void closePopup([_]) {
    if (_popup != null) {
      _popup.close();
    }
  }

  void togglePopup(_) {
    if (_popup != null) {
      if (_popup.open) {
        closePopup();
      } else {
        openPopup();
      }
    }
  }

  StreamSubscription<MouseEvent> _popupClickSubscription;
  StreamSubscription<MapEvent> _popupRemoveSubscription, _popupMoveSubscription;

  void bindPopupContent(String content, [MarkerOptions options=null]) {
    final popup = new Popup(options, this);
    bindPopup(popup, options);
  }

  void bindPopup(Popup popup, [MarkerOptions options=null]) {
    /*if (options == null) {
      options = new MarkerOptions();
    }*/
    Point2D anchor = new Point2D(0, 0);
    if (options != null && options.icon.options.popupAnchor != null) {
      anchor = new Point2D.point(options.icon.options.popupAnchor);
    }

    anchor = anchor + this.options.offset;

    if (options != null && options.offset != null) {
      anchor = anchor + options.offset;
    }

    options = new MarkerOptions.from(options);
    options.offset = anchor;

    if (!_popupHandlersAdded) {
      //on(EventType.CLICK, togglePopup);
      //on(EventType.REMOVE, closePopup);
      //on(EventType.MOVE, _movePopup);
      _popupClickSubscription = onClick.listen(togglePopup);
      _popupRemoveSubscription = onRemoveMarker.listen(closePopup);
      _popupMoveSubscription = onMove.listen(_movePopup);
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
      //off(EventType.CLICK, togglePopup);
      //off(EventType.REMOVE, closePopup);
      //off(EventType.MOVE, _movePopup);
      _popupClickSubscription.cancel();
      _popupRemoveSubscription.cancel();
      _popupMoveSubscription.cancel();
      _popupHandlersAdded = false;
    }
  }

  Popup getPopup() {
    return _popup;
  }

  void _movePopup(LocationEvent e) {
    _popup.setLatLng(e.latlng);
  }


  toGeoJSON() {
    return GeoJSON.getFeature(this, {
      'type': 'Point',
      'coordinates': GeoJSON.latLngToCoords(getLatLng())
    });
  }

  StreamController<MouseEvent> _clickController = new StreamController.broadcast();
  StreamController<MouseEvent> _dblClickController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseDownController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOverController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOutController = new StreamController.broadcast();
  StreamController<MouseEvent> _contextMenuController = new StreamController.broadcast();
  StreamController<MapEvent> _dragStartController = new StreamController.broadcast();
  StreamController<MapEvent> _dragController = new StreamController.broadcast();
  StreamController<DragEndEvent> _dragEndController = new StreamController.broadcast();
  StreamController<MapEvent> _moveController = new StreamController.broadcast();
  StreamController<MapEvent> _addController = new StreamController.broadcast();
  StreamController<MapEvent> _removeController = new StreamController.broadcast();
  StreamController<PopupEvent> _popupOpenController = new StreamController.broadcast();
  StreamController<PopupEvent> _popupCloseController = new StreamController.broadcast();

  Stream<MouseEvent> get onClick => _clickController.stream;
  Stream<MouseEvent> get onDblClick => _dblClickController.stream;
  Stream<MouseEvent> get onMouseDown => _mouseDownController.stream;
  Stream<MouseEvent> get onMouseOver => _mouseOverController.stream;
  Stream<MouseEvent> get onMouseOut => _mouseOutController.stream;
  Stream<MouseEvent> get onContextMenu => _contextMenuController.stream;
  Stream<MapEvent> get onDragStart => _dragStartController.stream;
  Stream<MapEvent> get onDrag => _dragController.stream;
  Stream<DragEndEvent> get onDragEnd => _dragEndController.stream;
  Stream<MapEvent> get onMove => _moveController.stream;
  Stream<MapEvent> get onAddMarker => _addController.stream;
  Stream<MapEvent> get onRemoveMarker => _removeController.stream;
  Stream<PopupEvent> get onPopupOpen => _popupOpenController.stream;
  Stream<PopupEvent> get onPopupClose => _popupCloseController.stream;


  void fire(EventType eventType) {
    final event = new MapEvent(eventType);
    fireEvent(event);
  }

  /**
   * For internal use.
   */
  //StreamController<PopupEvent> get popupOpenController;
  //StreamController<PopupEvent> get popupCloseController;
  void fireEvent(MapEvent event) {
    switch (event.type) {
      case EventType.CLICK:
        _clickController.add(event);
        break;
      case EventType.POPUPOPEN:
        _popupOpenController.add(event);
        break;
      case EventType.POPUPCLOSE:
        _popupCloseController.add(event);
        break;
    }

//    switch (event.type) {
//    case EventType.CLICK:
//      _clickController.add(event);
//      break;
//    case EventType.DBLCLICK:
//      _dblClickController.add(event);
//      break;
//    case EventType.MOUSEDOWN:
//      _mouseDownController.add(event);
//      break;
//    case EventType.MOUSEOVER:
//      _mouseOverController.add(event);
//      break;
//    case EventType.MOUSEOUT:
//      _mouseOutController.add(event);
//      break;
//    case EventType.CONTEXTMENU:
//      _contextMenuController.add(event);
//      break;
//    case EventType.DRAGSTART:
//      _dragStartController.add(event);
//      break;
//    case EventType.DRAG:
//      _dragController.add(event);
//      break;
//    }
  }

  /**
   * For internal use.
   */
  ImageElement get icon => _icon;
  ImageElement get shadow => _shadow;

}