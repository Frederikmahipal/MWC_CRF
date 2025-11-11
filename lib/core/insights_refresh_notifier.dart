import 'dart:async';

enum DataChangeType { likes, visits, reviews }

class InsightsRefreshNotifier {
  static final InsightsRefreshNotifier _instance =
      InsightsRefreshNotifier._internal();
  factory InsightsRefreshNotifier() => _instance;
  InsightsRefreshNotifier._internal();

  final StreamController<DataChangeType?> _refreshController =
      StreamController<DataChangeType?>.broadcast();

  Stream<DataChangeType?> get refreshStream => _refreshController.stream;

  void notifyRefresh([DataChangeType? changeType]) {
    _refreshController.add(changeType);
  }

  void dispose() {
    _refreshController.close();
  }
}
