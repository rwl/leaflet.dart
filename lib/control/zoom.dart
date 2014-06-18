part of leaflet.control;

class ZoomOptions extends ControlOptions {
  /**
   * The position of the control (one of the map corners). See control positions.
   */
  ControlPosition position  = ControlPosition.TOPLEFT;

  /**
   * The text set on the zoom in button.
   */
  String  zoomInText = '+';

  /**
   * The text set on the zoom out button.
   */
  String  zoomOutText = '-';

  /**
   * The title set on the zoom in button.
   */
  String  zoomInTitle = 'Zoom in';

  /**
   * The title set on the zoom out button.
   */
  String  zoomOutTitle = 'Zoom out';
}

/**
 * Zoom is used for the default zoom buttons on the map.
 */
class Zoom extends Control {

  ZoomOptions get zoomOptions => options as ZoomOptions;

  Zoom(ZoomOptions options) : super(options);

  Element _zoomInButton, _zoomOutButton;

  onAdd(BaseMap map) {
    final zoomName = 'leaflet-control-zoom',
        container = dom.create('div', '$zoomName leaflet-bar');

    _map = map;

    _zoomInButton = _createButton(
            zoomOptions.zoomInText, zoomOptions.zoomInTitle,
            '$zoomName-in', container, _zoomIn, this);
    _zoomOutButton = _createButton(
            zoomOptions.zoomOutText, zoomOptions.zoomOutTitle,
            '$zoomName-out', container, _zoomOut, this);

    _updateDisabled(null, null);
    map.on(EventType.ZOOMEND, _updateDisabled, this);
    map.on(EventType.ZOOMLEVELSCHANGE, _updateDisabled, this);

    return container;
  }

  onRemove(BaseMap map) {
    map.off(EventType.ZOOMEND, _updateDisabled, this);
    map.off(EventType.ZOOMLEVELSCHANGE, _updateDisabled, this);
  }

  _zoomIn(e) {
    _map.zoomIn(e.shiftKey ? 3 : 1);
  }

  _zoomOut(e) {
    _map.zoomOut(e.shiftKey ? 3 : 1);
  }

  _createButton(String html, String title, String className, Element container, Function fn, var context) {
    final link = dom.create('a', className, container);
    link.innerHtml = html;
    link.href = '#';
    link.title = title;

    final stop = dom.stopPropagation;

    dom.on(link, 'click', stop);
    dom.on(link, 'mousedown', stop);
    dom.on(link, 'dblclick', stop);
    dom.on(link, 'click', dom.preventDefault);
    dom.on(link, 'click', fn, context);
    dom.on(link, 'click', _refocusOnMap, context);

    return link;
  }

  _updateDisabled(Object obj, Event e) {
    final map = _map,
      className = 'leaflet-disabled';

    dom.removeClass(_zoomInButton, className);
    dom.removeClass(_zoomOutButton, className);

    if (map._zoom == map.getMinZoom()) {
      dom.addClass(_zoomOutButton, className);
    }
    if (map._zoom == map.getMaxZoom()) {
      dom.addClass(_zoomInButton, className);
    }
  }
}