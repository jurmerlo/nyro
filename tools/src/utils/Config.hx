package tools.src.utils;

enum abstract ExportTarget(String) from String to String {
  var Web = 'web';
  var Love2D = 'love2d';
}

/**
 * Represents a library dependency.
 */
private typedef Library = {
  /**
   * The name of the library.
   */
  var name: String;

  /**
   * The version or git URL of the library.
   */
  var ?version: String;
}

typedef WebOptions = {
  /**
   * The id of the canvas element to use.
   */
  var ?canvasId: String;

  /**
   * The name of the javascript file to output.
   */
  var ?scriptName: String;

  /**
   * The path to a custom index.html file to use.
   */
  var ?htmlIndexPath: String;
}

typedef Love2dOptions = {
  /**
   * The name of the save directory.
   */
  var ?identity: String;

  /**
   * Search files in source directory before save directory.
   */
  var ?appendidentity: Bool;

  /**
   * The LÖVE version this game was made for.
   */
  var ?version: String;

  /**
   * Attach a console (Windows only).
   */
  var ?console: Bool;

  /**
   * Enable the accelerometer on iOS and Android by exposing it as a Joystick.
   */
  var ?accelerometerjoystick: Bool;

  /**
   * True to save files (and read from the save directory) in external storage on Android.
   */
  var ?externalstorage: Bool;

  /**
   * Enable gamma-correct rendering, when supported by the system.
   */
  var ?gammacorrect: Bool;

  var ?audio: {
    /**
     * Request and use microphone capabilities in Android.
     */
    ?mic: Bool,
    /**
     * Keep background music playing when opening LOVE (iOS and Android only).
     */
    ?mixwithsystem: Bool
  }

  var ?window: {
    /**
     * Filepath to an image to use as the window's icon.
     */
    ?icon: String,
    /**
     * Remove all border visuals from the window.
     */
    ?borderless: Bool,
    /**
     * Let the window be user-resizable.
     */
    ?resizable: Bool,
    /**
     * The minimum window width if the window is resizable.
     */
    ?minwidth: Int,
    /**
     * The minimum window height if the window is resizable.
     */
    ?minheight: Int,
    /**
     * Choose between "desktop" fullscreen or "exclusive" fullscreen mode.
     */
    ?fullscreentype: String,
    /**
     * Vertical sync mode.
     */
    ?vsync: Int,
    /**
     * The number of samples to use with multi-sampled antialiasing.
     */
    ?msaa: Int,
    /**
     * The number of bits per sample in the depth buffer
     */
    ?depth: Int,
    /**
     * The number of bits per sample in the stencil buffer
     */
    ?stencil: Int,
    /**
     * Index of the monitor to show the window in.
     */
    ?display: Int,
    /**
     * The x-coordinate of the window's position in the specified display.
     */
    ?x: Int,
    /**
     * The y-coordinate of the window's position in the specified display.
     */
    ?y: Int
  };

  var ?modules: {
    /**
     * Enable the audio module.
     */
    ?audio: Bool,
    /**
     * Enable the data module.
     */
    ?data: Bool,
    /**
     * Enable the event module.
     */
    ?event: Bool,
    /**
     * Enable the font module.
     */
    ?font: Bool,
    /**
     * Enable the graphics module.
     */
    ?graphics: Bool,
    /**
     * Enable the image module.
     */
    ?image: Bool,
    /**
     * Enable the joystick module.
     */
    ?joystick: Bool,
    /**
     * Enable the keyboard module.
     */
    ?keyboard: Bool,
    /**
     * Enable the math module.
     */
    ?math: Bool,
    /**
     * Enable the mouse module.
     */
    ?mouse: Bool,
    /**
     * Enable the physics module.
     */
    ?physics: Bool,
    /**
     * Enable the sound module.
     */
    ?sound: Bool,
    /**
     * Enable the system module.
     */
    ?system: Bool,
    /**
     * Enable the thread module.
     */
    ?thread: Bool,
    /**
     * Enable the timer module.
     */
    ?timer: Bool,
    /**
     * Enable the touch module.
     */
    ?touch: Bool,
    /**
     * Enable the video module.
     */
    ?video: Bool,
    /**
     * Enable the window module.
     */
    ?window: Bool
  };
}

/**
 * Configuration for a Square2 project.
 */
typedef Config = {
  /**
   * The haxe source locations.
   */
  var sources: Array<String>;

  /**
   * The main entry point of the project.
   */
  var main: String;

  /**
   * The title of the window.
   */
  var ?title: String;

  /**
   * The width of the window in pixels.
   */
  var ?windowWidth: Int;

  /**
   * The height of the window in pixels.
   */
  var ?windowHeight: Int;

  /**
   * Enable high-dpi mode for the window on a Retina display.
   */
  var ?highdpi: Bool;

  /**
   * Start the application in fullscreen mode.
   */
  var ?fullscreen: Bool;

  /**
   * The export directory for the compiled project.
   */
  var ?exportPath: String;

  /**
   * The assets directory to copy to the export folder.
   */
  var ?assetsPath: String;

  /**
   * Libraries other than Nura to include in the project.
   */
  var ?libraries: Array<Library>;

  /**
   * Defines to pass to the Haxe compiler.
   */
  var ?defines: Array<String>;

  /**
   * Parameters to pass to the Haxe compiler.
   */
  var ?parameters: Array<String>;

  /**
   * Whether to enable debug mode.
   * This will include debug information in the compiled output.
   * If not set, it defaults to false.
   */
  var ?debug: Bool;

  /**
   * Options specific to the web platform.
   */
  var ?webOptions: WebOptions;

  /**
   * Options specific to the Love2D platform.
   */
  var ?love2dOptions: Love2dOptions;

  /**
   * The export target. This gets set automatically based on the selected platform.
   */
  var ?target: ExportTarget;
}

/**
 * Validate required fields in the config.
 * Throws an error if any required field is missing.
 * @param config The configuration object.
 */
function validateConfig(config: Config) {
  Sys.println('Validating config...');
  if (config.sources == null || config.sources.length == 0) {
    throwMissingField('sources');
  }
  if (config.main == null || config.main == '') {
    throwMissingField('main');
  }

  config.assetsPath ??= 'assets';
  config.exportPath ??= 'export';
  config.debug ??= false;
}

function throwMissingField(field: String, configType = 'config'): Void {
  throw 'Missing field "${field}" in ${configType}';
}
