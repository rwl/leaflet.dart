part of leaflet.layer.marker;

class DivIconOptions extends IconOptions {
  /// Size of the icon in pixels. Can be also set through CSS.
  Point2D iconSize = new Point2D(12, 12);

  /// The coordinates of the "tip" of the icon (relative to its top left
  /// corner). The icon will be aligned so that this point is at the
  /// marker's geographical location. Centered by default if size is
  /// specified, also can be set in CSS with negative margins.
  Point2D iconAnchor;

  /// A custom class name to assign to the icon. 'leaflet-div-icon' by default.
  String  className = 'leaflet-div-icon';

  /// A custom HTML code to put inside the div element, empty by default.
  String  html;

  Point2D bgPos;

  DivIconOptions(String iconUrl) : super(iconUrl);
}

/// DivIcon is a lightweight HTML-based icon class (as opposed to the
/// image-based Icon) to use with Marker.
class DivIcon extends Icon {

  DivIconOptions get divIconOptions => options as DivIconOptions;

  DivIcon([DivIconOptions options=null]) : super(options) {
    if (options == null) {
      options = new DivIconOptions("");
    }
  }

  Element createIcon([Element oldIcon=null]) {
    final div = (oldIcon != null && oldIcon.tagName.toUpperCase() == 'DIV') ? oldIcon : new DivElement();

    if (divIconOptions.html != null) {
      div.setInnerHtml(divIconOptions.html);
    } else {
      div.setInnerHtml('');
    }

    if (divIconOptions.bgPos != null) {
      div.style.backgroundPosition =
              '${-divIconOptions.bgPos.x}px ${-divIconOptions.bgPos.y}px';
    }

    _setIconStyles(div, IconType.ICON);
    return div;
  }

  Element createShadow([Element oldIcon=null]) {
    return null;
  }
}
