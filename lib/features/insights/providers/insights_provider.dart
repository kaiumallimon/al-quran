import 'package:flutter/foundation.dart';

import '../../../data/models/insight_model.dart';
import '../../../data/models/reading_summary_model.dart';
import '../../../data/models/recommendation_model.dart';
import '../../../data/repositories/insights_repository.dart';

enum InsightsStatus { initial, loading, loaded, error }

/// View model for reading insights and recommendations.
class InsightsProvider extends ChangeNotifier {
  InsightsProvider({required InsightsRepository repository})
      : _repository = repository;

  final InsightsRepository _repository;

  InsightsStatus _status = InsightsStatus.initial;
  String? _errorMessage;

  List<InsightModel> _insights = [];
  List<RecommendationModel> _recommendations = [];
  ReadingSummaryModel _weeklySummary = const ReadingSummaryModel();
  ReadingSummaryModel _monthlySummary = const ReadingSummaryModel();
  ReadingSummaryModel _lifetimeSummary = const ReadingSummaryModel();
  List<DailyActivityModel> _weeklyActivity = [];

  InsightsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<InsightModel> get insights => _insights;
  List<RecommendationModel> get recommendations => _recommendations;
  ReadingSummaryModel get weeklySummary => _weeklySummary;
  ReadingSummaryModel get monthlySummary => _monthlySummary;
  ReadingSummaryModel get lifetimeSummary => _lifetimeSummary;
  List<DailyActivityModel> get weeklyActivity => _weeklyActivity;

  List<InsightModel> get recentInsights => _insights.take(3).toList();
  RecommendationModel? get topRecommendation =>
      _recommendations.isNotEmpty ? _recommendations.first : null;

  Future<void> loadInsights() async {
    if (_status == InsightsStatus.loading) return;

    _status = InsightsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.generateInsights(),
        _repository.getRecommendations(),
        _repository.getWeeklySummary(),
        _repository.getMonthlySummary(),
        _repository.getLifetimeSummary(),
        _repository.getWeeklyActivity(),
      ]);

      _insights = results[0] as List<InsightModel>;
      _recommendations = results[1] as List<RecommendationModel>;
      _weeklySummary = results[2] as ReadingSummaryModel;
      _monthlySummary = results[3] as ReadingSummaryModel;
      _lifetimeSummary = results[4] as ReadingSummaryModel;
      _weeklyActivity = results[5] as List<DailyActivityModel>;
      _status = InsightsStatus.loaded;
    } catch (_) {
      _errorMessage = 'Unable to load insights. Please try again.';
      _status = InsightsStatus.error;
    }

    notifyListeners();
  }

  Future<void> refresh() => loadInsights();
}
