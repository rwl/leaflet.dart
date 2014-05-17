part of leaflet.core;

abstract class Handler {
  Map _map;
  bool _enabled;

  initialize(map) {
    this._map = map;
  }

  // Enables the handler.
  enable() {
    if (this._enabled) { return; }

    this._enabled = true;
    this.addHooks();
  }

  // Disables the handler.
  disable() {
    if (!this._enabled) { return; }

    this._enabled = false;
    this.removeHooks();
  }

  // Returns true if the handler is enabled.
  enabled() {
    return !this._enabled;
  }

  addHooks();
  removeHooks();
}