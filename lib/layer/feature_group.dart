part of leaflet.layer;

/// FeatureGroup extends LayerGroup by introducing mouse events and
/// additional methods shared between a group of interactive layers
/// (like vectors or markers).
class FeatureGroup extends LayerGroup {

//  static final EVENTS = [EventType.CLICK, EventType.DBLCLICK,
//    EventType.MOUSEOVER, EventType.MOUSEOUT, EventType.MOUSEMOVE,
//    EventType.CONTEXTMENU, EventType.POPUPOPEN, EventType.POPUPCLOSE];

  var _popupContent, _popupOptions;

//  List<StreamSubscription<LayerEvent>> _subscriptions;
  StreamSubscription<MapEvent> _clickSubscription;
  StreamSubscription<MapEvent> _dblClickSubscription;
  StreamSubscription<MapEvent> _mouseOverSubscription;
  StreamSubscription<MapEvent> _mouseOutSubscription;
  StreamSubscription<MapEvent> _mouseMoveSubscription;
  StreamSubscription<MapEvent> _contextMenuSubscription;
  StreamSubscription<MapEvent> _popupOpenSubscription;
  StreamSubscription<MapEvent> _popupCloseSubscription;

  /// Create a layer group, optionally given an initial set of layers.
  FeatureGroup([List<Layer> layers = null]) : super(layers);

  void addLayer(Layer layer) {
    if (hasLayer(layer)) {
      return;
    }

    if (layer is Marker/*Events*/) {
      _clickSubscription = layer.onClick.listen((e) => _propagateEvent(layer, e));
      _dblClickSubscription = layer.onDblClick.listen((e) => _propagateEvent(layer, e));
      _mouseOverSubscription = layer.onMouseOver.listen((e) => _propagateEvent(layer, e));
      _mouseOutSubscription = layer.onMouseOut.listen((e) => _propagateEvent(layer, e));
      //_mouseMoveSubscription = layer.onMouseMove.listen((e) => _propagateEvent(layer, e));
      _contextMenuSubscription = layer.onContextMenu.listen((e) => _propagateEvent(layer, e));
      _popupOpenSubscription = layer.onPopupOpen.listen((e) => _propagateEvent(layer, e));
      _popupCloseSubscription = layer.onPopupClose.listen((e) => _propagateEvent(layer, e));
    } else if (layer is Path/*Events*/) {
      _clickSubscription = layer.onClick.listen((e) => _propagateEvent(layer, e));
      _dblClickSubscription = layer.onDblClick.listen((e) => _propagateEvent(layer, e));
      _mouseOverSubscription = layer.onMouseOver.listen((e) => _propagateEvent(layer, e));
      _mouseOutSubscription = layer.onMouseOut.listen((e) => _propagateEvent(layer, e));
      //_mouseMoveSubscription = layer.onMouseMove.listen((e) => _propagateEvent(layer, e));
      _contextMenuSubscription = layer.onContextMenu.listen((e) => _propagateEvent(layer, e));
      _popupOpenSubscription = layer.onPopupOpen.listen((e) => _propagateEvent(layer, e));
      _popupCloseSubscription = layer.onPopupClose.listen((e) => _propagateEvent(layer, e));
    } else if (layer is ImageOverlay) {
    } else if (layer is TileLayer) {
    }

    super.addLayer(layer);

    if (_popupContent != null) {// && layer.bindPopup != null) {
      if (layer is Marker) {
        layer.bindPopup(_popupContent, _popupOptions);
      } else if (layer is Path) {
        layer.bindPopup(_popupContent, _popupOptions);
      }
    }

    //fireEvent(new LayerEvent(EventType.LAYERADD, layer));
    _layerAddController.add(new LayerEvent(EventType.LAYERADD, layer));
  }

  void removeLayer(Layer layer) {
    if (!hasLayer(layer)) {
      return;
    }
    if (_layers.containsKey(layer)) {
      layer = _layers[layer];
    }

//    layer.off(FeatureGroup.EVENTS, _propagateEvent);
    if (_clickSubscription != null) _clickSubscription.cancel();
    if (_dblClickSubscription != null) _dblClickSubscription.cancel();
    if (_mouseOverSubscription != null) _mouseOverSubscription.cancel();
    if (_mouseOutSubscription != null) _mouseOutSubscription.cancel();
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_contextMenuSubscription != null) _contextMenuSubscription.cancel();
    if (_popupOpenSubscription != null) _popupOpenSubscription.cancel();
    if (_popupCloseSubscription != null) _popupCloseSubscription.cancel();

    super.removeLayer(layer);

