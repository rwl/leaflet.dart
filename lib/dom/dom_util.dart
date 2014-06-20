part of leaflet.dom;

final DomUtil = new _DomUtil();

/**
 * DomUtil contains various utility functions for working with DOM.
 */
//class _DomUtil {

/**
 * Vendor-prefixed transition style name (e.g. 'webkitTransition' for WebKit).
 */
String TRANSITION;

/**
 * Vendor-prefixed transform style name.
 */
String TRANSFORM;

/**
 * Returns an element with the given id if a string was passed, or just returns the element if it was passed directly.
 */
Element get(String id) {
  return (id is String ? document.getElementById(id) : id);
}

/**
 * Returns the value for a certain style attribute on an element, including computed values or values set through CSS.
 */
String getStyle(Element el, String style) {

  var value = el.style[style];

  if (!value && el.currentStyle) {
    value = el.currentStyle[style];
  }

  if ((!value || value == 'auto') && document.defaultView) {
    var css = document.defaultView.getComputedStyle(el, null);
    value = css ? css[style] : null;
  }

  return value == 'auto' ? null : value;
}

/**
 * Returns the offset to the viewport for the requested element.
 */
geom.Point getViewportOffset(Element element) {

  int top = 0,
      left = 0;
  final el = element,
      docBody = document.body,
      docEl = document.documentElement;

  do {
    top += el.offsetTop || 0;
    left += el.offsetLeft || 0;

    //add borders
    top += parseInt(L.DomUtil.getStyle(el, 'borderTopWidth'), 10) || 0;
    left += parseInt(L.DomUtil.getStyle(el, 'borderLeftWidth'), 10) || 0;

    final pos = L.DomUtil.getStyle(el, 'position');

    if (el.offsetParent == docBody && pos == 'absolute') {
      break;
    }

    if (pos == 'fixed') {
      top += docBody.scrollTop || docEl.scrollTop || 0;
      left += docBody.scrollLeft || docEl.scrollLeft || 0;
      break;
    }

    if (pos == 'relative' && !el.offsetLeft) {
      var width = L.DomUtil.getStyle(el, 'width'),
          maxWidth = L.DomUtil.getStyle(el, 'max-width'),
          r = el.getBoundingClientRect();

      if (width != 'none' || maxWidth != 'none') {
        left += r.left + el.clientLeft;
      }

      //calculate full y offset since we're breaking out of the loop
      top += r.top + (docBody.scrollTop || docEl.scrollTop || 0);

      break;
    }

    el = el.offsetParent;

  } while (el);

  el = element;

  do {
    if (el == docBody) {
      break;
    }

    top -= el.scrollTop || 0;
    left -= el.scrollLeft || 0;

    el = el.parentNode;
  } while (el);

  return new L.Point(left, top);
}

documentIsLtr() {
  if (!L.DomUtil._docIsLtrCached) {
    L.DomUtil._docIsLtrCached = true;
    L.DomUtil._docIsLtr = L.DomUtil.getStyle(document.body, 'direction') == 'ltr';
  }
  return L.DomUtil._docIsLtr;
}

/**
 * Creates an element with tagName, sets the className, and optionally appends it to container element.
 */
Element create(String tagName, String className, [Element container=null]) {

  var el = document.createElement(tagName);
  el.className = className;

  if (container != null) {
    container.append(el);
  }

  return el;
}

/**
 * Returns true if the element class attribute contains name.
 */
bool hasClass(Element el, String name) {
  if (el.classList != null) {
    return el.classList.contains(name);
  }
  var className = _getClass(el);
  return className.length > 0 && new RegExp(r'(^|\\s)' + name + '(\\s|\$)').test(className);
}

/**
 * Adds name to the element's class attribute.
 */
void addClass(Element el, String name) {
  if (el.classList != null) {
    var classes = L.Util.splitWords(name);
    for (var i = 0,
        len = classes.length; i < len; i++) {
      el.classList.add(classes[i]);
    }
  } else if (!L.DomUtil.hasClass(el, name)) {
    var className = L.DomUtil._getClass(el);
    L.DomUtil._setClass(el, (className ? className + ' ' : '') + name);
  }
}

/**
 * Removes name from the element's class attribute.
 */
