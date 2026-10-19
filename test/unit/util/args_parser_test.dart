import 'package:enven/src/util/args_parser.dart';
import 'package:test/test.dart';

void main() {
  group('parseArgs', () {
    test('Should return empty map for no args', () {
      expect(parseArgs([]), isEmpty);
    });

    test('Should parse --key=value format', () {
      final result = parseArgs(['--name=hello']);
      expect(result, {'name': 'hello'});
    });

    test('Should parse --key value format', () {
      final result = parseArgs(['--name', 'hello']);
      expect(result, {'name': 'hello'});
    });

    test('Should parse multiple args', () {
      final result = parseArgs([
        '--env-files',
        '.env,.env.prod',
        '--class-name=Config',
      ]);
      expect(result, {
        'env-files': '.env,.env.prod',
        'class-name': 'Config',
      });
    });

    test('Should handle value containing equals sign', () {
      final result = parseArgs(['--key=a=b']);
      expect(result, {'key': 'a=b'});
    });

    test('Should ignore flag without value at end of args', () {
      final result = parseArgs(['--flag']);
      expect(result, isEmpty);
    });

    test('Should not consume next flag as value', () {
      final result = parseArgs(['--flag', '--other', 'val']);
      expect(result, {'other': 'val'});
      expect(result.containsKey('flag'), isFalse);
    });

    test('Should ignore non-flag arguments', () {
      final result = parseArgs(['hello', '--name', 'world']);
      expect(result, {'name': 'world'});
    });
  });
}
