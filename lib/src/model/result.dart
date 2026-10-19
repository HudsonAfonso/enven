import 'package:enven/src/model/file.dart';

class EnvResult {
  /// The list of .env file candidates.
  /// From lowest to highest priority.
  final List<String> candidates;

  /// The parsed .env file.
  final EnvFile parsedFile;

  EnvResult({
    required this.candidates,
    required this.parsedFile,
  });
}
