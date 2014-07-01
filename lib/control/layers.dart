part of leaflet.control;

final _layerId = new Expando<int>();

class LayersOptions extends ControlOptions {
  /**
   * The position of the control (one of the map corners). See control
   * positions.
   */
  ControlPosition position  = ControlPosition.TOPRIGHT;

  /**
   * If true, the control will be collapsed into an icon and expanded on
   * mouse hover or touch.
   */
  bool collapsed = true;

  /**
   * If true, the control will assign zIndexes in increasing order to all of
   * its layers so that the order is preserved when switching them on/off.
   */
  bool autoZIndex  = true;
}

/**
 * Layers is a control to allow users to switch between different layers on
 * the map.
 */
class Layers extends Control {

  LayersOptions get layersOptions => options as LayersOptions;

  Map<int, LayersControlEvent> _layers;
  int _lastZIndex;
  bool _handlingClick;
  Element _form;
  Element _layersLink;
  Element _baseLayersList, _overlaysList, _separator;

  /**
   * For internal use.
   */
  Element get baseLayersList => _baseLayersList;
  Element get overlaysList => _overlaysList;

  /**
   * Creates an attribution control with the given layers. Base layers will be
   * switched with radio buttons, while overlays will be switched with
   * checkboxes. Note that all base layers should be passed in the base layers
   * object, but only one should be added to the map during map instantiation.
   */
  Layers(LinkedHashMap<String, Layer> baseLayers, [LinkedHashMap<String, Layer> overlays=null, LayersOptions options=null]) : super(options) {
    if (options == null) {
      options = new LayersOptions();
    }
    _layers = new Map<int, Object>();
    _lastZIndex = 0;
    _handlingClick = false;

    for (String i in baseLayers) {
      _addLayer(baseLayers[i], i);
    }

    if (overlays != null) {
      for (String name in overlays) {
        _addLayer(overlays[name], name, true);
      }
    }
  }

  Element onAdd(LeafletMap map) {
    _initLayout();
    update();

    map.on(EventType.LAYERADD, _onLayerChange);
    map.on(EventType.LAYERREMOVE, _onLayerChange);

    return _container;
  }

  void onRemove(LeafletMap map) {
    map.off(EventType.LAYERADD, _onLayerChange);
    map.off(EventType.LAYERREMOVE, _onLayerChange);
  }

  /**
   * Adds a base layer (radio button entry) with the given name to the control.
   */
  void addBaseLayer(Layer layer, String name) {
    _addLayer(layer, name);
    update();
  }

  /**
   * Adds an overlay (checkbox entry) with the given name to the control.
   */
  void addOverlay(layer, String name) {
    _addLayer(layer, name, true);
    update();
  }

  /**
   * Remove the given layer from the control.
   */
  void removeLayer(layer) {
    final id = stamp(layer);
    _layers.remove(id);
    update();
  }

  _initLayout() {
    final className = 'leaflet-control-layers',
        container = _container = dom.create('div', className);

    //Makes this work on IE10 Touch devices by stopping it from firing a mouseout event when the touch is released
    container.setAttribute('aria-haspopup', 'true');

    if (!browser.touch) {
      dom.disableClickPropagation(container);
      dom.disableScrollPropagation(container);
    } else {
      //dom.on(container, 'click', dom.stopPropagation);
      container.onClick.listen((html.MouseEvent e) {
        e.stopPropagation();
      });
    }

    final form = _form = dom.create('form', className + '-list');

    if (layersOptions.collapsed) {
      final link = _layersLink = dom.create('a', '$className-toggle', container);
      link.href = '#';
      link.title = 'Layers';

      if (browser.touch) {
        //dom.on(link, 'click', dom.stop);
        link.onClick.listen(dom.stop);
        //dom.on(link, 'click', _expand, this);
        link.onClick.listen(_expand);
      }
      else {
        //dom.on(link, 'focus', _expand, this);
        link.onFocus.listen(_expand);
      }
      //Work around for Firefox android issue https://github.com/Leaflet/Leaflet/issues/2033
      //dom.on(form, 'click', () {
      form.onClick.listen((html.MouseEvent e) {
        //setTimeout(bind(_onInputClick, this), 0);
        new Timer(const Duration(milliseconds: 0), () {
          _onInputClick();
        });
      });

      _map.on(EventType.CLICK, _collapse);
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

    _layers[id] = new LayersControlEvent(null, layer, name, overlay);

    if (layersOptions.autoZIndex) {
      _lastZIndex++;
      layer.setZIndex(_lastZIndex);
    }
  }

  /**
   * For internal use.
   */
  void update() {
    if (_container == null) {
      return;
    }

    _baseLayersList.setInnerHtml('');
    _overlaysList.setInnerHtml('');

    bool baseLayersPresent = false,
        overlaysPresent = false;

    _layers.forEach((int id, LayersControlEvent obj) {
      _addItem(obj);
      overlaysPresent = overlaysPresent || obj.overlay != null;
      baseLayersPresent = baseLayersPresent || !obj.overlay != null;
    });

    _separator.style.display = overlaysPresent && baseLayersPresent ? '' : 'none';
  }

  void _onLayerChange(LayerEvent e) {
    final obj = _layers[stamp(e.layer)];

    if (obj == null) { return; }

    if (!_handlingClick) {
      update();
    }

    EventType type = obj.overlay != null ?
      (e.type == EventType.LAYERADD ? EventType.OVERLAYADD : EventType.OVERLAYREMOVE) :
      (e.type == EventType.LAYERADD ? EventType.BASELAYERCHANGE : null);

    if (type != null) {
      obj.type = type;
      _map.fireEvent(obj);
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

  Element _addItem(LayersControlEvent obj) {
    final label = document.createElement('label');
    InputElement input;
    final checked = _map.hasLayer(obj.layer);

    if (obj.overlay != null) {
      input = document.createElement('input');
      input.type = 'checkbox';
      input.className = 'leaflet-control-layers-selector';
      input.defaultChecked = checked;
    } else {
      input = _createRadioElement('leaflet-base-layers', checked);
    }

    _layerId[input] = stamp(obj.layer);

    //dom.on(input, 'click', _onInputClick, this);
    input.onClick.listen(_onInputClick);

    final name = document.createElement('span');
    name.setInnerHtml(' ' + obj.name);

    label.append(input);
    label.append(name);

    final container = obj.overlay ? _overlaysList : _baseLayersList;
    container.append(label);

    return label;
  }

  void _onInputClick([html.MouseEvent e]) {
    final inputs = _form.querySelectorAll('input');

    _handlingClick = true;

    for (int i = 0; i < inputs.length; i++) {
      InputElement input = inputs[i];
      final obj = _layers[_layerId[input]];

      if (input.checked && !_map.hasLayer(obj.layer)) {
        _map.addLayer(obj.layer);

      } else if (!input.checked && _map.hasLayer(obj.layer)) {
        _map.removeLayer(obj.layer);
      }
    }

    _handlingClick = false;

    _refocusOnMap();
  }

  _expand([html.MouseEvent e]) {
    _container.classes.add('leaflet-control-layers-expanded');
  }

  _collapse([html.MouseEvent e]) {
    _container.className = _container.className.replaceAll(' leaflet-control-layers-expanded', '');
  }
}