library leaflet.map.handler;

import 'dart:html' as html;
import 'dart:html' show Element, document, window;
import 'dart:math' as math;
import 'dart:async' show Timer;

import '../map.dart' show LeafletMap;

import '../../core/core.dart' show Handler, EventType, MouseEvent, DateTime, Event;
import '../../dom/dom.dart' as dom;
import '../../geo/geo.dart' show LatLng, LatLngBounds;
import '../../geometry/geometry.dart' show Point2D;

part 'box_zoom.dart';
part 'double_click_zoom.dart';
part 'drag.dart';
part 'keyboard.dart';
part 'scroll_wheel_zoom.dart';
part 'tap.dart';
part 'touch_zoom.dart';