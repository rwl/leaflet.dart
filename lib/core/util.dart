part of leaflet.core;

final Util = new Utils();

final idProp = new Expando<Object>('_leaflet_id');

class Utils {
  int lastId = 0;

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

  formatNum(num n, [int digits = 5]) {
    var pow = math.pow(10, digits);
    return (n * pow).round() / pow;
  }

  trim(String str) {
    return str.trim();//str.trim ? str.trim() : str.replace(/^\s+|\s+$/g, '');
  }

  splitWords(String str) {
    return str.split(r'\s+');//L.Util.trim(str).split(/\s+/);
  }
}
