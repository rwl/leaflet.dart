library leaflet.control;

import 'dart:html';
import 'dart:math' as math;

import '../core/core.dart';
import '../map/map.dart';
import '../geo/geo.dart';
import '../dom/dom.dart';

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

  BaseMap _map;
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
  setPosition(ControlPosition position) {
    final map = _map;

    if (map) {
      map.removeControl(this);
    }

    options.position = position;

    if (map) {
      map.addControl(this);
    }

    return this;
  }

  /**
   * Returns the HTML container of the control.
   */
  getContainer() {
    return _container;
  }

  /**
   * Adds the control to the map.
   */
  addTo(BaseMap map) {
    _map = map;

    final container = _container = onAdd(map);
    final pos = getPosition(),
        corner = map.controlCorners[pos];

    DomUtil.addClass(container, 'leaflet-control');

    if (pos.toString().indexOf('bottom') != -1) {
      corner.insertBefore(container, corner.firstChild);
    } else {
      corner.append(container);
    }

    return this;
  }

  /**
   * Removes the control from the map.
   */
  removeFrom(BaseMap map) {
    final pos = getPosition(),
        corner = map.controlCorners[pos];

    corner.removeChild(_container);
    _map = null;

    //if (onRemove != null) {
    onRemove(map);
    //}

    return this;
  }

  _refocusOnMap() {
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
  Element onAdd(BaseMap map);

  /**
   * Optional, should contain all clean up code (e.g. removes control's event
   * listeners). Called on map.removeControl(control) or
   * control.removeFrom(map). The control's DOM container is removed
   * automatically.
   */
  onRemove(BaseMap map);
}
