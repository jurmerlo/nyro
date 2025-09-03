package tools.src.utils;

import haxe.Exception;
import haxe.Timer;
import haxe.io.Path;

import sys.FileSystem;
import sys.io.File;

import tools.src.exporting.ExportProject.exportProject;
import tools.src.packer.Atlas;
import tools.src.packer.Tileset;
import tools.src.utils.Utils.copyDir;
import tools.src.utils.Utils.deleteDir;
import tools.src.utils.Utils.getHaxelibPath;

/**
 * Export options for the project.
 */
typedef ExportOptions = {
  /**
   * Whether to clean the export path before building.
   */
  var clean: Bool;

  /**
   * Whether to enable debug mode.
   */
  var debug: Bool;

  /**
   * Whether to disable atlas generation.
   */
  var noAtlas: Bool;

  /**
   * Whether to disable asset copying.
   */
  var noAssets: Bool;

  /**
   * Whether to pack the build into a .love file if the target is love2d.
   */
  var pack: Bool;
}

/**
 * Export the project.
 * @param config The nyro configuration.
 * @param options The export options.
 * @param exportStartTime The export start time.
 */
function export(config: Config, options: ExportOptions, exportStartTime: Float) {
  config.debug = options.debug;

  final exportPath = config.exportPath;
  if (options.clean) {
    cleanExportPath(exportPath);
  }

  if (!FileSystem.exists(exportPath)) {
    FileSystem.createDirectory(exportPath);
  }

  if (!options.noAssets) {
    copyAssets(config);
  }

  if (!options.noAssets && !options.noAtlas) {
    generateAtlas();
  }

  exportProject(config, options.pack);

  final buildTime = Timer.stamp() - exportStartTime;
  Sys.println('Export completed in ${Math.floor(buildTime * 100) / 100.0} seconds.');
}

/**
 * Clean the export path.
 * @param exportPath The path to the export directory.
 */
function cleanExportPath(exportPath: String) {
  Sys.println('Cleaning export path: ${exportPath}');
  deleteDir(exportPath);
}

/**
 * Copy the assets to the output folder.
 * @param config The project configuration.
 */
function copyAssets(config: Config) {
  if (FileSystem.exists(config.assetsPath)) {
    final output = Path.join([config.exportPath, config.assetsPath]);
    if (!FileSystem.exists(output)) {
      FileSystem.createDirectory(output);
    }
    copyDir(config.assetsPath, output);
    Sys.println('Copying asset folder...');
  } else {
    Sys.println('Asset folder ${config.assetsPath} not found.');
  }
}

/**
 * Generate a sprite atlas from the nyro.json config.
 * @param path The path to the nyro.json config file.
 */
function generateAtlas(?path: String) {
  if (path == null) {
    path = Path.join([Sys.getCwd(), 'nyro.json']);
  }

  if (FileSystem.exists(path)) {
    Atlas.fromJson(path);
    Tileset.fromJson(path);
  } else {
    Sys.println('No nyro.json file found. Cannot generate atlas.');
  }
}

/**
 * Install the 'nyro' command.
 * @return True if successful.
 */
function setupAlias(local: Bool): Bool {
  while (true) {
    Sys.println('');
    Sys.println('Do you want to install the "nyro" command? [y/n]?');

    switch (Sys.stdin().readLine()) {
      case 'n', 'No':
        return false;
      case 'y', 'Yes':
        break;

      default:
    }
  }

  final platform = Sys.systemName();
  var binPath = platform == 'Mac' ? '/usr/local/bin' : '/usr/bin';

  if (platform == 'Windows') {
    var haxePath = Sys.getEnv('HAXEPATH');
    if (haxePath == null || haxePath == '') {
      haxePath = 'C:\\HaxeToolkit\\haxe\\';
    }

    if (local) {
      haxePath = Sys.getCwd();
    }

    final destination = Path.join([haxePath, 'nyro.bat']);
    final source = Path.join([getHaxelibPath('nyro'), '../data/bin/nyro.bat']);

    if (FileSystem.exists(source)) {
      File.copy(source, destination);
    } else {
      throw new Exception('Could not find the nyro alias script.');
    }
  } else {
    if (local) {
      binPath = Sys.getCwd();
    }

    final source = Path.join([getHaxelibPath('nyro'), '../data/bin/nyro.sh']);
    if (FileSystem.exists(source)) {
      Sys.command('sudo', ['cp', source, binPath + '/nyro']);
      Sys.command('sudo', ['chmod', '+x', binPath + '/nyro']);
    } else {
      throw new Exception('Could not find the nyro alias script.');
    }
  }
  Sys.println('The "nyro" command has been added to the path.');

  return true;
}

function help() {
  Sys.println('');
  Sys.println('The following commands are available:');
  Sys.println('nyro setup                  Install the \'nyro\' command line command.');
  Sys.println('nyro create [project_name]  Create a starter project in the current directory.');
  Sys.println('nyro build [options]        Build the project. Use \'nyro build --help\' to see the options.');
  Sys.println('nyro atlas [config]         Generate just the sprite atlas. Can take an optional config file.');
  Sys.println('nyro assets                 Generate the sprite atlas and copy the assets to the output folder.');
  Sys.println('nyro clean                  Clean the output folder.');
  Sys.println('nyro help                   Show this list.');
}

function buildHelp() {
  Sys.println('');
  Sys.println('The following build options are available:');
  Sys.println('--debug       Create a debug build. Can also be set in the config file');
  Sys.println('--clean       Clean the output folder.');
  Sys.println('--no-atlas    Skip generating sprite atlases.');
  Sys.println('--no-assets   Skip copying the assets.');
  Sys.println('--code-only   Only compile the haxe code.');
  Sys.println('--pack        Create a .love package. Only for the Love2d target.');
}
