CAMBIOS REALIZADOS:

- La ruta de las librerías se encierran entre <> (ej: #add <c3p.base>)
- El token MAIN se ha eliminado porque tiene la misma sintaxis que los procedimientos
- El token ARITHMETIC_OPERAND, COMPARE_OPERAND, LOGIC_OPERAND, y MAIN se han eliminado
- Se ha añadido el token T y F para las constantes booleanas
- Se han añadido los tokens AND, OR, EQUAL, NOTEQUAL, LESSEQUAL, MOREEQUAL, EOL
- Para las constantes, se ha añadido en Flex una asignación yylval.<tipo_dato> = <valor>
- En Flex se retorna el token EOL cuando se encuentran saltos de línea
- Se ha añadido Flex los casos para AND, OR, EQUAL, NOTEQUAL, LESSEQUAL, MOREEQUAL, EOL
- Se ha añadido el retorno de T y F en Flex
- Se ha eliminado en Flex el caso para el token MAIN
- Se han eliminado los contenedores bidimensionales

ADVERTENCIAS:

 En Bison no se han considerado los identificadores en la asignación y declaración de
 expresiones, porque sin el analizador semántico y la tabla de símbolos no se puede
 conocer el tipo de dato y el valor que se le ha asignado. Ahora bien, la implementación
 en Bison sí que define expresiones cuando los operandos son constantes.

 Otra cuestión a tener en cuenta es que el cuerpo de las reglas se ha especificado sólo
 para las expresiones, porque en el resto de casos se necesita de la tabla de símbolos.