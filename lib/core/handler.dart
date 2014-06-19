part of leaflet.core;

/**
 * An interface implemented by interaction handlers.
 */
abstract class Handler {

  BaseMap _map;

  bool _enabled;

  Handler(this._map);

  BaseMap get map => _map;

  /**
   * Enables the handler.
   */
  void enable() {
    if (_enabled) { return; }

    _enabled = true;
    addHooks();
  }

  /**
   * Disables the handler.
   */
  void disable() {
    if (!_enabled) { return; }

    _enabled = false;
    removeHooks();
  }

  /**
   * Returns true if the handler is enabled.
   */
  bool enabled() {
    return _enabled;
  }

  void addHooks();

  void removeHooks();
}