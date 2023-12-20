import 'package:flybuy/service/helpers/request_helper.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

import '../models/models.dart';

part 'topic_store.g.dart';

class BBPTopicStore = BBPTopicStoreBase with _$BBPTopicStore;

abstract class BBPTopicStoreBase with Store {
  final String? key;

  // Request helper instance
  final RequestHelper _requestHelper;
  CancelToken _token = CancelToken();

  // constructor:---------------------------------------------------------------
  BBPTopicStoreBase(
    this._requestHelper, {
    this.key,
    int? perPage,
  }) {
    if (perPage != null) _perPage = perPage;
    _reaction();
  }

  // store variables:-----------------------------------------------------------
  static ObservableFuture<Map> emptyTopicsResponse = ObservableFuture.value({});

  @observable
  ObservableFuture<Map?> fetchTopicsFuture = emptyTopicsResponse;

  @observable
  ObservableList<BBPTopic> _topics = ObservableList<BBPTopic>.of([]);

  @observable
  int _perPage = 10;

  @observable
  int _nextPage = 1;

  @observable
  bool _canLoadMore = true;

  // computed:-------------------------------------------------------------------
  @computed
  bool get loading => fetchTopicsFuture.status == FutureStatus.pending;

  @observable
  bool pending = false;

  @computed
  int get nextPage => _nextPage;

  @computed
  ObservableList<BBPTopic> get topics => _topics;

  @computed
  bool get canLoadMore => _canLoadMore;

  @computed
  int get perPage => _perPage;

  // actions:-------------------------------------------------------------------
  @action
  Future<List<BBPTopic>> getTopics({bool cancelPrevious = false}) async {
    if (cancelPrevious) {
      _token.cancel("cancel");
      _token = CancelToken();
    }
    if (pending) {
      return ObservableList<BBPTopic>.of([]);
    }

    pending = true;

    Map<String, dynamic> qs = {
      "page": _nextPage,
      "per_page": _perPage,
    };

    final future =
        _requestHelper.getTopics(queryParameters: qs, cancelToken: _token);
    fetchTopicsFuture = ObservableFuture(future);
    return future.then((res) {
      List dataTopics = res?["topics"] ?? [];
      int dataNextPage = ConvertData.stringToInt(res?["next_page"]);

      List<BBPTopic> data =
          dataTopics.map((m) => BBPTopic.fromJson(m)).toList().cast<BBPTopic>();

      // Replace state in the first time or refresh
      if (_nextPage <= 1) {
        _topics = ObservableList<BBPTopic>.of(data);
      } else {
        // Add posts when load more page
        _topics.addAll(ObservableList<BBPTopic>.of(data));
      }

      // Check if can load more item
      if (dataNextPage > _nextPage) {
        _nextPage = dataNextPage;
      } else {
        _canLoadMore = false;
      }

      pending = false;
      return _topics;
    }).catchError((error) {
      pending = false;
      _canLoadMore = false;
      avoidPrint(error);
      throw error;
    });
  }

  @action
  Future<void> refresh() {
    pending = false;
    _canLoadMore = true;
    _nextPage = 1;
    _topics.clear();
    return getTopics(cancelPrevious: true);
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _reaction() {
    _disposers = [];
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
    _token.cancel("cancel");
  }
}
