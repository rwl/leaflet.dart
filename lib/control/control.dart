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

  // Top left of the map.
  static const TOPLEFT = const ControlPosition._internal('topleft');
  // Top right of the map.
  static const TOPRIGHT = const ControlPosition._internal('topright');
  // Bottom left of the map.
  static const BOTTOMLEFT = const ControlPosition._internal('bottomleft');
  // Bottom right of the map.
  static const BOTTOMRIGHT = const ControlPosition._internal('bottomright');
}

class ControlOptions {
  // The initial position of the control (one of the map corners).
  ControlPosition position = ControlPosition.TOPRIGHT;
}

// Represents a UI element in one of the corners of the map.
//
// Control is a base class for implementing map controls. Handles positioning.
// All other controls extend from this class.
abstract class Control {
  final Map<String, Object> options = {
    'position': 'topright'
  };

  BaseMap _map;
  var _container;

  Control(Map<String, Object> options) {
    this.options.addAll(options);
  }

  String getPosition() {
    return this.options['position'];
  }

  setPosition(position) {
    var map = this._map;

    if (map) {
      map.removeControl(this);
    }

    this.options['position'] = position;

    if (map) {
      map.addControl(this);
    }

    return this;
  }

  getContainer() {
    return this._container;
  }

  addTo(BaseMap map) {
    this._map = map;

    final container = this._container = this.onAdd(map);
    final pos = this.getPosition(),
        corner = map._controlCorners[pos];

    DomUtil.addClass(container, 'leaflet-control');

    if (pos.indexOf('bottom') != -1) {
      corner.insertBefore(container, corner.firstChild);
    } else {
      corner.append(container);
    }

    return this;
  }

  removeFrom(BaseMap map) {
    var pos = this.getPosition(),
        corner = map._controlCorners[pos];

    corner.removeChild(this._container);
    this._map = null;

    if (this.onRemove != null) {
      this.onRemove(map);
    }

    return this;
  }

  _refocusOnMap() {
    if (this._map != null) {
      this._map.getContainer().focus();
    }
  }

  // Should contain code that creates all the neccessary DOM elements for the
  // control, adds listeners on relevant map events, and returns the element
  // containing the control. Called on map.addControl(control) or
  // control.addTo(map).
  Element onAdd(BaseMap map);

  // Optional, should contain all clean up code (e.g. removes control's event
  // listeners). Called on map.removeControl(control) or
  // control.removeFrom(map). The control's DOM container is removed
  // automatically.
  onRemove(BaseMap map);
}

class ControlMap {
  addControl(control) {
    control.addTo(this);
    return this;
  }

  removeControl(control) {
    control.removeFrom(this);
    return this;
  }

  _initControlPos() {
    final corners = this._controlCorners = {};
    String l = 'leaflet-';
    final container = this._controlContainer =
                DomUtil.create('div', l + 'control-container', this._container);

    createCorner(String vSide, String hSide) {
      var className = l + vSide + ' ' + l + hSide;

      corners[vSide + hSide] = DomUtil.create('div', className, container);
    }

    createCorner('top', 'left');
    createCorner('top', 'right');
    createCorner('bottom', 'left');
    createCorner('bottom', 'right');
  }

  _clearControlPos() {
    this._container.removeChild(this._controlContainer);
  }
}