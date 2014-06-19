part of leaflet.core;

class EventType {

  final _value;

  const EventType._internal(this._value);

  toString() => '$_value';

  /**
   * Fired when the user clicks (or taps) the map.
   */
  static const CLICK  = const EventType._internal('click');

  /**
   * Fired when the user double-clicks (or double-taps) the map.
   */
  static const DBLCLICK  = const EventType._internal('dblclick');

  /**
   * Fired when the user pushes the mouse button on the map.
   */
  static const MOUSEDOWN  = const EventType._internal('mousedown');

  /**
   * Fired when the user pushes the mouse button on the map.
   */
  static const MOUSEUP  = const EventType._internal('mouseup');

  /**
   * Fired when the mouse enters the map.
   */
  static const MOUSEOVER  = const EventType._internal('mouseover');

  /**
   * Fired when the mouse leaves the map.
   */
  static const MOUSEOUT  = const EventType._internal('mouseout');

  /**
   * Fired while the mouse moves over the map.
   */
  static const MOUSEMOVE  = const EventType._internal('mousemove');

  /**
   * Fired when the user pushes the right mouse button on the map, prevents
   * default browser context menu from showing if there are listeners on this
   * event. Also fired on mobile when the user holds a single touch for a
   * second (also called long press).
   */
  static const CONTEXTMENU  = const EventType._internal('contextmenu');

  /**
   * Fired when the user focuses the map either by tabbing to it or
   * clicking/panning.
   */
  static const FOCUS  = const EventType._internal('focus');

  /**
   * Fired when the map looses focus.
   */
  static const BLUR  = const EventType._internal('blur');

  /**
   * Fired before mouse click on the map (sometimes useful when you want
   * something to happen on click before any existing click handlers start
   * running).
   */
  static const PRECLICK  = const EventType._internal('preclick');

  /**
   * Fired when the map is initialized (when its center and zoom are set for
   * the first time).
   */
  static const LOAD  = const EventType._internal('load');

  /**
   * Fired when the map is destroyed with remove method.
   */
  static const UNLOAD  = const EventType._internal('unload');

  /**
   * Fired when the map needs to redraw its content (this usually happens on
   * map zoom or load). Very useful for creating custom overlays.
   */
  static const VIEWRESET  = const EventType._internal('viewreset');

  /**
   * Fired when the view of the map starts changing (e.g. user starts dragging
   * the map).
   */
  static const MOVESTART  = const EventType._internal('movestart');

  /**
   * Fired on any movement of the map view.
   */
  static const MOVE  = const EventType._internal('move');

  /**
   * Fired when the view of the map ends changed (e.g. user stopped dragging
   * the map).
   */
  static const MOVEEND  = const EventType._internal('moveend');

  /**
   * Fired when the user starts dragging the map.
   */
  static const DRAGSTART  = const EventType._internal('dragstart');

  /**
   * Fired repeatedly while the user drags the map.
   */
  static const DRAG  = const EventType._internal('drag');

  /**
   * Fired when the user stops dragging the map.
   */
  static const DRAGEND  = const EventType._internal('dragend');

  /**
   * Fired when the map zoom is about to change (e.g. before zoom animation).
   */
  static const ZOOMSTART  = const EventType._internal('zoomstart');

  /**
   * Fired when the map zoom changes.
   */
  static const ZOOMEND  = const EventType._internal('zoomend');

  /**
   * Fired when the number of zoomlevels on the map is changed due to adding
   * or removing a layer.
   */
  static const ZOOMLEVELSCHANGE  = const EventType._internal('zoomlevelschange');

  /**
   * Fired when the map is resized.
   */
  static const RESIZE  = const EventType._internal('resize');

  /**
   * Fired when the map starts autopanning when opening a popup.
   */
  static const AUTOPANSTART  = const EventType._internal('autopanstart');

  /**
   * Fired when a new layer is added to the map.
   */
  static const LAYERADD  = const EventType._internal('layeradd');

  /**
   * Fired when some layer is removed from the map.
   */
  static const LAYERREMOVE  = const EventType._internal('layerremove');

  /**
   * Fired when the base layer is changed through the layer control.
   */
  static const BASELAYERCHANGE  = const EventType._internal('baselayerchange');

  /**
   * Fired when an overlay is selected through the layer control.
   */
  static const OVERLAYADD  = const EventType._internal('overlayadd');

  /**
   * Fired when an overlay is deselected through the layer control.
   */
  static const OVERLAYREMOVE  = const EventType._internal('overlayremove');

  /**
   * Fired when geolocation (using the locate method) went successfully.
   */
  static const LOCATIONFOUND  = const EventType._internal('locationfound');

  /**
   * Fired when geolocation (using the locate method) failed.
   */
  static const LOCATIONERROR  = const EventType._internal('locationerror');

  /**
   * Fired when a popup is opened (using openPopup method).
   */
  static const POPUPOPEN  = const EventType._internal('popupopen');

  /**
   * Fired when a popup is closed (using closePopup method).
   */
  static const POPUPCLOSE  = const EventType._internal('popupclose');

  /* Marker events. */

  /**
   * Fired when the marker is added to the map.
   */
  static const ADD = const EventType._internal('add');

  /**
   * Fired when the marker is removed from the map.
   */
  static const REMOVE = const EventType._internal('remove');


  static const MOUSEENTER  = const EventType._internal('mouseenter');
  static const MOUSELEAVE  = const EventType._internal('mouseleave');

  static const OPEN  = const EventType._internal('open');
  static const CLOSE  = const EventType._internal('close');

  static const ZOOMANIM = const EventType._internal('zoomanim');

  static const TILELAYERSLOAD = const EventType._internal('tilelayersload');

  static const BOXZOOMSTART = const EventType._internal('boxzoomstart');
  static const BOXZOOMEND = const EventType._internal('boxzoomend');

  static const PREDRAG = const EventType._internal('predrag');
}
