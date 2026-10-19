import 'package:enven/src/parser/env_parser.dart';

/// Represents a .env file.
class EnvFile {
  /// Global configuration specified in the .env file.
  final EnvenConfig config;

  /// All entries in the .env file.
  /// The key is the entry key which is the same as [EnvEntry.key].
  final Map<String, EnvEntry> entries;

  EnvFile({
    required this.config,
    required this.entries,
  });

  /// Merges this [EnvFile] with the given [fallback].
  EnvFile withFallback(EnvFile fallback, EnvParser parser) {
    final mergedEntries = <String, EnvEntry>{...fallback.entries};
    for (final entry in entries.entries) {
      if (mergedEntries.containsKey(entry.key)) {
        // fallback exists, merge annotations
        mergedEntries[entry.key] =
            entry.value.withFallback(mergedEntries[entry.key]!, parser);
      } else {
        // no fallback, just add
        mergedEntries[entry.key] = entry.value;
      }
    }
    return EnvFile(
      config: fallback.config.copyWith(
        output: config.output,
        seed: config.seed,
        className: config.className,
      ),
      entries: mergedEntries,
    );
  }

  EnvFile copyWith({
    EnvenConfig? config,
    Map<String, EnvEntry>? entries,
  }) {
    return EnvFile(
      config: config ?? this.config,
      entries: entries ?? this.entries,
    );
  }
}

/// Global configuration specified in a .env file.
class EnvenConfig {
  static const defaultOutput = 'lib/gen/env.g.dart';
  static const defaultClassName = 'Env';

  /// The output file path.
  final String? output;

  /// The seed used for obfuscation.
  /// If null, a random seed will be used.
  final String? seed;

  /// The class name for the generated code.
  /// If null, defaults to [defaultClassName].
  final String? className;

  EnvenConfig({
    required this.output,
    required this.seed,
    this.className,
  });

  EnvenConfig copyWith({
    String? output,
    String? seed,
    String? className,
  }) {
    return EnvenConfig(
      output: output ?? this.output,
      seed: seed ?? this.seed,
      className: className ?? this.className,
    );
  }
}

/// Represents a single entry in a .env file.
class EnvEntry {
  /// Annotations above this entry.
  /// Format: `#enven:<key>=<value>`
  /// If no value is specified, the value is assumed to be `true`.
  final Map<String, EnvEntryAnnotation> annotations;

  /// The key of this entry. ("key" in "key=value")
  final String key;

  /// The value of this entry. ("value" in "key=value")
  final Object? value;

  EnvEntry({
    required this.annotations,
    required this.key,
    required this.value,
  });

  /// Merges this [EnvEntry] with the given [fallback].
  /// We only merge annotations, not the key or value.
  EnvEntry withFallback(EnvEntry fallback, EnvParser parser) {
    final currentType = annotations.getTypeAnnotation();
    final fallbackType = fallback.annotations.getTypeAnnotation();
    Object? actualValue = value;
    if (currentType == null && fallbackType != null) {
      // no type annotation, but fallback has one
      // use fallback type
      actualValue = parser.valueParser.parseValue(
        value: value.toString(),
        type: fallbackType,
      );
    }
    return EnvEntry(
      annotations: {
        ...fallback.annotations,
        ...annotations,
      },
      key: key,
      value: actualValue,
    );
  }
}

/// Represents a single annotation for a .env entry.
class EnvEntryAnnotation {
  // File annotations
  static const output = 'output';
  static const seed = 'seed';
  static const className = 'class';

  // Entry annotations
  static const obfuscate = 'obfuscate';
  static const isConst = 'const';
  static const type = 'type';
  static const name = 'name';

  final String key;
  final Object value;

  EnvEntryAnnotation({
    required this.key,
    required this.value,
  });

  @override
  String toString() {
    return '$key=$value';
  }
}

extension AnnotationsExt on Map<String, EnvEntryAnnotation> {
  String? getTypeAnnotation() {
    return this[EnvEntryAnnotation.type]?.value as String?;
  }

  bool hasObfuscateAnnotation() {
    return this[EnvEntryAnnotation.obfuscate]?.value == true;
  }

  bool hasConstAnnotation() {
    return this[EnvEntryAnnotation.isConst]?.value == true;
  }
}
