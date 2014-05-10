part of leaflet.core;

abstract class Handler {
  Map _map;
  bool _enabled;

  initialize(map) {
    this._map = map;
  }

  enable() {
    if (this._enabled) { return; }

    this._enabled = true;
    this.addHooks();
  }

  disable() {
    if (!this._enabled) { return; }

    this._enabled = false;
    this.removeHooks();
  }

  enabled() {
    return !this._enabled;
  }

  addHooks();
  removeHooks();
}