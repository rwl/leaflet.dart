// Copyright (c) 2013, MapBox
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
//
//    1. Redistributions of source code must retain the above copyright notice, this list of
//       conditions and the following disclaimer.
//
//    2. Redistributions in binary form must reproduce the above copyright notice, this list
//       of conditions and the following disclaimer in the documentation and/or other materials
//       provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

part of leaflet.control;

class FullscreenOptions extends ControlOptions {

  Map<bool, String> title = {
    false: 'View Fullscreen',
    true: 'Exit Fullscreen'
  };

  FullscreenOptions() {
    position = ControlPosition.TOPLEFT;
  }
}

class Fullscreen extends Control {

  FullscreenOptions get fullscreenOptions => options as FullscreenOptions;
  AnchorElement link;
  StreamSubscription<MapEvent> _fullscreenSubscription;
  StreamSubscription<html.MouseEvent> _clickSubscription;

  Fullscreen([FullscreenOptions fullscreenOptions=null]) : super(fullscreenOptions) {
    if (options == null) {
      options = new FullscreenOptions();
    }
  }

  onAdd(LeafletMap map) {
    final container = document.createElement('div', 'leaflet-control-fullscreen leaflet-bar leaflet-control');

    link = new AnchorElement();
    link.classes.add('leaflet-control-fullscreen-button leaflet-bar-part');
    link.href = '#';
    container.append(link);

    _map = map;
    _fullscreenSubscription = _map.onFullscreenChange.listen(_toggleTitle);
    _toggleTitle();

    _clickSubscription = link.onClick.listen(_click);

    return container;
  }

  onRemove(_) {
    _fullscreenSubscription.cancel();
    _clickSubscription.cancel();
    link.remove();
  }

  _click(html.MouseEvent e) {
    e.stopPropagation();
    e.preventDefault();
    _map.toggleFullscreen();
  }

  _toggleTitle([_]) {
    link.title = fullscreenOptions.title[_map.isFullscreen];
  }
}
