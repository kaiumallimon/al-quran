/// Available reading display modes.
enum ReadingMode {
  normal('Normal', 'Show Arabic and translations'),
  readingFocus('Reading Focus', 'Minimal distractions'),
  hideTranslations('Hide Translations', 'Arabic with optional toggle'),
  arabicOnly('Arabic Only', 'Arabic text only'),
  translationOnly('Translation Only', 'Translations without Arabic');

  const ReadingMode(this.label, this.description);

  final String label;
  final String description;

  static ReadingMode fromString(String value) {
    return ReadingMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ReadingMode.normal,
    );
  }
}
