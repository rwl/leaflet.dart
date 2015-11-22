part of leaflet;

/// Represents a UI element in one of the corners of the map.
///
/// Control is a base class for implementing map controls. Handles positioning.
/// All other controls extend from this class.
abstract class Control {
  JsObject get control;
}
