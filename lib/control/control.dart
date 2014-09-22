library leaflet.control;

import 'dart:collection' show LinkedHashMap;
import 'dart:html' show Element, document, InputElement, Event;
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:async' show Timer, StreamSubscription;

import 'package:leaflet/src/core/browser.dart' as browser;

import '../core/core.dart' show MapEvent, EventType, LayerEvent, Util, Browser, stamp, LayersControlEvent;
import '../map/map.dart';
import '../dom/dom.dart' as dom;
import '../layer/layer.dart' show Layer;

part 'attribution.dart';
part 'layers.dart';
part 'scale.dart';
part 'zoom.dart';

class ControlPosition {
  final _value;
  const ControlPosition._internal(this._value);
  toString() => '$_value';

  /**
   * Top left of the map.
   */
  static const TOPLEFT = const ControlPosition._internal('topleft');

  /**
   * Top right of the map.
   */
  static const TOPRIGHT = const ControlPosition._internal('topright');

  /**
   * Bottom left of the map.
   */
  static const BOTTOMLEFT = const ControlPosition._internal('bottomleft');

  /**
   * Bottom right of the map.
   */
  static const BOTTOMRIGHT = const ControlPosition._internal('bottomright');

  static Map<String, ControlPosition> _names = {
    TOPLEFT.toString(): TOPLEFT,
    TOPRIGHT.toString: TOPRIGHT,
    BOTTOMLEFT.toString(): BOTTOMLEFT,
    BOTTOMRIGHT.toString(): BOTTOMRIGHT
  };

  factory ControlPosition.fromString(String s) {
    return _names[s];
  }
}

class ControlOptions {
  /**
   * The initial position of the control (one of the map corners).
   */
  ControlPosition position = ControlPosition.TOPRIGHT;
}

/**
 * Represents a UI element in one of the corners of the map.
 *
 * Control is a base class for implementing map controls. Handles positioning.
 * All other controls extend from this class.
 */
abstract class Control {

  ControlOptions options;

  LeafletMap _map;
  Element _container;

  Control(this.options);

  /**
   * Returns the current position of the control.
   */
  ControlPosition getPosition() {
    return options.position;
  }

  /**
   * Sets the position of the control.
   */
  void setPosition(ControlPosition position) {
    final map = _map;

    if (map) {
      map.removeControl(this);
    }

    options.position = position;

    if (map) {
      map.addControl(this);
    }
  }

  /**
   * Returns the HTML container of the control.
   */
  Element getContainer() {
    return _container;
  }

  /**
   * Adds the control to the map.
   */
  void addTo(LeafletMap map) {
    _map = map;

    final container = _container = onAdd(map);
    final pos = getPosition(),
        corner = map.controlCorners[pos];

    container.classes.add('leaflet-control');

    if (pos.toString().indexOf('bottom') != -1) {
      corner.insertBefore(container, corner.firstChild);
    } else {
      corner.append(container);
    }
  }

  /**
   * Removes the control from the map.
   */
  void removeFrom(LeafletMap map) {
    final pos = getPosition(),
        corner = map.controlCorners[pos];

//    corner.removeChild(_container);
    _container.remove();
    _map = null;

    //if (onRemove != null) {
    onRemove(map);
    //}
  }

  void _refocusOnMap([html.MouseEvent e]) {
    if (_map != null) {
      _map.getContainer().focus();
    }
  }

  /**
   * Should contain code that creates all the neccessary DOM elements for the
   * control, adds listeners on relevant map events, and returns the element
   * containing the control. Called on map.addControl(control) or
   * control.addTo(map).
   */
  Element onAdd(LeafletMap map);

  /**
   * Optional, should contain all clean up code (e.g. removes control's event
   * listeners). Called on map.removeControl(control) or
   * control.removeFrom(map). The control's DOM container is removed
   * automatically.
   */
  onRemove(LeafletMap map);
}
