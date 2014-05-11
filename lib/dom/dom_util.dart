part of leaflet.dom;

final DomUtil = new _DomUtil();

// DomUtil contains various utility functions for working with DOM.
class _DomUtil {

  get(id) {
    return (id is String ? document.getElementById(id) : id);
  }

  getStyle(el, style) {

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

  getViewportOffset(element) {

    var top = 0,
        left = 0,
        el = element,
        docBody = document.body,
        docEl = document.documentElement,
        pos;

    do {
      top  += el.offsetTop  || 0;
      left += el.offsetLeft || 0;

      //add borders
      top += parseInt(L.DomUtil.getStyle(el, 'borderTopWidth'), 10) || 0;
      left += parseInt(L.DomUtil.getStyle(el, 'borderLeftWidth'), 10) || 0;

      pos = L.DomUtil.getStyle(el, 'position');

      if (el.offsetParent == docBody && pos == 'absolute') { break; }

      if (pos == 'fixed') {
        top  += docBody.scrollTop  || docEl.scrollTop  || 0;
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
        top += r.top + (docBody.scrollTop  || docEl.scrollTop  || 0);

        break;
      }

      el = el.offsetParent;

    } while (el);

    el = element;

    do {
      if (el == docBody) { break; }

      top  -= el.scrollTop  || 0;
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

  create(tagName, className, container) {

    var el = document.createElement(tagName);
    el.className = className;

    if (container) {
      container.appendChild(el);
    }

    return el;
  }

  hasClass(el, name) {
    if (el.classList != null) {
      return el.classList.contains(name);
    }
    var className = L.DomUtil._getClass(el);
    return className.length > 0 && new RegExp(r'(^|\\s)' + name + '(\\s|\$)').test(className);
  }

  addClass(el, name) {
    if (el.classList != null) {
      var classes = L.Util.splitWords(name);
      for (var i = 0, len = classes.length; i < len; i++) {
        el.classList.add(classes[i]);
      }
    } else if (!L.DomUtil.hasClass(el, name)) {
      var className = L.DomUtil._getClass(el);
      L.DomUtil._setClass(el, (className ? className + ' ' : '') + name);
    }
  }

  removeClass(el, name) {
    if (el.classList != null) {
      el.classList.remove(name);
    } else {
      L.DomUtil._setClass(el, L.Util.trim((' ' + L.DomUtil._getClass(el) + ' ').replace(' ' + name + ' ', ' ')));
    }
  }

  _setClass(el, name) {
    if (el.className.baseVal == null) {
      el.className = name;
    } else {
      // in case of SVG element
      el.className.baseVal = name;
    }
  }

  _getClass(el) {
    return el.className.baseVal == null ? el.className : el.className.baseVal;
  }

  setOpacity(el, value) {

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
        if (value == 1) { return; }
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

  testProp(props) {

    var style = document.documentElement.style;

    for (var i = 0; i < props.length; i++) {
      if (style.contains(props[i])) {
        return props[i];
      }
    }
    return false;
  }

  getTranslateString(point) {
    // on WebKit browsers (Chrome/Safari/iOS Safari/Android) using translate3d instead of translate
    // makes animation smoother as it ensures HW accel is used. Firefox 13 doesn't care
    // (same speed either way), Opera 12 doesn't support translate3d

    var is3d = L.Browser.webkit3d,
        open = 'translate' + (is3d ? '3d' : '') + '(',
        close = (is3d ? ',0' : '') + ')';

    return open + point.x + 'px,' + point.y + 'px' + close;
  }

  getScaleString(scale, origin) {

    var preTranslateStr = L.DomUtil.getTranslateString(origin.add(origin.multiplyBy(-1 * scale))),
        scaleStr = ' scale(' + scale + ') ';

    return preTranslateStr + scaleStr;
  }

  setPosition(el, point, disable3D) { // (HTMLElement, Point[, Boolean])

    // jshint camelcase: false
    el._leaflet_pos = point;

    if (!disable3D && L.Browser.any3d) {
      el.style[L.DomUtil.TRANSFORM] =  L.DomUtil.getTranslateString(point);
    } else {
      el.style.left = point.x + 'px';
      el.style.top = point.y + 'px';
    }
  }

  getPosition(el) {
    // this method is only used for elements previously positioned using setPosition,
    // so it's safe to cache the position for performance

    // jshint camelcase: false
    return el._leaflet_pos;
  }
}