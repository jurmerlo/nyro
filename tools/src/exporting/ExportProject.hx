package tools.src.exporting;

import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Writer;

import sys.FileSystem;
import sys.io.File;

import tools.src.utils.Config;
import tools.src.utils.Utils.getHaxelibPath;
import tools.src.utils.Utils.runCommand;

using StringTools;

/**
 * Export the project.
 * @param config The nyro configuration.
 * @param pack Whether to pack the build into a .love file if the target is love2d.
 */
function exportProject(config: Config, pack: Bool) {
  generateHxml(config);
  if (config.target == ExportTarget.Love2D) {
    exportLove2d(config, pack);
  } else if (config.target == ExportTarget.Web) {
    exportWeb(config);
  }
}

/**
 * Export the love2d build.
 * @param config The nyro configuration.
 * @param pack Whether to pack the build into a .love file.
 */
private function exportLove2d(config: Config, pack: Bool) {
  runCommand('', 'haxe', ['hxml/love2d.hxml']);
  createLove2dConfig(config);

  if (pack) {
    packLove2d(config);
  }
}

/**
 * Export the web build.
 * @param config The nyro configuration.
 */
private function exportWeb(config: Config) {
  runCommand('', 'haxe', ['hxml/web.hxml']);
  copyTemplate(config);
}

/**
 * Generate the haxe build file from the config file.
 * @param config The project configuration.
 */
private function generateHxml(config: Config) {
  Sys.println('Generating hxml config...');
  var fileData = '';
  var foundNyro = false;

  if (config.target == ExportTarget.Love2D) {
    fileData += '-L love2d-hx\n';
  }

  if (config.libraries != null) {
    for (lib in config.libraries) {
      if (lib.name == 'nyro') {
        foundNyro = true;
      }

      if (lib.version != null) {
        fileData += '-L ${lib.name}:${lib.version}\n';
      } else {
        fileData += '-L ${lib}\n';
      }
    }
  }

  if (!foundNyro) {
    fileData = '-L nyro\n' + fileData;
  }

  for (source in config.sources) {
    if (FileSystem.exists(source)) {
      fileData += '-cp ${source}\n';
    } else {
      Sys.println('Source folder "${source}" not found. Not adding it to the hxml.');
    }
  }

  fileData += '\n';
  if (config.defines != null) {
    for (define in config.defines) {
      fileData += '-D ${define}\n';
    }
    fileData += '\n';
  }

  var filename = '';
  if (config.target == ExportTarget.Web) {
    fileData += '-D web\n';
    filename = 'web.hxml';
  } else if (config.target == ExportTarget.Love2D) {
    fileData += '-D lua-vanilla\n';
    fileData += '-D luajit\n';
    fileData += '-D love2d\n';
    filename = 'love2d.hxml';
  }

  if (config.parameters != null) {
    for (parameter in config.parameters) {
      fileData += '${parameter}\n';
    }
    fileData += '\n';
  }

  if (config.debug) {
    fileData += '--debug\n';
    fileData += '\n';
  }

  if (config.target == ExportTarget.Web) {
    final scriptName = config.webOptions?.scriptName ?? 'nyro.js';
    fileData += '-js ${Path.join([config.exportPath, scriptName])}\n';
  } else if (config.target == ExportTarget.Love2D) {
    fileData += '-lua ${Path.join([config.exportPath, 'main.lua'])}\n';
  }

  fileData += '\n';
  fileData += '-main ${config.main}\n';

  if (!FileSystem.exists('hxml')) {
    FileSystem.createDirectory('hxml');
  }

  File.saveContent(Path.join([Sys.getCwd(), 'hxml/${filename}']), fileData);
}

/**
 * Copy the starter template and fill the placeholders.
 * @param config The project configuration.
 */
