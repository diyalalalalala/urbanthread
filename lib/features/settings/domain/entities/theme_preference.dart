/// The user's chosen colour scheme.
///
/// Deliberately not Flutter's `ThemeMode`: the domain layer must not import
/// Flutter, and this is also the value that gets persisted, so it owns its own
/// wire format. `settings_providers.dart` maps it to `ThemeMode` at the
/// presentation boundary.
enum ThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const ThemePreference(this.wireValue);

  /// The string written to `PreferencesService.themeMode`.
  final String wireValue;

  static ThemePreference parse(String? raw) => switch (raw?.toLowerCase()) {
        'light' => ThemePreference.light,
        'dark' => ThemePreference.dark,
        _ => ThemePreference.system,
      };

  String get label => switch (this) {
        ThemePreference.system => 'System default',
        ThemePreference.light => 'Light',
        ThemePreference.dark => 'Dark',
      };

  String get description => switch (this) {
        ThemePreference.system => 'Follow the device setting',
        ThemePreference.light => 'Always use the light theme',
        ThemePreference.dark => 'Always use the dark theme',
      };
}
