import 'dart:developer';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';
import 'package:sup_gen_model/extensions/string_extension.dart';

/// A function that will append the word 'Value' to a name that is a protected
/// keyword in Dart.
/// For example, if the name is 'class', it will return 'classValue'.
String _appendValue(String name) {
  if (name == 'class' ||
      name == 'abstract' ||
      name == 'dynamic' ||
      name == 'enum' ||
      name == 'final' ||
      name == 'native' ||
      name == 'typedef' ||
      name == 'void' ||
      name == 'var' ||
      name == 'void' ||
      name == 'async' ||
      name == 'await' ||
      name == 'yield' ||
      name == 'deferred' ||
      name == 'external' ||
      name == 'factory' ||
      name == 'implements' ||
      name == 'interface' ||
      name == 'is' ||
      name == 'mixin' ||
      name == 'operator' ||
      name == 'part' ||
      name == 'static' ||
      name == 'this' ||
      name == 'typedef' ||
      name == 'yield' ||
      name == 'abstract' ||
      name == 'assert' ||
      name == 'break' ||
      name == 'case' ||
      name == 'catch' ||
      name == 'class' ||
      name == 'const' ||
      name == 'continue' ||
      name == 'default' ||
      name == 'do' ||
      name == 'else' ||
      name == 'enum' ||
      name == 'extends' ||
      name == 'false' ||
      name == 'final' ||
      name == 'bool') {
    return '${name}Value';
  }

  return name;
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TableModel {
  final String name;
  final List<TableProperty> properties;
  TableModel({required this.name, required this.properties});

  bool get hasValidName => isValidDartClassName(name);
  String get className => snakeToPascalCase(name);

  String get fromJsonFunction {
    final buffer = StringBuffer();
    buffer.writeln("factory $className.fromJson(Map<String, dynamic> json) {");
    buffer.writeln("return $className(");
    for (var element in properties) {
      if (element.type == 'json' || element.type == 'jsonb') {
        final command = '''
jsonDecode(json['${element.name}'].toString()) as Map<String, dynamic>
''';
        buffer.writeln(
            "${element.dartName}: json['${element.name}'] != null ? $command: null,");
      } else {
        buffer.writeln("${element.dartName}: json['${element.name}'],");
      }
    }
    buffer.writeln(");");
    buffer.writeln("}");
    return buffer.toString();
  }

  String createClass() {
    final buffer = StringBuffer();
    // buffer.writeln('// ignore_for_file: camel_case_types');
    // buffer.writeln("import 'supabase_enums.gen.dart'; \n");
    // for (var table in tableList) {
    if (hasValidName) {
      buffer.writeln('class $className {');

      // Generate constructors
      buffer.writeln('  $className({');
      for (final prop in properties) {
        buffer.writeln(
            ' ${prop.isNullable ? "" : "required"}   this.${_appendValue(prop.dartName)},');
      }
      buffer.writeln('});');

      // Genereate properties
      for (final prop in properties) {
        buffer.writeln(prop.field);
      }

      buffer.writeln(fromJsonFunction);
      buffer.writeln('}');
      buffer.writeCharCode("\n".codeUnitAt(0));
    }
    return buffer.toString();
  }

//   factory TableModel.fromJson(Map<String, dynamic> json) {
// return TableModel(
// id: json['id'],
// name: json['name'],
// );
// }

  // Map<String, dynamic> toJson(dynamic data) {
  //   final mapped = jsonDecode(data.toString()) as Map<String, dynamic>;
  //   return mapped;
  // }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TableProperty {
  final String name;
  final String type;
  final bool isNullable;
  final bool isPrimaryKey;
  final bool isAutoIncrement;

  TableProperty({
    required this.name,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
    required this.isAutoIncrement,
  });

  String get dartName => snakeToCamelCase(name);
  String get dartType => _dartType;
  String get _dartType {
    switch (type) {
      case 'integer' ||
            'int4' ||
            'int' ||
            'int2' ||
            'int8' ||
            'bigint' ||
            'smallint' ||
            'serial' ||
            'bigserial':
        return 'int';

      case 'numeric' || 'float' || 'float8' || 'float4' || 'real':
        return 'num';
      case 'boolean' || 'bool':
        return 'bool';
      case '_numeric':
        return 'List<num>';
      case '_text':
        return 'List<String>';
      case 'text' ||
            'uuid' ||
            'character varying' ||
            'varchar' ||
            'timestamp' ||
            'timestamptz' ||
            'date' ||
            'tsvector' ||
            '_uuid' ||
            '_varchar' ||
            'geometry':
        return 'String';
      case 'json':
        return 'Map<String, dynamic>';
      case 'jsonb':
        return 'Map<String, dynamic>';
      default:
        log(type);
        stdout.writeln('Unknown type: $type');
        return snakeToPascalCase(type);
    }
  }

  String get field {
    return "final ${_appendValue(dartType)}${isNullable ? "?" : ""} ${_appendValue(dartName)};";
  }
}

// class EnumModel {
//   final String name;
//   final List<String> values;
//   EnumModel({required this.name, required this.values});

//   String get namePascalCase {
//     final pascalCase =
//         snakeToPascalCase(name.replaceAll('"', '').replaceAll(" ", "_"));
//     return pascalCase[0].toUpperCase() + pascalCase.substring(1);
//   }

//   List<String> get dartValues => values.map((e) {
//         final pascalCase =
//             snakeToPascalCase(e.replaceAll('"', '').replaceAll(" ", "_"));
//         final result = pascalCase[0].toUpperCase() + pascalCase.substring(1);
//         return result;
//       }).toList();
// }
