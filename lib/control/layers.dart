part of leaflet.control;

class LayersOptions extends ControlOptions {
  /**
   * The position of the control (one of the map corners). See control positions.
   */
  ControlPosition position  = ControlPosition.TOPRIGHT;

  /**
   * If true, the control will be collapsed into an icon and expanded on mouse hover or touch.
   */
  bool collapsed = true;

  /**
   * If true, the control will assign zIndexes in increasing order to all of its layers so that the order is preserved when switching them on/off.
   */
  bool autoZIndex  = true;
}

/**
 * Layers is a control to allow users to switch between different layers on the map.
 */
class Layers extends Control {

  LayersOptions get layersOptions => options as LayersOptions;

  Map _layers;
  int _lastZIndex;
  bool _handlingClick;
  var _form;
  var _layersLink;
  Element _baseLayersList, _overlaysList, _separator;

  /**
   * For internal use.
   */
  Element get baseLayersList => _baseLayersList;
  Element get overlaysList => _overlaysList;

  /**
   * Creates an attribution control with the given layers. Base layers will be switched with radio buttons, while overlays will be switched with checkboxes. Note that all base layers should be passed in the base layers object, but only one should be added to the map during map instantiation.
   */
  Layers(LinkedHashMap<String, Layer> baseLayers, LinkedHashMap<String, Layer> overlays, [LayersOptions options=null]) : super(options) {
    if (options == null) {
      options = new LayersOptions();
    }
    _layers = {};
    _lastZIndex = 0;
    _handlingClick = false;

    for (String i in baseLayers) {
      _addLayer(baseLayers[i], i);
    }

    for (String name in overlays) {
      _addLayer(overlays[name], name, true);
    }
  }

  Element onAdd(BaseMap map) {
    _initLayout();
    _update();

    map.on(EventType.LAYERADD, _onLayerChange, this);
    map.on(EventType.LAYERREMOVE, _onLayerChange, this);

    return _container;
  }

  void onRemove(BaseMap map) {
    map.off(EventType.LAYERADD, _onLayerChange);
    map.off(EventType.LAYERREMOVE, _onLayerChange);
  }

  /**
   * Adds a base layer (radio button entry) with the given name to the control.
   */
  void addBaseLayer(Layer layer, String name) {
    _addLayer(layer, name);
    _update();
  }

  /**
   * Adds an overlay (checkbox entry) with the given name to the control.
   */
  void addOverlay(layer, String name) {
    _addLayer(layer, name, true);
    _update();
  }

  /**
   * Remove the given layer from the control.
   */
  void removeLayer(layer) {
    final id = stamp(layer);
    _layers.remove(id);
    _update();
  }

  _initLayout() {
    final className = 'leaflet-control-layers',
        container = _container = dom.create('div', className);

    //Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
    container.setAttribute('aria-haspopup', 'true');

    if (!Browser.touch) {
      dom.disableClickPropagation(container);
      dom.disableScrollPropagation(container);
    } else {
      dom.on(container, 'click', dom.stopPropagation);
    }

    final form = _form = dom.create('form', className + '-list');

    if (layersOptions.collapsed) {
      if (!Browser.android) {
        dom.on(container, 'mouseover', _expand, this);
        dom.on(container, 'mouseout', _collapse, this);
      }
      final link = _layersLink = dom.create('a', '$className-toggle', container);
      link.href = '#';
      link.title = 'Layers';

      if (Browser.touch) {
        dom.on(link, 'click', dom.stop);
        dom.on(link, 'click', _expand, this);
      }
      else {
        dom.on(link, 'focus', _expand, this);
      }
      //Work around for Firefox android issue https://github.com/Leaflet/Leaflet/issues/2033
      dom.on(form, 'click', () {
        //setTimeout(bind(_onInputClick, this), 0);
        new Timer(const Duration(milliseconds: 0), () {
          _onInputClick();
        });
      }, this);

      _map.on(EventType.CLICK, _collapse, this);
      // TODO keyboard accessibility
    } else {
      _expand();
    }

    _baseLayersList = dom.create('div', className + '-base', form);
    _separator = dom.create('div', className + '-separator', form);
    _overlaysList = dom.create('div', className + '-overlays', form);

    container.append(form);
  }

  void _addLayer(Layer layer, String name, [bool overlay=false]) {
    final id = stamp(layer);

    _layers[id] = {
      'layer': layer,
      'name': name,
      'overlay': overlay
    };

    if (layersOptions.autoZIndex) {
      _lastZIndex++;
      layer.setZIndex(_lastZIndex);
    }
  }

  void _update() {
    if (_container == null) {
      return;
    }

    _baseLayersList.innerHTML = '';
    _overlaysList.innerHTML = '';

    bool baseLayersPresent = false,
        overlaysPresent = false;

    for (var i in _layers) {
      final obj = _layers[i];
      _addItem(obj);
      overlaysPresent = overlaysPresent || obj.overlay != null;
      baseLayersPresent = baseLayersPresent || !obj.overlay != null;
    }

    _separator.style.display = overlaysPresent && baseLayersPresent ? '' : 'none';
  }

  void _onLayerChange(Object obj, LayerEvent e) {
    final obj = _layers[stamp(e.layer)];

    if (!obj) { return; }

    if (!_handlingClick) {
      _update();
    }

    final type = obj.overlay != null ?
      (e.type == 'layeradd' ? 'overlayadd' : 'overlayremove') :
      (e.type == 'layeradd' ? 'baselayerchange' : null);

    if (type) {
      _map.fire(type, obj);
    }
  }

  // IE7 bugs out if you create a radio dynamically, so you have to do it this hacky way (see http://bit.ly/PqYLBe)
  Element _createRadioElement(String name, bool checked) {

    var radioHtml = '<input type="radio" class="leaflet-control-layers-selector" name="' + name + '"';
    if (checked) {
      radioHtml += ' checked="checked"';
    }
    radioHtml += '/>';

    final radioFragment = document.createElement('div');
    radioFragment.setInnerHtml(radioHtml);

    return radioFragment.firstChild;
  }

  _addItem(obj) {
    final label = document.createElement('label');
    var input;
    final checked = _map.hasLayer(obj.layer);

    if (obj.overlay != null) {
      input = document.createElement('input');
      input.type = 'checkbox';
      input.className = 'leaflet-control-layers-selector';
      input.defaultChecked = checked;
    } else {
      input = _createRadioElement('leaflet-base-layers', checked);
    }

    input.layerId = stamp(obj.layer);

    dom.on(input, 'click', _onInputClick, this);

    final name = document.createElement('span');
    name.setInnerHtml(' ' + obj.name);

    label.append(input);
    label.append(name);

    final container = obj.overlay ? _overlaysList : _baseLayersList;
    container.append(label);

    return label;
  }

  _onInputClick() {
//    var i, input, obj;
    final inputs = _form.getElementsByTagName('input');

    _handlingClick = true;

    for (int i = 0; i < inputs.length; i++) {
      final input = inputs[i];
      final obj = _layers[input.layerId];

      if (input.checked && !_map.hasLayer(obj.layer)) {
        _map.addLayer(obj.layer);

      } else if (!input.checked && _map.hasLayer(obj.layer)) {
        _map.removeLayer(obj.layer);
      }
    }

    _handlingClick = false;

    _refocusOnMap();
  }

  _expand() {
    dom.addClass(_container, 'leaflet-control-layers-expanded');
  }

  _collapse(Object obj, Event e) {
    _container.className = _container.className.replaceAll(' leaflet-control-layers-expanded', '');
  }
}