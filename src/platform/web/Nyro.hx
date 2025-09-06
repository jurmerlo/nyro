package platform.web;

import js.Browser;
import js.html.CanvasElement;

import nyro.NyroOptions;
import nyro.di.Services;
import nyro.events.Events;
import nyro.input.KeyCode;
import nyro.input.KeyboardEvent;

using nyro.utils.Destructure;

private final MAX_DT = 1.0 / 15;

@:build(nyro.utils.Macros.buildNyroConfig())
class Nyro {
  public final canvas: CanvasElement;

  public var targetFps: Int;

  static var options: NyroOptions;

  var lastFrameTime: Float;

  final events: Events;

  public function new() {
    options.destructure(final width, final height, final targetFps);

    final canvasId = 'nyro';
    canvas = cast Browser.document.getElementById(canvasId);

    if (canvas == null) {
      throw 'No canvas element found with id "$canvasId".';
    }

    this.targetFps = targetFps ?? -1;

    canvas.width = width;
    canvas.height = height;
    canvas.style.width = '${width}px';
    canvas.style.height = '${height}px';

    events = new Events();
    Services.add(events);
  }

  public function start() {
    final listener = events.addListener(KeyboardEvent.KEY_DOWN, (e) -> {
      trace('key: ${e.key}, code: ${e.code}');
    }, (e) -> e.key == KeyCode.A);
  }

  function toBackground() {}

  function toForeground() {}

  function resize(width: Int, height: Int) {}

  function loop() {
    Browser.window.requestAnimationFrame((_time: Float) -> loop());

    final now = Browser.window.performance.now();
    final timePassed = now - lastFrameTime;
    if (targetFps == -1) {
      update(timePassed / 1000.0);
      lastFrameTime = now;
    } else {
      final interval = 1.0 / targetFps;
      if (timePassed < interval) {
        return;
      }

      final excess = timePassed % interval;

      update((timePassed - excess) / 1000.0);
      lastFrameTime = now - excess;
    }
  }

  function update(dt: Float) {
    render();
  }

  function render() {}
}
