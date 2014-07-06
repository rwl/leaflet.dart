library leaflet.layer.vector;

import 'dart:html' show window, document, Element, Event;
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:async' show Stream, StreamController, StreamSubscription;

import 'package:simple_features/simple_features.dart' as sfs;

import '../../core/core.dart';
import '../../map/map.dart';
import '../../geo/geo.dart';
import '../../dom/dom.dart' as dom;
import '../../geometry/geometry.dart' show clipPolygon, simplify, Point2D, clipSegment;

import '../layer.dart' show Popup, PopupOptions, GeoJSON, Layer, FeatureGroup;

part 'circle.dart';
part 'circle_marker.dart';
part 'path.dart';
part 'polygon.dart';
part 'polyline.dart';
part 'rectangle.dart';
part 'multi.dart';