private function copyTemplate(config: Config) {
  Sys.println('Copying html template...');
  var templatePath: String;
  if (config.webOptions?.htmlIndexPath != null) {
    templatePath = config.webOptions.htmlIndexPath;
  } else {
    final nyroPath = getHaxelibPath('nyro');
    templatePath = Path.join([nyroPath, '../tools/data/html/index.html']);
  }
  var template = File.getContent(templatePath);

  var canvasId = 'nyro';
  if (config.webOptions?.canvasId != null) {
    canvasId = config.webOptions.canvasId;
  }
  template = template.replace('{{canvasId}}', canvasId);
  File.saveContent(Path.join([config.exportPath, 'index.html']), template);
}

/**
 * Create the love2d `conf.lua` configuration file.
 * @param config The nyro configuration.
 */
private function createLove2dConfig(config: Config) {
  Sys.println('Creating love2d config...');
  var fileData = 'function love.conf(t)\n';
  fileData += '  t.window.title = "${config.title}"\n';
  fileData += '  t.window.width = ${config.windowWidth}\n';
  fileData += '  t.window.height = ${config.windowHeight}\n';
  fileData += '  t.window.highdpi = ${config.highdpi ?? false}\n';
  fileData += '  t.window.fullscreen = ${config.fullscreen ?? false}\n';

  if (config.love2dOptions != null) {
    var options = config.love2dOptions;
    if (options.identity != null) {
      fileData += '  t.identity = "${options.identity}"\n';
    }

    if (options.version != null) {
      fileData += '  t.version = "${options.version}"\n';
    }

    if (options.console != null) {
      fileData += '  t.console = ${options.console}\n';
    }

    if (options.accelerometerjoystick != null) {
      fileData += '  t.accelerometerjoystick = ${options.accelerometerjoystick}\n';
    }

    if (options.externalstorage != null) {
      fileData += '  t.externalstorage = ${options.externalstorage}\n';
    }

    if (options.gammacorrect != null) {
      fileData += '  t.gammacorrect = ${options.gammacorrect}\n';
    }

    if (options.audio != null) {
      fileData += '  \n';
      if (options.audio.mic != null) {
        fileData += '  t.audio.mic = ${options.audio.mic},\n';
      }
      if (options.audio.mixwithsystem != null) {
        fileData += '  t.audio.mixwithsystem = ${options.audio.mixwithsystem},\n';
      }
    }

    if (options.window != null) {
      fileData += '  \n';
      if (options.window.icon != null) {
        fileData += '  t.window.icon = "${options.window.icon}",\n';
      }
      if (options.window.borderless != null) {
        fileData += '  t.window.borderless = ${options.window.borderless},\n';
      }
      if (options.window.resizable != null) {
        fileData += '  t.window.resizable = ${options.window.resizable},\n';
      }
      if (options.window.minwidth != null) {
        fileData += '  t.window.minwidth = ${options.window.minwidth},\n';
      }
      if (options.window.minheight != null) {
        fileData += '  t.window.minheight = ${options.window.minheight},\n';
      }
      if (options.window.fullscreentype != null) {
        fileData += '  t.window.fullscreentype = "${options.window.fullscreentype}",\n';
      }
      if (options.window.vsync != null) {
        fileData += '  t.window.vsync = ${options.window.vsync},\n';
      }
      if (options.window.msaa != null) {
        fileData += '  t.window.msaa = ${options.window.msaa},\n';
      }
      if (options.window.depth != null) {
        fileData += '  t.window.depth = ${options.window.depth},\n';
      }
      if (options.window.stencil != null) {
        fileData += '  t.window.stencil = ${options.window.stencil},\n';
      }
      if (options.window.display != null) {
        fileData += '  t.window.display = ${options.window.display},\n';
      }
      if (options.window.x != null) {
        fileData += '  t.window.x = ${options.window.x},\n';
      }
      if (options.window.y != null) {
        fileData += '  t.window.y = ${options.window.y},\n';
      }
    }

    if (options.modules != null) {
      fileData += '  \n';
      if (options.modules.audio != null) {
        fileData += '  t.modules.audio = ${options.modules.audio},\n';
      }
      if (options.modules.data != null) {
        fileData += '  t.modules.data = ${options.modules.data},\n';
      }
      if (options.modules.event != null) {
        fileData += '  t.modules.event = ${options.modules.event},\n';
      }
      if (options.modules.font != null) {
        fileData += '  t.modules.font = ${options.modules.font},\n';
      }
      if (options.modules.graphics != null) {
        fileData += '  t.modules.graphics = ${options.modules.graphics},\n';
      }
      if (options.modules.image != null) {
        fileData += '  t.modules.image = ${options.modules.image},\n';
      }
      if (options.modules.joystick != null) {
        fileData += '  t.modules.joystick = ${options.modules.joystick},\n';
      }
      if (options.modules.keyboard != null) {
        fileData += '  t.modules.keyboard = ${options.modules.keyboard},\n';
      }
      if (options.modules.math != null) {
        fileData += '  t.modules.math = ${options.modules.math},\n';
      }
      if (options.modules.mouse != null) {
        fileData += '  t.modules.mouse = ${options.modules.mouse},\n';
      }
      if (options.modules.physics != null) {
        fileData += '  t.modules.physics = ${options.modules.physics},\n';
      }
      if (options.modules.sound != null) {
        fileData += '  t.modules.sound = ${options.modules.sound},\n';
      }
      if (options.modules.system != null) {
        fileData += '  t.modules.system = ${options.modules.system},\n';
      }
      if (options.modules.thread != null) {
        fileData += '  t.modules.thread = ${options.modules.thread},\n';
      }
      if (options.modules.timer != null) {
        fileData += '  t.modules.timer = ${options.modules.timer},\n';
      }
      if (options.modules.touch != null) {
        fileData += '  t.modules.touch = ${options.modules.touch},\n';
      }
      if (options.modules.video != null) {
        fileData += '  t.modules.video = ${options.modules.video},\n';
      }
      if (options.modules.window != null) {
        fileData += '  t.modules.window = ${options.modules.window},\n';
      }
    }
  }
  fileData += 'end\n';

  File.saveContent(Path.join([config.exportPath, 'conf.lua']), fileData);
}

