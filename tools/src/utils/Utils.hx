package tools.src.utils;

import haxe.Json;
import haxe.io.Path;

import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

import tools.src.utils.Config.validateConfig;

using StringTools;

/**
 * Get the path to the config. Will also check for the '--config' flag to load a config file from a user defined path.
 * @param workingDir The current working directory.
 * @param args The command line arguments.
 * @return The path to the config.
 */
function getConfigPath(workingDir: String, args: Array<String>): String {
  var configPath = Path.join([workingDir, 'nyro.json']);
  if (args.contains('--config')) {
    final index = args.indexOf('--config');
    if (args.length > index + 1) {
      final path = args[index + 1];
      configPath = Path.join([workingDir, path]);
    }
  }

  return configPath;
}

/**
 * Read the toml config file.
 * @param path The path to the config.
 * @return The Config or null if the file is not found.
 */
function readConfig(path: String): Config {
  if (FileSystem.exists(path)) {
    final content = File.getContent(path);
    final config: Config = Json.parse(content);

    validateConfig(config);

    return config;
  }

  Sys.println('No config file found at ${path}.');
  Sys.exit(1);

  return null;
}

/**
 * Recursive copy a directory.
 * @param source The source directory to copy.
 * @param destination The destination directory to copy to.
 */
function copyDir(source: String, destination: String) {
  final files = FileSystem.readDirectory(source);
  for (file in files) {
    final sourcePath = Path.join([source, file]);
    final destinationPath = Path.join([destination, file]);
    if (FileSystem.isDirectory(sourcePath)) {
      FileSystem.createDirectory(destinationPath);
      copyDir(sourcePath, destinationPath);
    } else {
      File.copy(sourcePath, destinationPath);
    }
  }
}

/**
 * Recursive delete a directory.
 * @param dir The directory to delete.
 */
function deleteDir(dir: String) {
  final files = FileSystem.readDirectory(dir);
  for (file in files) {
    final filePath = Path.join([dir, file]);
    if (FileSystem.isDirectory(filePath)) {
      deleteDir(filePath);
    } else {
      FileSystem.deleteFile(filePath);
    }
  }
  FileSystem.deleteDirectory(dir);
}

/**
 * Find the location of a haxelib library class path.
 * @param name The library to find.
 * @return The location path.
 */
function getHaxelibPath(name: String): String {
  final proc = new Process('haxelib', ['path', name]);
  var result = '';

  try {
    var previous = '';
    while (true) {
      final line = proc.stdout.readLine();
      if (line.startsWith('-D $name')) {
        result = previous;
        break;
      }
      previous = line;
    }
  } catch (e:Dynamic) {}

  proc.close();

  return result;
}

/**
 * Get the haxelib version.
 * @return String
 */
function getVersion(): String {
  try {
    final libPath = getHaxelibPath('nyro');
    final haxelib = Path.join([libPath, '../haxelib.json']);
    final json = Json.parse(File.getContent(haxelib));

    return json.version;
  } catch (err) {
    return '0.0.0';
  }
}

/**
 * Run a Sys command and restore the working directory after.
 * @param path The path to run the command in.
 * @param command The command to run.
 * @param args A list of command parameters.
 * @param throwErrors Show this throw errors.
 * @return The command status. 0 is success.
 */
function runCommand(path: String, command: String, args: Array<String>, throwErrors = true): Int {
  var currentPath = '';
  if (path != null && path != '') {
    currentPath = Sys.getCwd();

    try {
      Sys.setCwd(path);
    } catch (e:Dynamic) {
      Sys.println('Cannot set current working directory to ${path}.');
    }
  }

  var result = Sys.command(command, args);
  if (currentPath != '') {
    Sys.setCwd(currentPath);
  }

  if (result != 0 && throwErrors) {
    Sys.exit(1);
  }

  return result;
}
