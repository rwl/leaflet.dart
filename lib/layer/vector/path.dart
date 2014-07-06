part of leaflet.layer.vector;

class PathOptions {
  /**
   * Whether to draw stroke along the path. Set it to false to disable borders on polygons or circles.
   */
  bool stroke = true;

  /**
   * Stroke color.
   */
  String color = '#03f';

  /**
   * Stroke width in pixels.
   */
  num weight = 5;

  /**
   * Stroke opacity.
   */
  num opacity = 0.5;

  /**
   * Whether to fill the path with color. Set it to false to disable filling on polygons or circles.
   */
  bool fill;

  /**
   * Same as color Fill color.
   */
  String fillColor;

  /**
   * Fill opacity.
   */
  num fillOpacity = 0.2;

  /**
   * A string that defines the stroke dash pattern. Doesn't work on canvas-powered layers (e.g. Android 2).
   */
  String dashArray;

  /**
   * A string that defines shape to be used at the end of the stroke.
   */
  String lineCap;

  /**
   * A string that defines shape to be used at the corners of the stroke.
   */
  String lineJoin;

  /**
   * If false, the vector will not emit mouse events and will act as a part of the underlying map.
   */
  bool clickable = true;

  /**
   * Sets the pointer-events attribute on the path if SVG backend is used.
   */
  String pointerEvents;

  /**
   * Custom class name set on an element.
   */
  String className;// = '';
}

/**
 * Path is a base class for rendering vector paths on a map. Inherited by Polyline, Circle, etc.
 */
abstract class Path extends Layer {

  // how much to extend the clip area around the map view
  // (relative to its size, e.g. 0.5 is half the screen in each direction)
  // set it so that SVG element doesn't exceed 1280px (vectors flicker on dragend if it is)
  static var CLIP_PADDING = (() {
    var max = Browser.mobile ? 1280 : 2000,
        target = (max / math.max(window.outerWidth, window.outerHeight) - 1) / 2;
    return math.max(0, math.min(0.5, target));
  })();

  /*Map<String, Object> options = {
    'stroke': true,
    'color': '#0033ff',
    'dashArray': null,
    'lineCap': null,
    'lineJoin': null,
    'weight': 5,
    'opacity': 0.5,

    'fill': false,
    'fillColor': null, //same as color by default
    'fillOpacity': 0.2,

    'clickable': true
  };*/
  PathOptions options;

  List<LatLng> _latlngs;

  LeafletMap _map;
  Element _container;
  var _stroke, _fill;

  StreamSubscription<MapEvent> _viewResetSubscription, _moveEndSubscription;

  Path(this.options);

  onAdd(LeafletMap map) {
    _map = map;

    if (_container == null) {
      this._initElements();
      this._initEvents();
    }

    projectLatlngs();
    this._updatePath();

    if (_container != null) {
      _map.pathRoot.append(_container);
    }

    //fire(EventType.ADD);
    _addController.add(new MapEvent(EventType.ADD));

    //map.on(EventType.VIEWRESET, projectLatlngs, this);
    //map.on(EventType.MOVEEND, this._updatePath, this);
    _viewResetSubscription = map.onViewReset.listen(projectLatlngs);
    _moveEndSubscription = map.onMoveEnd.listen(_updatePath);
  }

  /**
   * Adds the layer to the map.
   */
  void addTo(LeafletMap map) {
    map.addLayer(this);
  }

  void onRemove(LeafletMap map) {
    //map.pathRoot.removeChild(_container);
    _container.remove();

    // Need to fire remove event before we set _map to null as the event hooks might need the object
    //fire(EventType.REMOVE);
    _removeController.add(new MapEvent(EventType.REMOVE));
    _map = null;

    if (Browser.vml) {
      _container = null;
      _stroke = null;
      _fill = null;
    }

    //map.off(EventType.VIEWRESET, projectLatlngs, this);
    //map.off(EventType.MOVEEND, this._updatePath, this);
    _viewResetSubscription.cancel();
    _moveEndSubscription.cancel();
  }

  /**
   * Do all projection stuff here.
   */
  void projectLatlngs();

  /**
   * Changes the appearance of a Path based on the options in the Path options object.
   */
  void setStyle(PathOptions style) {
    options = style;

    if (_container != null) {
      _updateStyle();
    }
  }

  /**
   * Redraws the layer. Sometimes useful after you changed the coordinates that the path uses.
   */
  void redraw() {
    if (_map != null) {
      projectLatlngs();
      this._updatePath();
    }
  }


  /*
   * Popup extensions to Path (polylines, polygons, circles).
   */

  Popup _popup;
  bool _popupHandlersAdded = false;

  /**
   * Binds a popup with a particular HTML content to a click on this path.
   */
  void bindPopupHtml(String html, PopupOptions options) {
    _popup = new Popup(options, this);
    _popup.setContent(html);
  }

