part of leaflet.core;

//final Util = new Util();

/**
 * Data URI string containing a base64-encoded empty GIF image. Used as a
 * hack to free memory from unused images on WebKit-powered mobile devices
 * (by setting image src to this string).
 */
String emptyImageUrl;

final idProp = new Expando<Object>('_leaflet_id');

/**
 * Various utility functions, used by Leaflet internally.
 */
//class _Util {)

int lastId = 0;

/**
 * Applies a unique key to the object and returns that key.
 */
int stamp(Object obj) {
  if (idProp[obj] == null) {
    lastId++;
    idProp[obj] = lastId;
  }
  return idProp[obj];
}

//falseFn() {
//  return false;
//}

/**
 * Returns the number num rounded to digits decimals.
 */
num formatNum(num n, [int digits = 5]) {
  var pow = math.pow(10, digits);
  return (n * pow).round() / pow;
}

/**
 * Trims the whitespace from both ends of the string and returns the result.
 */
String trim(String str) {
  return str.trim();//str.trim ? str.trim() : str.replace(/^\s+|\s+$/g, '');
}

/**
 * Trims and splits the string on whitespace and returns the array of parts.
 */
List<String> splitWords(String str) {
  return str.split(r'\s+');//L.Util.trim(str).split(/\s+/);
}

String template(String url, Map data) => new UriTemplate(url).expand(data);