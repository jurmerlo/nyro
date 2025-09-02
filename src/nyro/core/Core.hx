package nyro.core;

#if web
typedef Core = nyro.core.platforms.web.Core;
#elseif love2d
typedef Core = nyro.core.platforms.love2d.Core;
#else

/**
 * The Core class runs the game loop and sets up the services.
 */
extern class Core {
  /**
   * Create a new Core instance.
   */
  public function new();

  /**
   * Start the game.
   */
  public function start(): Void;
}
#end
