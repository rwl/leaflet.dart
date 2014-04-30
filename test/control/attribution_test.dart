import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:leaflet/control/attribution.dart';
import 'package:leaflet/leaflet.dart' as L;


main() {
  useHtmlEnhancedConfiguration();

  var map, control, container;

  setUp(() {
    map = L.map(document.createElement('div'));
    control = new L.Control.Attribution({
      prefix: 'prefix'
    }).addTo(map);
    container = control.getContainer();
  });

  test('contains just prefix if no attributions added', () {
    expect(container.innerHTML).to.eql('prefix');
  });

  describe('#addAttribution', () {
    test('adds one attribution correctly', () {
      control.addAttribution('foo');
      expect(container.innerHTML).to.eql('prefix | foo');
    });

    test('adds no duplicate attributions', () {
      control.addAttribution('foo');
      control.addAttribution('foo');
      expect(container.innerHTML).to.eql('prefix | foo');
    });

    test('adds several attributions listed with comma', () {
      control.addAttribution('foo');
      control.addAttribution('bar');
      expect(container.innerHTML).to.eql('prefix | foo, bar');
    });
  });

  describe('#removeAttribution', () {
    test('removes attribution correctly', () {
      control.addAttribution('foo');
      control.addAttribution('bar');
      control.removeAttribution('foo');
      expect(container.innerHTML).to.eql('prefix | bar');
    });
    test('does nothing if removing attribution that was not present', () {
      control.addAttribution('foo');
      control.addAttribution('baz');
      control.removeAttribution('bar');
      control.removeAttribution('baz');
      control.removeAttribution('baz');
      control.removeAttribution('');
      expect(container.innerHTML).to.eql('prefix | foo');
    });
  });

  describe('#setPrefix', () {
    test('changes prefix', () {
      control.setPrefix('bla');
      expect(container.innerHTML).to.eql('bla');
    });
  });

  describe('control.attribution factory', () {
    test('creates Control.Attribution instance', () {
      var options = {prefix: 'prefix'};
      expect(L.control.attribution(options)).to.eql(new L.Control.Attribution(options));
    });
  });
}
