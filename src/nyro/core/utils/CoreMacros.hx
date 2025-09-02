package nyro.core.utils;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using haxe.macro.PositionTools;
using haxe.macro.Tools;
using haxe.macro.TypeTools;

/**
 * Add the @:inject metadata for autocomplete.
 */
function init() {
  Compiler.registerCustomMetadata({
    metadata: ':inject',
    doc: 'Inject the service of this type.',
    targets: [ClassField],
    platforms: [Js]
  }, 'nyro');
}

/**
 * Inject a service into a field.
 * @return The updated fields.
 */
function inject(): Array<Field> {
  // Get all the fields in the event class.
  final fields = Context.getBuildFields();

  final getters: Array<Field> = [];

  for (field in fields) {
    // Only inject fields that have `@:inject` metadata.
    if (!hasMetadata(field, ':inject')) {
      continue;
    }

    try {
      switch (field.kind) {
        case FVar(fType, fExpr):
          if (fType == null) {
            continue;
          }

          final classType = fType.toType().getClass();
          final serviceType = Context.getType('nyro.core.di.Service').getClass();

          var implementsService = false;
          if (classType.interfaces != null) {
            for (interfaceRef in classType.interfaces) {
              if (interfaceRef.t.get().name == serviceType.name) {
                implementsService = true;
                break;
              }
            }

            // Make sure the class to inject implements `Service`.
            if (implementsService) {
              final path = classType.pack.concat([classType.name]);
              final getterFunc: Function = {
                expr: macro return nyro.core.di.Services.get($p{path}),
                ret: fType,
                args: []
              };

              field.kind = FProp('get', 'never', getterFunc.ret);

              final getter: Field = {
                name: 'get_${field.name}',
                access: [APrivate, AInline],
                kind: FFun(getterFunc),
                pos: Context.currentPos()
              };
              getters.push(getter);
            }
          }

        default:
      }
    } catch (e) {
      #if debug
      trace('Error processing field ${field.name}: ${e}');
      #end
    }
  }

  for (getter in getters) {
    fields.push(getter);
  }

  return fields;
}

/**
 * Destructure an object into multiple variables.
 * Based on https://github.com/SomeRanDev/Haxe-ExtraFeatures unpack function.
 * @param input The object to destructure.
 * @param exprs The expressions to extract from the object.
 */
function destructureMacro(input: Expr, exprs: Array<Expr>) {
  final pos = Context.currentPos();
  final assignmentNames = [];
  final declaredVariables = [];
  final namePositions: Map<String, Position> = [];

  var index = 1;
  for (expr in exprs) {
    switch (expr.expr) {
      // New variables.
      case EVars(vars):
        declaredVariables.push({
          expr: EVars(vars.map(v -> {
            // Add the assignment expression for the variable so it looks something like: `var x = input.x;`.
            final n = v.name;
            v.expr = macro $input.$n;
            v;
          })),
          pos: expr.pos,
        });

      // Existing variables.
      case EConst(c):
        switch (c) {
          case CIdent(s):
            if (!assignmentNames.contains(s)) {
              assignmentNames.push(s);
            } else {
              Context.error('Multiple instances of \'${s}\' are attempting to be unpacked', pos);
            }
            namePositions[s] = expr.pos;

          case _:
            Context.error('Unpack parameter #$index \'${expr.toString()}\' is not a valid identifier', expr.pos);
        }

      case _:
        Context.error('Unpack parameter #$index \'${expr.toString()}\' is neither an EVars or EConst(CIdent)',
          expr.pos);
    }
    index++;
  }

  final resultExprs = [];

  // Create the new variables.
  for (declared in declaredVariables) {
    resultExprs.push(macro @:pos(pos) $declared);
  }

  // Create the assignment expressions for the existing variables.
  for (name in assignmentNames) {
    // do not explicitly check for field's existence since Haxe will print robust error.
    final exprPos = namePositions[name];
    resultExprs.push(macro @:pos(exprPos) $i{name} = $input.$name);
  }

  return macro @:mergeBlock $b{resultExprs};
}

/**
 * Build the core configuration options from the nyro config file.
 * @return The class fields.
 */
function buildCoreConfig(): Array<Field> {
  final fields = Context.getBuildFields();

  #if !display
  // We assume that this is run from within a hxml folder and the nyro.json config is
  // one folder up in the root of the project.
  final path = haxe.io.Path.join([Sys.getCwd(), '../nyro.json']);

  var options: nyro.core.CoreOptions = {
    width: 800,
    height: 600,
    targetFps: -1,
    hdpi: false,
    fullscreen: false,
    title: 'Nyro Game'
  };

  if (sys.FileSystem.exists(path)) {
    final content = sys.io.File.getContent(path);

    // This data will have more fields than just the CoreOptions.
    final data = haxe.Json.parse(content);

    // Add only the relevant options so we assign the correct data.
    options = {
      width: data.windowWidth,
      height: data.windowHeight,
      targetFps: data.targetFps ?? -1,
      hdpi: data.highdpi ?? false,
      fullscreen: data.fullscreen ?? false,
      title: data.title ?? 'Nyro Game'
    };
  }

  // Find the options variable and update the value.
  for (field in fields) {
    if (field.name == 'options') {
      switch (field.kind) {
        case FVar(type, expr):
          field.kind = FVar(type, macro $v{options});

        default:
      }
    }
  }
  #end

  return fields;
}

/**
 * Check if a field has a specific metadata tag.
 * @param field The field to check.
 * @param tagName The name of the tag to look for without the '@' symbol.
 * @return Bool
 */
private function hasMetadata(field: Field, tagName: String): Bool {
  if (field.meta != null) {
    for (tag in field.meta) {
      if (tag.name == tagName) {
        return true;
      }
    }
  }

  return false;
}
#end
