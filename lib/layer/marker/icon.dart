part of leaflet.layer.marker;

class IconType {
  final _value;
  const IconType._internal(this._value);
  toString() => '$_value';

  static const ICON = const IconType._internal('icon');
  static const SHADOW = const IconType._internal('shadow');
}

class IconOptions {
  /**
   * The URL to the icon image (absolute or relative to your script path).
   */
  String iconUrl;

  /**
   * The URL to a retina sized version of the icon image (absolute or relative to your script path). Used for Retina screen devices.
   */
  String iconRetinaUrl;

  /**
   * Size of the icon image in pixels.
   */
  geom.Point iconSize;

  /**
   * The coordinates of the "tip" of the icon (relative to its top left corner). The icon will be aligned so that this point is at the marker's geographical location. Centered by default if size is specified, also can be set in CSS with negative margins.
   */
  geom.Point iconAnchor;

  /**
   * The URL to the icon shadow image. If not specified, no shadow image will be created.
   */
  String shadowUrl;

  /**
   * The URL to the retina sized version of the icon shadow image. If not specified, no shadow image will be created. Used for Retina screen devices.
   */
  String shadowRetinaUrl;

  /**
   * Size of the shadow image in pixels.
   */
  geom.Point shadowSize;

  /**
   * The coordinates of the "tip" of the shadow (relative to its top left corner) (the same as iconAnchor if not specified).
   */
  geom.Point shadowAnchor;

  /**
   * The coordinates of the point from which popups will "open", relative to the icon anchor.
   */
  geom.Point popupAnchor;

  /**
   * A custom class name to assign to both icon and shadow images. Empty by default.
   */
  String className;

  IconOptions(this.iconUrl);
}

/**
 * Icon is an image-based icon class that you can use with L.Marker for custom markers.
 */
class Icon {

  /*final Map<String, Object> options = {

    iconUrl: (String) (required)
    iconRetinaUrl: (String) (optional, used for retina devices if detected)
    iconSize: (Point) (can be set through CSS)
    iconAnchor: (Point) (centered by default, can be set in CSS with negative margins)
    popupAnchor: (Point) (if not specified, popup opens in the anchor point)
    shadowUrl: (String) (no shadow by default)
    shadowRetinaUrl: (String) (optional, used for retina devices if detected)
    shadowSize: (Point)
    shadowAnchor: (Point)

    'className': ''
  };*/
  IconOptions options;

  Icon(this.options);

  createIcon(Element oldIcon) {
    return _createIcon(IconType.ICON, oldIcon);
  }

  createShadow(Element oldIcon) {
    return _createIcon(IconType.SHADOW, oldIcon);
  }

  _createIcon(IconType iconType, Element oldIcon) {
    final src = _getIconUrl(iconType);

    if (src == null) {
      if (iconType == IconType.ICON) {
        throw new Exception('iconUrl not set in Icon options (see the docs).');
      }
      return null;
    }

    Element img;
    if (oldIcon == null || oldIcon.tagName.toUpperCase() != 'IMG') {
      img = _createImg(src);
    } else {
      img = _createImg(src, oldIcon);
    }
    _setIconStyles(img, iconType);

    return img;
  }

  _setIconStyles(Element img, IconType iconType) {
    geom.Point size;
    switch (iconType) {
      case IconType.ICON:
        size = new geom.Point.point(options.iconSize);
        break;
      case IconType.SHADOW:
        size = new geom.Point.point(options.shadowSize);
        break;
    }

    geom.Point anchor = null;
    switch (iconType) {
      case IconType.SHADOW:
        if (options.shadowAnchor != null) {
          anchor = new geom.Point.point(options.shadowAnchor);
        } else {
          anchor = new geom.Point.point(options.iconAnchor);
        }
        break;
      case IconType.ICON:
        anchor = new geom.Point.point(options.iconAnchor);
        break;
    }

    if (anchor == null && size != null) {
      anchor = size.divideBy(2, true);
    }

    img.className = 'leaflet-marker-$iconType ${options.className}';

    if (anchor != null) {
      img.style.marginLeft = '${-anchor.x}px';
      img.style.marginTop = '${-anchor.y}px';
    }

    if (size != null) {
      img.style.width = '${size.x}px';
      img.style.height = '${size.y}px';
    }
  }

  Element _createImg(String src, [Element el=null]) {
    if (el == null) {
      el = new ImageElement();
    }
    el.attributes["src"] = src;
    return el;
  }

  String _getIconUrl(IconType iconType) {
    String iconUrl = null;
    if (Browser.retina) {
      switch (iconType) {
        case IconType.ICON:
          iconUrl = options.iconRetinaUrl;
          break;
        case IconType.SHADOW:
          iconUrl = options.shadowRetinaUrl;
          break;
      }
    }
    if (iconUrl == null) {
      switch (iconType) {
        case IconType.ICON:
          iconUrl = options.iconUrl;
          break;
        case IconType.SHADOW:
          iconUrl = options.shadowUrl;
          break;
      }
    }

    return iconUrl;
  }
}
