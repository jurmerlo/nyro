package nyro.core.platforms.love2d;

import love.Love;
import love.graphics.Graphics;

using nyro.core.utils.Destructure;

@:build(nyro.core.utils.CoreMacros.buildCoreConfig())
class Core {
  static var options: CoreOptions;

  public function new() {
    Love.update = (dt) -> {}

    Love.draw = () -> {
      Graphics.line(0, 0, 100, 100);
    }
  }

  public function start() {
    Love.update = update;
    Love.draw = render;
  }

  function update(dt: Float) {}

  function render() {
    trace('rendering');
  }
}
