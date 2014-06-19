library leaflet.map.handler;

import 'dart:html' as html;
import 'dart:html' show Element, document;
import 'dart:math' as math;

import '../../core/core.dart' show Handler, EventType, MouseEvent, DateTime, Event;
import '../map.dart' show BaseMap;
import '../../dom/dom.dart' as dom;
import '../../geometry/geometry.dart' as geom;
import '../../geo/geo.dart' show LatLng, LatLngBounds;

part 'box_zoom.dart';
part 'double_click_zoom.dart';
part 'drag.dart';
part 'keyboard.dart';
part 'scroll_wheel_zoom.dart';
part 'tap.dart';
part 'touch_zoom.dart';