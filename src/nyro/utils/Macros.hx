package nyro.utils;

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
    platforms: [Js, Lua]
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
          final serviceType = Context.getType('nyro.di.Service').getClass();

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
                expr: macro return nyro.di.Services.get($p{path}),
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
 * Build event classes by adding and object pool and functions to send and reset the event using the class fields.
 * @return The class fields.
 */
function buildEvent(): Array<Field> {
  final fields = Context.getBuildFields();

  final classType = Context.getLocalClass().get();
  final eventType = Context.getLocalType().toComplexType();

  final typePath = { name: classType.name, pack: classType.pack, params: [] };

  // Create an object pool for this event.
  fields.push({
    name: 'pool',
    access: [APrivate, AStatic],
    pos: Context.currentPos(),
    kind: FVar(macro : Array<$eventType>, macro [])
  });

  var putFunction: Field;

  for (field in fields) {
    switch (field.kind) {
      case FFun(func):
        if (field.name == 'put') {
          putFunction = field;
          break;
        }

      default:
    }
  }

  // Create the EventType<Event> parameter for this event.
  final typeParam: FunctionArg = {
    name: 'type',
    type: TPath({
      name: 'EventType',
      pack: ['nyro', 'events'],
      params: [TPType(eventType)]
    })
  };

  final paramFields: Array<FunctionArg> = [typeParam];

  for (field in fields) {
    switch (field.kind) {
      // Make all non-static variables of the event public readonly properties
      // and store them to use as parameters later.
      case FVar(fType, fExpr):
        if (!field.access.contains(AStatic)) {
          field.access = [APublic];
          field.kind = FProp('default', 'null', fType, fExpr);

          paramFields.push({ name: field.name, type: fType, value: fExpr });
        }

      // Add non-static public properties to the field parameters.
      case FProp(get, set, fType, fExpr):
        if (!field.access.contains(AStatic) && field.access.contains(APublic)) {
          paramFields.push({
            name: field.name,
            type: fType,
            value: fExpr
          });
        }

      default:
    }
  }

  final paramNames: Array<Expr> = [];
  final assignExprs: Array<Expr> = [];

  // Get all parameter names and assignments.
  for (param in paramFields) {
    final name = param.name;
    paramNames.push(macro $i{param.name});
    assignExprs.push(macro {this.$name = $i{name};});
  }

  // Create the reset function to reset all fields with new values.
  fields.push({
    name: 'reset',
    access: [APrivate],
    pos: Context.currentPos(),
    kind: FFun({
      args: paramFields,
      expr: macro $b{assignExprs}
    })
  });

  // Add a static get function to get an event from the pool.
  fields.push({
    name: 'get',
    access: [APublic, AStatic],
    pos: Context.currentPos(),
    kind: FFun({
      args: paramFields,
      expr: macro {
        var event: $eventType;
        if (pool.length > 0) {
          event = pool.pop();
        } else {
          event = new $typePath();
        }
        event.reset($a{paramNames});

        return event;
      },
      ret: eventType
    })
  });

  // Add a static send function that uses the object pool to recycle events.
  fields.push({
    name: 'send',
    access: [APublic, AStatic],
    pos: Context.currentPos(),
    kind: FFun({
      args: paramFields,
      expr: macro {
        var event: $eventType;
        if (pool.length > 0) {
          event = pool.pop();
        } else {
          event = new $typePath();
        }
        event.reset($a{paramNames});
        nyro.di.Services.get(nyro.events.Events).sendEvent(event);
      },
      ret: macro : Void
    })
  });

  // Create the put function to put the event back into the object pool.
  if (putFunction == null) {
    fields.push({
      name: 'put',
      pos: Context.currentPos(),
      access: [APublic, AOverride],
      kind: FFun({
        args: [],
        expr: macro {
          super.put();
          pool.push(this);
        }
      })
    });
  } else {
    switch (putFunction.kind) {
      case FFun(func):
        final expr = macro {pool.puh(this);};
        func.expr = macro $b{[func.expr, expr]};

      default:
    }
  }

  return fields;
}

/**
 * Build the nyro configuration options from the nyro config file.
 * @return The class fields.
 */
function buildNyroConfig(): Array<Field> {
  final fields = Context.getBuildFields();

  #if !display
  // We assume that this is run from within a hxml folder and the nyro.json config is
  // one folder up in the root of the project.
  final path = haxe.io.Path.join([Sys.getCwd(), '../nyro.json']);

  var options: nyro.NyroOptions = {
    width: 800,
    height: 600,
    targetFps: -1,
    hdpi: false,
    fullscreen: false,
    title: 'Nyro Game'
  };

  if (sys.FileSystem.exists(path)) {
    final content = sys.io.File.getContent(path);

    // This data will have more fields than just the NyroOptions.
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
