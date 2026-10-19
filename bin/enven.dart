import 'dart:io';

import 'package:enven/src/generator/enven_generator.dart';
import 'package:enven/src/model/file.dart';
import 'package:enven/src/parser/env_parser.dart';
import 'package:enven/src/util/args_parser.dart';
import 'package:enven/src/util/file_utils.dart';

void main(List<String> args) {
  final parsedArgs = parseArgs(args);

  final result = EnvParser().readFileSystem(
    envFiles: parsedArgs['env-files']?.split(','),
  );
  printCandidates(result.candidates);

  // CLI --class-name takes precedence over #enven:class annotation
  final classNameOverride = parsedArgs['class-name'];
  final envFile = classNameOverride != null
      ? result.parsedFile.copyWith(
          config: result.parsedFile.config.copyWith(
            className: classNameOverride,
          ),
        )
      : result.parsedFile;

  final outputContent = EnvenGenerator().generate(envFile);

  // Create file and missing folders
  final outputPath = envFile.config.output ?? EnvenConfig.defaultOutput;
  FileUtils.createMissingFolders(filePath: outputPath);
  File(outputPath).writeAsStringSync(outputContent);

  print('Generated: $outputPath');
}

void printCandidates(List<String> candidates) {
  print(
    'Input: ${candidates.join(' < ')}${candidates.length > 1 ? ' (A overridden by B)' : ''}',
  );
}
