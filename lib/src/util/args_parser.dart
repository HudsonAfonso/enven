/// Simple named argument parser.
/// Supports: `--key value` and `--key=value`
Map<String, String> parseArgs(List<String> args) {
  final result = <String, String>{};
  for (int i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg.startsWith('--')) {
      final equalsIndex = arg.indexOf('=');
      if (equalsIndex != -1) {
        result[arg.substring(2, equalsIndex)] = arg.substring(equalsIndex + 1);
      } else if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
        result[arg.substring(2)] = args[i + 1];
        i++;
      }
    }
  }
  return result;
}
