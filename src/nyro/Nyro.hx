package nyro;

#if web
typedef Nyro = platform.web.Nyro;
#elseif love2d
typedef Nyro = platform.love2d.Nyro;
#else

/**
 * The main class runs the game loop and sets up the services.
 */
extern class Nyro {
  /**
   * Create a new Nyro instance.
   */
  public function new();

  /**
   * Start the game.
   */
  public function start(): Void;
}
#end
