import '../../../core/constants/api_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../models/ayah_model.dart';
import '../../models/search_result_model.dart';
import '../../models/surah_model.dart';
import 'quran_api_client.dart';

/// Remote data source for Quran content from alquran.cloud.
class QuranRemoteDataSource {
  QuranRemoteDataSource(this._client);

  final QuranApiClient _client;

  Future<List<SurahModel>> fetchSurahList() async {
    final response = await _client.getTyped<List<SurahModel>>(
      '/surah',
      (data) => (data as List)
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<SurahModel> fetchSurahMeta(int number) async {
    final response = await _client.get('/surah/$number');
    final data = response['data'] as Map<String, dynamic>;
    return SurahModel.fromJson(data);
  }

  Future<List<AyahModel>> fetchSurahAyahs(int number, {String? edition}) async {
    final path = edition != null
        ? '/surah/$number/$edition'
        : '/surah/$number/${ApiConstants.editionArabic}';
    final response = await _client.get(path);
    final data = response['data'] as Map<String, dynamic>;
    final ayahs = data['ayahs'] as List;
    return ayahs
        .map((e) => AyahModel.fromJson(
              e as Map<String, dynamic>,
              surahNumber: number,
            ))
        .toList();
  }

  Future<AyahModel> fetchRandomAyah() async {
    final response = await _client.get('/ayah/random');
    final data = response['data'] as Map<String, dynamic>;
    return AyahModel.fromJson(data);
  }

  Future<AyahModel> fetchAyah(int number, {String? edition}) async {
    final path = edition != null
        ? '/ayah/$number/$edition'
        : '/ayah/$number/${ApiConstants.editionArabic}';
    final response = await _client.get(path);
    final data = response['data'] as Map<String, dynamic>;
    return AyahModel.fromJson(data);
  }

  Future<AyahModel> fetchAyahWithEditions(
    int number,
    List<String> editions,
  ) async {
    final editionsParam = editions.join(',');
    final response =
        await _client.get('/ayah/$number/editions/$editionsParam');
    return _mergeAyahEditions(response['data'] as List);
  }

  /// Fetches a full surah merged across multiple editions.
  Future<List<AyahModel>> fetchSurahWithEditions(
    int number,
    List<String> editions,
  ) async {
    final editionsParam = editions.join(',');
    final response =
        await _client.get('/surah/$number/editions/$editionsParam');
    final dataList = response['data'] as List;

    final merged = <int, AyahModel>{};

    for (final editionSurah in dataList) {
      final map = editionSurah as Map<String, dynamic>;
      final edition = map['edition'] as Map<String, dynamic>?;
      final editionId = edition?['identifier'] as String? ?? '';
      final ayahs = map['ayahs'] as List;

      for (final ayahJson in ayahs) {
        final ayahMap = ayahJson as Map<String, dynamic>;
        final numInSurah = ayahMap['numberInSurah'] as int;
        final text = ayahMap['text'] as String;

        if (_isArabicEdition(editionId)) {
          merged[numInSurah] = AyahModel.fromJson(
            ayahMap,
            surahNumber: number,
          );
        } else if (merged.containsKey(numInSurah)) {
          merged[numInSurah] = _applyEditionText(
            merged[numInSurah]!,
            editionId: editionId,
            editionType: edition?['type'] as String? ?? '',
            text: text,
          );
        }
      }
    }

    return merged.values.toList()
      ..sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah));
  }

  AyahModel _mergeAyahEditions(List dataList) {
    AyahModel? base;

    for (final item in dataList) {
      final map = item as Map<String, dynamic>;
      final edition = map['edition'] as Map<String, dynamic>?;
      final editionId = edition?['identifier'] as String? ?? '';
      final text = map['text'] as String;

      if (_isArabicEdition(editionId)) {
        base = AyahModel.fromJson(map);
      } else if (base != null) {
        base = _applyEditionText(
          base,
          editionId: editionId,
          editionType: edition?['type'] as String? ?? '',
          text: text,
        );
      }
    }

    if (base == null && dataList.isNotEmpty) {
      base = AyahModel.fromJson(dataList.first as Map<String, dynamic>);
    }

    return base!;
  }

  AyahModel _applyEditionText(
    AyahModel ayah, {
    required String editionId,
    required String editionType,
    required String text,
  }) {
    if (editionType == 'transliteration' ||
        editionId == ApiConstants.editionTransliteration) {
      return ayah.copyWith(banglaTransliteration: text);
    }
    if (editionId.startsWith('en.')) {
      return ayah.copyWith(englishText: text);
    }
    if (editionId.startsWith('bn.')) {
      return ayah.copyWith(banglaTranslation: text);
    }
    return ayah;
  }

  bool _isArabicEdition(String editionId) {
    return editionId.contains('quran') || editionId.startsWith('quran-');
  }

  /// Searches verses remotely via alquran.cloud search API.
  Future<List<SearchResultModel>> search(
    String word, {
    String surah = 'all',
    String language = 'en',
  }) async {
    final encoded = Uri.encodeComponent(word);
    final path = surah == 'all'
        ? '/search/$encoded/all/$language'
        : '/search/$encoded/$surah/$language';

    try {
      final response = await _client.get(path);
      final data = response['data'] as Map<String, dynamic>;
      final matches = data['matches'] as List? ?? [];

      return matches.map((item) {
        final map = item as Map<String, dynamic>;
        final surahData = map['surah'] as Map<String, dynamic>;
        final edition = map['edition'] as Map<String, dynamic>?;
        final lang = edition?['language'] as String? ?? 'en';

        return SearchResultModel(
          surahNumber: surahData['number'] as int,
          numberInSurah: map['numberInSurah'] as int,
          globalAyahNumber: map['number'] as int?,
          previewText: map['text'] as String,
          englishText: lang == 'en' ? map['text'] as String : null,
          surahEnglishName: surahData['englishName'] as String,
          surahArabicName: surahData['name'] as String?,
          matchedIn: lang == 'bn' ? 'bangla' : 'english',
          isLocal: false,
        );
      }).toList();
    } on ApiException catch (e) {
      if (e.statusCode == 404) return [];
      rethrow;
    }
  }

  /// Searches English and Bangla editions in parallel.
  Future<List<SearchResultModel>> searchAllLanguages(String word) async {
    final results = await Future.wait([
      search(word, language: ApiConstants.editionEnglish),
      search(word, language: 'bn'),
    ]);

    final merged = <String, SearchResultModel>{};
    for (final result in [...results[0], ...results[1]]) {
      merged['${result.surahNumber}:${result.numberInSurah}'] = result;
    }
    return merged.values.toList();
  }
}
