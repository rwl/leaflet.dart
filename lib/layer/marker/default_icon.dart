part of leaflet.layer.marker;

/**
 * Default is the blue marker icon used by default in Leaflet.
 */
class Default extends Icon {

  static String imagePath;

  static final _defaultOptions = new IconOptions("")
    ..iconSize = new geom.Point(25, 41)
    ..iconAnchor = new geom.Point(12, 41)
    ..popupAnchor = new geom.Point(1, -34)
    ..shadowSize = new geom.Point(41, 41);

  Default() : super(_defaultOptions);

  String _getIconUrl(IconType iconType) {

    switch (iconType) {
      case IconType.SHADOW:
        if (options.shadowUrl != null) {
          return options.shadowUrl;
        }
        break;
      case IconType.ICON:
        if (options.iconUrl != null) {
          return options.iconUrl;
        }
        break;
    }

    String name = iconType.toString();

    if (Browser.retina && name == 'icon') {
      name += '-2x';
    }

    final path = Default.imagePath;

    if (path == null) {
      throw new Exception('Couldn\'t autodetect Default.imagePath, set it manually.');
    }

    return '$path/marker-$name.png';
  }

}