void removeClass(Element el, String name) {
  if (el.classList != null) {
    el.classList.remove(name);
  } else {
    L.DomUtil._setClass(el, L.Util.trim((' ' + L.DomUtil._getClass(el) + ' ').replace(' ' + name + ' ', ' ')));
  }
}

void _setClass(Element el, String name) {
  if (el.className.baseVal == null) {
    el.className = name;
  } else {
    // in case of SVG element
    el.className.baseVal = name;
  }
}

String _getClass(Element el) {
  return el.className.baseVal == null ? el.className : el.className.baseVal;
}

/**
 * Set the opacity of an element (including old IE support). Value must be from 0 to 1.
 */
void setOpacity(Element el, num value) {

  if (el.style.contains('opacity')) {
    el.style.opacity = value;

  } else if (el.style.contains('filter')) {

    var filter = false,
        filterName = 'DXImageTransform.Microsoft.Alpha';

    // filters collection throws an error if we try to retrieve a filter that doesn't exist
    try {
      filter = el.filters.item(filterName);
    } catch (e) {
      // don't set opacity to 1 if we haven't already set an opacity,
      // it isn't needed and breaks transparent pngs.
      if (value == 1) {
        return;
      }
    }

    value = Math.round(value * 100);

    if (filter) {
      filter.Enabled = (value != 100);
      filter.Opacity = value;
    } else {
      el.style.filter += ' progid:' + filterName + '(opacity=' + value + ')';
    }
  }
}

/**
 * Goes through the array of style names and returns the first name that is a valid style name for an element. If no such name is found, it returns null. Useful for vendor-prefixed styles like transform.
 */
String testProp(List<String> props) {

  var style = document.documentElement.style;

  for (var i = 0; i < props.length; i++) {
    if (style.contains(props[i])) {
      return props[i];
    }
  }
  return null;
}

/**
 * Returns a CSS transform string to move an element by the offset provided in the given point. Uses 3D translate on WebKit for hardware-accelerated transforms and 2D on other browsers.
 */
String getTranslateString(geom.Point point) {
  // on WebKit browsers (Chrome/Safari/iOS Safari/Android) using translate3d instead of translate
  // makes animation smoother as it ensures HW accel is used. Firefox 13 doesn't care
  // (same speed either way), Opera 12 doesn't support translate3d

  var is3d = L.Browser.webkit3d,
      open = 'translate' + (is3d ? '3d' : '') + '(',
      close = (is3d ? ',0' : '') + ')';

  return open + point.x + 'px,' + point.y + 'px' + close;
}

/**
 * Returns a CSS transform string to scale an element (with the given scale origin).
 */
String getScaleString(num scale, geom.Point origin) {

  var preTranslateStr = L.DomUtil.getTranslateString(origin.add(origin.multiplyBy(-1 * scale))),
      scaleStr = ' scale(' + scale + ') ';

  return preTranslateStr + scaleStr;
}

/**
 * Sets the position of an element to coordinates specified by point, using
 * CSS translate or top/left positioning depending on the browser (used by
 * Leaflet internally to position its layers). Forces top/left positioning
 * if disable3D is true.
 */
void setPosition(Element el, geom.Point point, [bool disable3D=false]) {

  // jshint camelcase: false
  el._leaflet_pos = point;

  if (!disable3D && L.Browser.any3d) {
    el.style[L.DomUtil.TRANSFORM] = L.DomUtil.getTranslateString(point);
  } else {
    el.style.left = point.x + 'px';
    el.style.top = point.y + 'px';
  }
}

/**
 * Returns the coordinates of an element previously positioned with setPosition.
 */
geom.Point getPosition(Element el) {
  // this method is only used for elements previously positioned using setPosition,
  // so it's safe to cache the position for performance

  // jshint camelcase: false
  return el._leaflet_pos;
}

/**
 * Makes sure text cannot be selected, for example during dragging.
 */
disableTextSelection() {
  on(window, 'selectstart', preventDefault);
}

/**
 * Makes text selection possible again.
 */
enableTextSelection() {
  off(window, 'selectstart', preventDefault);
}

disableImageDrag() {
  on(window, 'dragstart', preventDefault);
}

enableImageDrag() {
  off(window, 'dragstart', preventDefault);
}