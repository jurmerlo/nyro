import haxe.Timer;
import haxe.io.Path;

import tools.src.utils.Commands.buildHelp;
import tools.src.utils.Commands.cleanExportPath;
import tools.src.utils.Commands.copyAssets;
import tools.src.utils.Commands.export;
import tools.src.utils.Commands.generateAtlas;
import tools.src.utils.Commands.help;
import tools.src.utils.Commands.setupAlias;
import tools.src.utils.Config.ExportTarget;
import tools.src.utils.Utils.getConfigPath;
import tools.src.utils.Utils.getVersion;
import tools.src.utils.Utils.readConfig;

class Run {
  public static function main() {
    final args = Sys.args();
    final workingDir = args.pop();
    Sys.setCwd(workingDir);
    run(workingDir, args);
  }

  static function run(workingDir: String, args: Array<String>) {
    if (args.length >= 2 && args[0] == 'export') {
      args.shift();

      if (args.contains('--help')) {
        buildHelp();
        Sys.exit(0);
      }

      final target: ExportTarget = args.shift();
      if (target != ExportTarget.Love2D && target != ExportTarget.Web) {
        throw 'Unknown target: ${target}';
      }

      Sys.println('Exporting Nyro project for ${target}...');
      final configPath = getConfigPath(workingDir, args);
      final config = readConfig(configPath);
      config.target = target;

      final clean = args.contains('--clean');
      final debug = args.contains('--debug') || config.debug;

      final codeOnly = args.contains('--code-only');
      final noAtlas = args.contains('--no-atlas') || codeOnly;
      final noAssets = args.contains('--no-assets') || codeOnly;

      config.exportPath = Path.join([config.exportPath, config.target]);

      export(config, {
        clean: clean,
        debug: debug,
        noAtlas: noAtlas,
        noAssets: noAssets
      }, Timer.stamp());

      Sys.exit(0);
    } else if (args.length == 2 && args[0] == 'atlas') {
      generateAtlas(args[1]);
      Sys.exit(0);
    } else if (args.length == 1) {
      switch (args[0]) {
        case 'help':
          help();
          Sys.exit(0);

        case 'setup':
          setupAlias(false);
          Sys.exit(0);

        case 'local-setup':
          setupAlias(true);
          Sys.exit(0);

        case 'alias':
          setupAlias(false);
          Sys.exit(0);

        case 'local-alias':
          setupAlias(true);
          Sys.exit(0);

        case 'atlas':
          generateAtlas();
          Sys.exit(0);

        case 'assets':
          generateAtlas();
          final configPath = getConfigPath(workingDir, args);
          final config = readConfig(configPath);

          copyAssets(config);
          Sys.exit(0);

        case 'clean':
          final configPath = getConfigPath(workingDir, args);
          final config = readConfig(configPath);

          cleanExportPath(config.exportPath);
          Sys.exit(0);
      }
    }

    Sys.println('Nyro CLI.');
    Sys.println('version ${getVersion()}.');
    Sys.println('Use \'nura help\' for a list of commands.');
    Sys.exit(0);
  }
}
