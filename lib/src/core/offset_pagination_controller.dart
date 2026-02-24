import 'pagination_controller.dart';
import 'pagination_state.dart';
import 'pagination_status.dart';

class OffsetPaginationController<T> extends PaginationController<T> {
  final Future<List<T>> Function(int page, int limit) fetcher;
  final int limit;
  int _page = 1;

  OffsetPaginationController({required this.fetcher, this.limit = 20});

  @override
  Future<void> fetchNext({bool refresh = false}) async {
    if (isFetching) return;
    if (refresh) {
      await refreshData();
      return;
    }
    if (!state.hasMore) return;
    startFetching();
    try {
      final result = await fetcher(_page, limit);
      final hasMore = result.length >= limit;
      setState(PaginationState<T>(items: [...state.items, ...result], status: PaginationStatus.success, hasMore: hasMore));
      _page++;
    } catch (e) {
      setState(state.copyWith(status: PaginationStatus.failure, errorMessage: mapError(e)));
    }
    stopFetching();
  }

  Future<void> refreshData() async {
    if (isFetching) return;
    startFetching();
    _page = 1;
    setState(state.copyWith(status: PaginationStatus.loading, hasMore: true, clearError: true));
    try {
      final result = await fetcher(_page, limit);
      final hasMore = result.length >= limit;
      setState(PaginationState<T>(items: result, status: PaginationStatus.success, hasMore: hasMore));
      _page++;
    } catch (e) {
      setState(state.copyWith(status: PaginationStatus.failure, errorMessage: mapError(e)));
    }
    stopFetching();
  }
}