    if (_popupContent != null) {
      //      invoke('unbindPopup');
      eachLayer((layer) {
        layer.unbindPopup();
      });
    }

    //fireEvent(new LayerEvent(EventType.LAYERREMOVE, layer));
    _layerRemoveController.add(new LayerEvent(EventType.LAYERREMOVE, layer));
  }

  /// Binds a popup with a particular HTML content to a click on any layer
  /// from the group that has a bindPopup method.
  bindPopup(String content, [PopupOptions options=null]) {
    if (options == null) {
      options = new PopupOptions();
    }
    _popupContent = content;
    _popupOptions = options;
    //return invoke('bindPopup', content, options);
    eachLayer((layer) {
      layer.bindPopup(content, options);
      //content.bindPopup(layer, options);
    });
  }

  openPopup(LatLng latlng) {
    // Open popup on the first layer.
    for (String id in _layers) {
      final layer = _layers[id];
      if (layer is Marker) {
        layer.openPopup();//latlng);
      } else if (layer is Path) {
        layer.openPopup(latlng);
      }
      break;
    }
    return this;
  }

  /// Sets the given path options to each layer of the group that has a
  /// setStyle method.
  setStyle(PathOptions style) {
    //return invoke('setStyle', style);
    eachLayer((layer) {
      layer.setStyle(style);
    });
  }

  /// Brings the layer group to the top of all other layers.
  bringToFront() {
    //return invoke('bringToFront');
    eachLayer((layer) {
      layer.bringToFront();
    });
  }

  /// Brings the layer group to the bottom of all other layers.
  bringToBack() {
    //return invoke('bringToBack');
    eachLayer((layer) {
      layer.bringToBack();
    });
  }

  /// Returns the LatLngBounds of the Feature Group (created from bounds and
  /// coordinates of its children).
  getBounds() {
    var bounds = new LatLngBounds.between();

    eachLayer((layer) {
      bounds.extend(layer is Marker ? layer.getLatLng() : layer.getBounds());
    });

    return bounds;
  }

  _propagateEvent(Layer target, MapEvent e) {
    final ee = new LayerEvent(e.type, target);
    //ee.layer = e.target;
    //ee.target = this;
    //fire(ee.type, ee);
    fireEvent(ee);
  }

  void fireEvent(MapEvent event) {
    switch (event.type) {
    case EventType.CLICK:
      _clickController.add(event);
      break;
    case EventType.DBLCLICK:
      _dblClickController.add(event);
      break;
    case EventType.MOUSEMOVE:
      _mouseMoveController.add(event);
      break;
    case EventType.MOUSEOVER:
      _mouseOverController.add(event);
      break;
    case EventType.MOUSEOUT:
      _mouseOutController.add(event);
      break;
    case EventType.CONTEXTMENU:
      _contextMenuController.add(event);
      break;
    case EventType.LAYERADD:
      _layerAddController.add(event);
      break;
    case EventType.LAYERREMOVE:
      _layerRemoveController.add(event);
      break;
    }
  }

  StreamController<LayerEvent/*MouseEvent*/> _clickController = new StreamController.broadcast();
  StreamController<LayerEvent/*MouseEvent*/> _dblClickController = new StreamController.broadcast();
  StreamController<LayerEvent/*MouseEvent*/> _mouseMoveController = new StreamController.broadcast();
  StreamController<LayerEvent/*MouseEvent*/> _mouseOverController = new StreamController.broadcast();
  StreamController<LayerEvent/*MouseEvent*/> _mouseOutController = new StreamController.broadcast();
  StreamController<LayerEvent/*MouseEvent*/> _contextMenuController = new StreamController.broadcast();
  StreamController<LayerEvent> _layerAddController = new StreamController.broadcast();
  StreamController<LayerEvent> _layerRemoveController = new StreamController.broadcast();

  Stream<LayerEvent/*MouseEvent*/> get onClick => _clickController.stream;
  Stream<LayerEvent/*MouseEvent*/> get onDblClick => _dblClickController.stream;
  Stream<LayerEvent/*MouseEvent*/> get onMouseMove => _mouseMoveController.stream;
  Stream<LayerEvent/*MouseEvent*/> get onMouseOver => _mouseOverController.stream;
  Stream<LayerEvent/*MouseEvent*/> get onMouseOut => _mouseOutController.stream;
  Stream<LayerEvent/*MouseEvent*/> get onContextMenu => _contextMenuController.stream;
  Stream<LayerEvent> get onLayerAdd => _layerAddController.stream;
  Stream<LayerEvent> get onLayerRemove => _layerRemoveController.stream;
}