/**
 * Pack the export directory into a .love file.
 * @param config The nyro configuration.
 */
private function packLove2d(config: Config) {
  Sys.println('Packing Love2D project...');
  final zipEntries = getFilesToZip(config.exportPath);
  for (entry in zipEntries) {
    Sys.println(' - ' + entry.fileName);
  }
  final file = File.write(Path.join([config.exportPath, '${config.title}.love']));
  final zip = new Writer(file);
  zip.write(zipEntries);
  file.close();
}

/**
 * Get all files in a directory and its subdirectories to be zipped.
 * @param dir The directory to search.
 * @param entries The list of entries to populate.
 * @param parentDir The directory to use as the base for relative paths.
 */
private function getFilesToZip(dir: String, ?entries: List<Entry>, ?parentDir: String) {
  if (entries == null) {
    entries = new List<Entry>();
  }

  if (parentDir == null) {
    parentDir = Path.addTrailingSlash(dir);
  }

  for (file in FileSystem.readDirectory(dir)) {
    final path = Path.join([dir, file]);
    if (FileSystem.isDirectory(path)) {
      getFilesToZip(path, entries, parentDir);
      FileSystem.deleteDirectory(path);
    } else {
      if (path.contains('.DS_Store') || path.contains('Thumbs.db') || path.endsWith('.love')) {
        FileSystem.deleteFile(path);
        continue;
      }

      final bytes: Bytes = Bytes.ofData(File.getBytes(path).getData());
      final entry: Entry = {
        fileName: path.replace(parentDir, ''),
        fileSize: bytes.length,
        fileTime: Date.now(),
        compressed: false,
        dataSize: FileSystem.stat(path).size,
        data: bytes,
        crc32: Crc32.make(bytes)
      };
      entries.push(entry);
      FileSystem.deleteFile(path);
    }
  }
  return entries;
}
