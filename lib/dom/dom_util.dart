part of leaflet.dom;

/// Returns an element with the given id if a string was passed, or just
/// returns the element if it was passed directly.
//Element get(String id) {
//  return (id is String ? document.getElementById(id) : id);
//}

String px(num i) => '${i}px';

/// Returns the value for a certain style attribute on an element, including
/// computed values or values set through CSS.
// TODO: no caller? delete?
String getStyle(Element el, String style) {
  var value = el.getComputedStyle();
  return value == 'auto' ? null : value;
}

/// Returns the offset to the viewport for the requested element.
Point2D getViewportOffset(Element element) {
  var bounds = element.getBoundingClientRect();
  return new Point2D(bounds.left + document.body.scrollLeft,
      bounds.top + document.body.scrollTop);
}

bool _isLtr;
documentIsLtr() {
  if (_isLtr != null) return _isLtr;
  return _isLtr = document.body.getComputedStyle()
      .getPropertyValue('direction') == 'ltr';
}

/// Creates an element with tagName, sets the className, and optionally
/// appends it to container element.
Element create(String tagName, String className, [Element container=null]) {

  var el = document.createElement(tagName);
  el.className = className;

  if (container != null) {
    container.append(el);
  }

  return el;
}

/// Goes through the array of style names and returns the first name that is
/// a valid style name for an element. If no such name is found, it returns
/// null. Useful for vendor-prefixed styles like transform.
// TODO: no uses? This isn't easily implementable in Dart. Remove?
String testProp(List<String> props) {

  var style = document.documentElement.style;

  for (var i = 0; i < props.length; i++) {
    if (style.contains(props[i])) {
      return props[i];
    }
  }
  return null;
}

/// Returns a CSS transform string to move an element by the offset provided
/// in the given point. Uses 3D translate on WebKit for hardware-accelerated
/// transforms and 2D on other browsers.
// All browsers that support Dart support translate3d
String getTranslateString(Point2D point) =>
    'translate3d(${point.x}px, ${point.y}px, 0)';

/// Returns a CSS transform string to scale an element (with the given
/// scale origin).
String getScaleString(num scale, Point2D origin) {
  var preTranslateStr =
      getTranslateString(origin..add(origin..multiplyBy(-1 * scale)));
  return '$preTranslateStr scale($scale) ';
}

Expando<Point2D> _leafletPos = new Expando<Point2D>();

/// Sets the position of an element to coordinates specified by point, using
/// CSS translate or top/left positioning depending on the browser (used by
/// Leaflet internally to position its layers). Forces top/left positioning
/// if disable3D is true.
void setPosition(Element el, Point2D point) {
  _leafletPos[el] = point;
  if (point != null) {
    el.style.transform = getTranslateString(point);
  } else {
    throw 'null point';
  }
}

/// Returns the coordinates of an element previously positioned with setPosition.
// this method is only used for elements previously positioned using setPosition,
// so it's safe to cache the position for performance
Point2D getPosition(Element el) => _leafletPos[el];

var _selectSubscription;

/// Makes sure text cannot be selected, for example during dragging.
disableTextSelection() {
  if (_selectSubscription == null) {
    _selectSubscription =
        window.document.onSelectStart.listen(preventDefault);
  }
}

/// Makes text selection possible again.
enableTextSelection() {
  if (_selectSubscription != null) {
    _selectSubscription.cancel();
    _selectSubscription = null;
  }
}

var _dragSubscription;


disableImageDrag() {
  if (_dragSubscription == null) {
    _dragSubscription =
        window.document.onDragStart.listen(preventDefault);
  }
}

enableImageDrag() {
  if (_dragSubscription != null) {
    _dragSubscription.cancel();
    _dragSubscription = null;
  }
}
