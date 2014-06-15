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
  var _baseLayersList, _overlaysList;
  var _separator;

  /**
   * Creates an attribution control with the given layers. Base layers will be switched with radio buttons, while overlays will be switched with checkboxes. Note that all base layers should be passed in the base layers object, but only one should be added to the map during map instantiation.
   */
  Layers(LinkedHashMap<String, Layer> baseLayers, LinkedHashMap<String, Layer> overlays, LayersOptions options) : super(options) {
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

  onAdd(BaseMap map) {
    _initLayout();
    _update();

    map.on(EventType.LAYERADD, _onLayerChange, this);
    map.on(EventType.LAYERREMOVE, _onLayerChange, this);

    return _container;
  }

  onRemove(BaseMap map) {
    map.off(EventType.LAYERADD, _onLayerChange);
    map.off(EventType.LAYERREMOVE, _onLayerChange);
  }

  /**
   * Adds a base layer (radio button entry) with the given name to the control.
   */
  addBaseLayer(Layer layer, String name) {
    _addLayer(layer, name);
    _update();
    return this;
  }

  /**
   * Adds an overlay (checkbox entry) with the given name to the control.
   */
  addOverlay(layer, String name) {
    _addLayer(layer, name, true);
    _update();
    return this;
  }

  /**
   * Remove the given layer from the control.
   */
  removeLayer(layer) {
    var id = Util.stamp(layer);
    _layers.remove(id);
    _update();
    return this;
  }

  _initLayout() {
    final className = 'leaflet-control-layers',
        container = _container = DomUtil.create('div', className);

    //Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
    container.setAttribute('aria-haspopup', true);

    if (!Browser.touch) {
      DomEvent
        .disableClickPropagation(container)
        .disableScrollPropagation(container);
    } else {
      DomEvent.on(container, 'click', DomEvent.stopPropagation);
    }

    final form = _form = DomUtil.create('form', className + '-list');

    if (layersOptions.collapsed) {
      if (!Browser.android) {
        DomEvent.on(container, 'mouseover', _expand, this);
        DomEvent.on(container, 'mouseout', _collapse, this);
      }
      final link = _layersLink = DomUtil.create('a', '$className-toggle', container);
      link.href = '#';
      link.title = 'Layers';

      if (Browser.touch) {
        DomEvent.on(link, 'click', DomEvent.stop);
        DomEvent.on(link, 'click', _expand, this);
      }
      else {
        DomEvent.on(link, 'focus', _expand, this);
      }
      //Work around for Firefox android issue https://github.com/Leaflet/Leaflet/issues/2033
      DomEvent.on(form, 'click', () {
        setTimeout(bind(_onInputClick, this), 0);
      }, this);

      _map.on(EventType.CLICK, _collapse, this);
      // TODO keyboard accessibility
    } else {
      _expand();
    }

    _baseLayersList = DomUtil.create('div', className + '-base', form);
    _separator = DomUtil.create('div', className + '-separator', form);
    _overlaysList = DomUtil.create('div', className + '-overlays', form);

    container.appendChild(form);
  }

  _addLayer(Layer layer, String name, [bool overlay=false]) {
    var id = Util.stamp(layer);

    _layers[id] = {
      layer: layer,
      name: name,
      overlay: overlay
    };

    if (layersOptions.autoZIndex) {
      _lastZIndex++;
      layer.setZIndex(_lastZIndex);
    }
  }

  _update() {
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

  _onLayerChange(Object obj, LayerEvent e) {
    final obj = _layers[Util.stamp(e.layer)];

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
  _createRadioElement(String name, bool checked) {

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

    input.layerId = Util.stamp(obj.layer);

    DomEvent.on(input, 'click', _onInputClick, this);

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
    DomUtil.addClass(_container, 'leaflet-control-layers-expanded');
  }

  _collapse() {
    _container.className = _container.className.replace(' leaflet-control-layers-expanded', '');
  }
}