package nyro.core.platforms.web;

import js.Browser;
import js.html.CanvasElement;

using nyro.core.utils.Destructure;

private final MAX_DT = 1.0 / 15;

@:build(nyro.core.utils.CoreMacros.buildCoreConfig())
class Core {
  public final canvas: CanvasElement;

  public var targetFps: Int;

  static var options: CoreOptions;

  var lastFrameTime: Float;

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
  }

  public function start() {}

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
