part of leaflet.layer.marker;

const defaultImagePath = '/packages/leaflet/images';

/// Default is the blue marker icon used by default in Leaflet.
class DefaultIcon extends Icon {

  static String imagePath = defaultImagePath;

  static final _defaultOptions = new IconOptions(null)
    ..iconSize = new Point2D(25, 41)
    ..iconAnchor = new Point2D(12, 41)
    ..popupAnchor = new Point2D(1, -34)
    ..shadowSize = new Point2D(41, 41);

  DefaultIcon() : super(_defaultOptions);

  String getIconUrl(IconType iconType) {

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

//    if (Browser.retina && name == 'icon') { TODO: retina
//      name += '-2x';
//    }

    final path = DefaultIcon.imagePath;

    if (path == null) {
      throw new Exception('Couldn\'t autodetect Default.imagePath, set it manually.');
    }

    return '$path/marker-$name.png';
  }
}
