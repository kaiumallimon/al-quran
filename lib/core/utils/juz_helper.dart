/// Standard Madani mushaf juz end page numbers.
class JuzHelper {
  JuzHelper._();

  static const List<int> juzEndPages = [
    21, 41, 61, 81, 101, 121, 141, 161, 181, 201,
    221, 241, 261, 281, 301, 321, 341, 361, 381, 401,
    421, 441, 461, 481, 501, 521, 541, 561, 581, 604,
  ];

  /// Returns the juz number (1–30) for a given page.
  static int juzForPage(int page) {
    if (page <= 0) return 1;
    for (var i = 0; i < juzEndPages.length; i++) {
      if (page <= juzEndPages[i]) return i + 1;
    }
    return 30;
  }

  /// Pages remaining until the end of the current juz.
  static int pagesUntilJuzEnd(int page) {
    if (page <= 0) return juzEndPages.first;
    final juz = juzForPage(page);
    final endPage = juzEndPages[juz - 1];
    return (endPage - page).clamp(0, endPage);
  }
}
