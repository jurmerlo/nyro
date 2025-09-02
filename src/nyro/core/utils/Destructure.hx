package nyro.core.utils;

import haxe.macro.Expr;

/**
 * Destructure an object into multiple variables.
 * 
 * You can use existing variables with the field name or use `var` to create new variables.  
 * Example:  
 * ```haxe
 * var obj = { x: 10, y: 20 };
 * obj.destructure(var x, var y);
 * trace(x); // 10
 * trace(y); // 20
 * 
 * // You can also use existing variables:
 * var x = 0;
 * var y = 0;
 * obj.destructure(x, y);
 * trace(x); // 10
 * trace(y); // 20
 * ``` 
 * @param input The object to destructure.
 * @param exprs The variables to assign the destructured values to.
 */
macro function destructure(input: Expr, exprs: Array<Expr>) {
  return nyro.core.utils.CoreMacros.destructureMacro(input, exprs);
}