  void bindPopupElement(Element elem, PopupOptions options) {
    _popup = new Popup(options, this);
    _popup.setContent(elem);
  }

  StreamSubscription<MapEvent> _popupClickSubscription, _popupRemoveSubscription;

  /**
   * Binds a given popup object to the path.
   */
  void bindPopup(Popup popup, PopupOptions options) {
    _popup = popup;

    if (!_popupHandlersAdded) {
      //on(EventType.CLICK, _openPopup, this);
      //on(EventType.REMOVE, closePopup, this);
      _popupClickSubscription = onClick.listen(_openPopup);
      _popupRemoveSubscription = onRemoveMarker.listen(closePopup);

      _popupHandlersAdded = true;
    }
  }

  /**
   * Unbinds the popup previously bound to the path with bindPopup.
   */
  void unbindPopup() {
    if (_popup != null) {
      _popup = null;
      //off(EventType.CLICK, _openPopup);
      //off(EventType.REMOVE, closePopup);
      _popupClickSubscription.cancel();
      _popupRemoveSubscription.cancel();

      _popupHandlersAdded = false;
    }
  }

  /**
   * Opens the popup previously bound by the bindPopup method in the given point, or in one of the path's points if not specified.
   */
  void openPopup([LatLng latlng = null]) {

    if (_popup != null) {
      // Open the popup from one of the path's points if not specified.
      if (latlng == null) {
        latlng = _latlngs[(_latlngs.length / 2).floor()];
      }

      _openPopup(new LocationEvent()..latlng = latlng);
    }
  }

  /**
   * Closes the path's bound popup if it is opened.
   */
  void closePopup(_) {
    if (_popup != null) {
      _popup.close();
    }
  }

  void _openPopup(LocationEvent e) {
    _popup.setLatLng(e.latlng);
    _map.openPopup(_popup);
  }

  /**
   * Returns the LatLngBounds of the path.
   */
  LatLngBounds getBounds();


  /*
   * SVG-specific rendering code.
   */

  static const SVG_NS = 'http://www.w3.org/2000/svg';

  Element _path;

  /**
   * Brings the layer to the top of all path layers.
   */
  bringToFront() {
    final root = _map.pathRoot,
        path = _container;

    if (path && root.lastChild != path) {
      root.append(path);
    }
  }

  /**
   * Brings the layer to the bottom of all path layers.
   */
  bringToBack() {
    final root = _map.pathRoot,
        path = _container,
        first = root.firstChild;

    if (path && first != path) {
      root.insertBefore(path, first);
    }
  }

  // Form path string here.
  getPathString();

  /*_createElement(String name) {
    return document.createElementNS(SVG_NS, name);
  }*/

  _initElements() {
    _map._initPathRoot();
    _initPath();
    _initStyle();
  }

  _initPath() {
    _container = _createElement('g');

    _path = _createElement('path');

    if (options.className != null) {
      _path.classes.add(options.className);
    }

    _container.append(_path);
  }

  _initStyle() {
    if (options.stroke) {
      _path.setAttribute('stroke-linejoin', 'round');
      _path.setAttribute('stroke-linecap', 'round');
    }
    if (options.fill) {
      _path.setAttribute('fill-rule', 'evenodd');
    }
    if (options.pointerEvents != null) {
      _path.setAttribute('pointer-events', options.pointerEvents);
    }
    if (!options.clickable && options.pointerEvents == null) {
      _path.setAttribute('pointer-events', 'none');
    }
    _updateStyle();
  }

  _updateStyle() {
    if (options.stroke) {
      _path.setAttribute('stroke', options.color);
      _path.setAttribute('stroke-opacity', options.opacity.toString());
      _path.setAttribute('stroke-width', options.weight.toString());
      if (options.dashArray != null) {
        _path.setAttribute('stroke-dasharray', options.dashArray);
      } else {
        _path.attributes.remove('stroke-dasharray');
      }
      if (options.lineCap != null) {
        _path.setAttribute('stroke-linecap', options.lineCap);
      }
      if (options.lineJoin != null) {
        _path.setAttribute('stroke-linejoin', options.lineJoin);
      }
    } else {
      _path.setAttribute('stroke', 'none');
    }
    if (options.fill) {
      _path.setAttribute('fill', options.fillColor != null ? options.fillColor : options.color);
      _path.setAttribute('fill-opacity', options.fillOpacity.toString());
    } else {
      _path.setAttribute('fill', 'none');
    }
  }

  _updatePath([Object obj, MapEvent e]) {
    var str = getPathString();
    if (!str) {
      // fix webkit empty string parsing bug
      str = 'M0 0';
    }
    _path.setAttribute('d', str);
  }

