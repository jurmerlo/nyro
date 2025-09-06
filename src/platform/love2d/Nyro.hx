package platform.love2d;

import love.Love;

import nyro.NyroOptions;
import nyro.di.Services;
import nyro.events.Events;

import platform.love2d.input.Love2dInput;

using nyro.utils.Destructure;

@:build(nyro.utils.Macros.buildNyroConfig())
class Nyro {
  static var options: NyroOptions;

  var loveInput: Love2dInput;

  final events: Events;

  public function new() {
    events = new Events();
    Services.add(events);
  }

  public function start() {
    Love.update = update;
    Love.draw = render;

    Love.focus = focus;
    Love.resize = resize;

    loveInput = new Love2dInput();
  }

  function update(dt: Float) {}

  function render() {}

  function focus(focus: Bool) {}

  function resize(width: Float, height: Float) {}
}
