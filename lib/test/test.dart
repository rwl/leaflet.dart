library leaflet.test;

import 'package:unittest/unittest.dart';
import 'package:leaflet/geo/geo.dart' show LatLng;
import 'package:leaflet/geometry/geometry.dart' show Point2D;

Matcher near(Point2D expected, [num delta=1]) => new _Near(expected, delta);

class _Near extends Matcher {
  final delta;
  final expected;
  const _Near(this.expected, this.delta);
  bool matches(item, Map matchState) {
    if (item.x < expected.x - delta || item.x > expected.x + delta) {
      return false;
    } else if (item.y < expected.y - delta || item.y > expected.y + delta) {
      return false;
    }
    return true;
  }
  Description describe(Description description) {
    description.add('near');
    return description;
  }
}

Matcher nearLatLng(LatLng expected, [num delta=1e-4]) => new _NearLatLng(expected, delta);

class _NearLatLng extends Matcher {
  final delta, expected;
  _NearLatLng(this.expected, this.delta);
  bool matches(LatLng item, Map matchState) {
    if (item.lat < expected.lat - delta || item.lat > expected.lat + delta) {
      return false;
    } else if (item.lng < expected.lng - delta || item.lng > expected.lng + delta) {
      return false;
    }
    return true;
  }
  Description describe(Description description) {
    description.add('near LatLng');
    return description;
  }
}