  // TODO remove duplication with Map
  _initEvents() {
    if (options.clickable) {
      if (Browser.svg || !Browser.vml) {
        _path.classes.add('leaflet-clickable');
      }

      //dom.on(_container, 'click', _onMouseClick, this);
      _container.onClick.listen(_onMouseClick);

      /*var events = ['dblclick', 'mousedown', 'mouseover',
                    'mouseout', 'mousemove', 'contextmenu'];
      for (var i = 0; i < events.length; i++) {
        dom.on(_container, events[i], _fireMouseEvent, this);
      }*/
      _container.onDoubleClick.listen(_fireDoubleClickEvent);
      _container.onMouseDown.listen(_fireMouseDownEvent);
      _container.onMouseOver.listen(_fireMouseOverEvent);
      _container.onMouseOut.listen(_fireMouseOutEvent);
      _container.onMouseMove.listen(_fireMouseMoveEvent);
      _container.onContextMenu.listen(_fireContextMenuEvent);
    }
  }

  _onMouseClick(html.MouseEvent e) {
    if (_map.dragging != null && _map.dragging.moved()) {
      return;
    }

    _fireClickEvent(e);
  }

  _fireClickEvent(html.MouseEvent e) {
    if (!_clickController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _clickController.add(new MouseEvent(EventType.CLICK, latlng, layerPoint, containerPoint, e));

    e.stopPropagation();
  }

  _fireDoubleClickEvent(html.MouseEvent e) {
    if (!_dblClickController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _dblClickController.add(new MouseEvent(EventType.DBLCLICK, latlng, layerPoint, containerPoint, e));

    e.stopPropagation();
  }

  _fireMouseDownEvent(html.MouseEvent e) {
    if (!_mouseDownController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _mouseDownController.add(new MouseEvent(EventType.MOUSEDOWN, latlng, layerPoint, containerPoint, e));

    e.stopPropagation();
  }

  _fireMouseOverEvent(html.MouseEvent e) {
    if (!_mouseOverController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _mouseOverController.add(new MouseEvent(EventType.MOUSEOVER, latlng, layerPoint, containerPoint, e));

    e.stopPropagation();
  }

  _fireMouseOutEvent(html.MouseEvent e) {
    if (!_mouseOutController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _mouseOutController.add(new MouseEvent(EventType.MOUSEOUT, latlng, layerPoint, containerPoint, e));

    e.stopPropagation();
  }

  _fireMouseMoveEvent(html.MouseEvent e) {
    if (!_moveController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _moveController.add(new MouseEvent(EventType.MOUSEMOVE, latlng, layerPoint, containerPoint, e));
  }

  _fireContextMenuEvent(html.MouseEvent e) {
    if (!_contextMenuController.hasListener) {
      return;
    }

    final containerPoint = _map.mouseEventToContainerPoint(e),
        layerPoint = _map.containerPointToLayerPoint(containerPoint),
        latlng = _map.layerPointToLatLng(layerPoint);

    _contextMenuController.add(new MouseEvent(EventType.CONTEXTMENU, latlng, layerPoint, containerPoint, e));

    e.preventDefault();
  }

  /*_fireMouseEvent(html.MouseEvent e) {
    if (!hasEventListeners(e.type)) { return; }

    final map = _map,
        containerPoint = map.mouseEventToContainerPoint(e),
        layerPoint = map.containerPointToLayerPoint(containerPoint),
        latlng = map.layerPointToLatLng(layerPoint);

    fire(e.type, {
      'latlng': latlng,
      'layerPoint': layerPoint,
      'containerPoint': containerPoint,
      'originalEvent': e
    });

    if (e.type == 'contextmenu') {
      dom.preventDefault(e);
    }
    if (e.type != 'mousemove') {
      dom.stopPropagation(e);
    }
  }*/

  StreamController<MouseEvent> _clickController = new StreamController.broadcast();
  StreamController<MouseEvent> _dblClickController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseDownController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOverController = new StreamController.broadcast();
  StreamController<MouseEvent> _mouseOutController = new StreamController.broadcast();
  StreamController<MouseEvent> _contextMenuController = new StreamController.broadcast();
  StreamController<MouseEvent> _moveController = new StreamController.broadcast();
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
  Stream<MouseEvent> get onMove => _moveController.stream;
  Stream<MapEvent> get onAddMarker => _addController.stream;
  Stream<MapEvent> get onRemoveMarker => _removeController.stream;
  Stream<PopupEvent> get onPopupOpen => _popupOpenController.stream;
  Stream<PopupEvent> get onPopupClose => _popupCloseController.stream;

  /**
   * For internal use.
   */
  //StreamController<PopupEvent> get popupOpenController;
  //StreamController<PopupEvent> get popupCloseController;
  void fire(PopupEvent event) {
    switch (event.type) {
      case EventType.POPUPOPEN:
        _popupOpenController.add(event);
        break;
      case EventType.POPUPCLOSE:
        _popupCloseController.add(event);
        break;
    }
  }
}
