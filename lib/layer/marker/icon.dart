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
  Point2D iconSize;

  /**
   * The coordinates of the "tip" of the icon (relative to its top left corner). The icon will be aligned so that this point is at the marker's geographical location. Centered by default if size is specified, also can be set in CSS with negative margins.
   */
  Point2D iconAnchor;

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
  Point2D shadowSize;

  /**
   * The coordinates of the "tip" of the shadow (relative to its top left corner) (the same as iconAnchor if not specified).
   */
  Point2D shadowAnchor;

  /**
   * The coordinates of the point from which popups will "open", relative to the icon anchor.
   */
  Point2D popupAnchor;

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

  IconOptions options;

  Icon(this.options);

  ImageElement createIcon(Element oldIcon) {
    return _createIcon(IconType.ICON, oldIcon);
  }

  ImageElement createShadow(Element oldIcon) {
    return _createIcon(IconType.SHADOW, oldIcon);
  }

  ImageElement _createIcon(IconType iconType, Element oldIcon) {
    final src = _getIconUrl(iconType);

    if (src == null) {
      if (iconType == IconType.ICON) {
        throw new Exception('iconUrl not set in Icon options (see the docs).');
      }
      return null;
    }

    ImageElement img;
    if (oldIcon == null || oldIcon.tagName.toUpperCase() != 'IMG') {
      img = _createImg(src);
    } else {
      img = _createImg(src, oldIcon);
    }
    _setIconStyles(img, iconType);

    return img;
  }

  void _setIconStyles(Element img, IconType iconType) {
    Point2D size;
    switch (iconType) {
      case IconType.ICON:
        size = new Point2D.point(options.iconSize);
        break;
      case IconType.SHADOW:
        size = new Point2D.point(options.shadowSize);
        break;
    }

    Point2D anchor = null;
    switch (iconType) {
      case IconType.SHADOW:
        if (options.shadowAnchor != null) {
          anchor = new Point2D.point(options.shadowAnchor);
        } else {
          anchor = new Point2D.point(options.iconAnchor);
        }
        break;
      case IconType.ICON:
        anchor = new Point2D.point(options.iconAnchor);
        break;
    }

    if (anchor == null && size != null) {
      anchor = (size / 2).rounded();
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

  ImageElement _createImg(String src, [ImageElement el=null]) {
    if (el == null) {
      el = new ImageElement();
    }
    el.src = src;
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
