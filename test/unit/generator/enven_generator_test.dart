import 'package:enven/src/generator/enven_generator.dart';
import 'package:enven/src/model/file.dart';
import 'package:test/test.dart';

EnvFile _buildEnvFile({
  String? className,
  Map<String, EnvEntry>? entries,
}) {
  return EnvFile(
    config: EnvenConfig(
      output: null,
      seed: 'test',
      className: className,
    ),
    entries: entries ??
        {
          'API_KEY': EnvEntry(
            annotations: {},
            key: 'API_KEY',
            value: 'abc',
          ),
        },
  );
}

void main() {
  const generator = EnvenGenerator();

  group('className', () {
    test('Should use default class name when not specified', () {
      final output = generator.generate(_buildEnvFile());
      expect(output, contains('class Env {'));
      expect(output, contains('class EnvData {'));
      expect(output, contains('static EnvData instance = EnvData();'));
    });

    test('Should use custom class name', () {
      final output = generator.generate(_buildEnvFile(className: 'Config'));
      expect(output, contains('class Config {'));
      expect(output, contains('class ConfigData {'));
      expect(output, contains('static ConfigData instance = ConfigData();'));
    });

    test('Should not contain default class name when custom is set', () {
      final output = generator.generate(_buildEnvFile(className: 'Config'));
      expect(output, isNot(contains('class Env {')));
      expect(output, isNot(contains('class EnvData {')));
    });

    test('Should use custom class name in mock example comment', () {
      final output = generator.generate(_buildEnvFile(className: 'Config'));
      expect(
        output,
        contains('Config.instance = MockConfigData()'),
      );
    });

    test('Should use default class name in mock example comment', () {
      final output = generator.generate(_buildEnvFile());
      expect(
        output,
        contains('Env.instance = MockEnvData()'),
      );
    });

    test('Should use custom class name with getter delegation', () {
      final output = generator.generate(_buildEnvFile(className: 'AppEnv'));
      expect(output, contains('static String get apiKey => instance.apiKey;'));
      expect(output, contains('class AppEnv {'));
      expect(output, contains('class AppEnvData {'));
    });

    test('Should use custom class name with const entry', () {
      final output = generator.generate(_buildEnvFile(
        className: 'Settings',
        entries: {
          'VERSION': EnvEntry(
            annotations: {
              EnvEntryAnnotation.isConst: EnvEntryAnnotation(
                key: EnvEntryAnnotation.isConst,
                value: true,
              ),
            },
            key: 'VERSION',
            value: 1,
          ),
        },
      ));
      expect(output, contains('class Settings {'));
      expect(output, contains('class SettingsData {'));
      expect(output, contains('static const int version = 1;'));
    });
  });
}
