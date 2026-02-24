import 'pagination_controller.dart';
import 'pagination_state.dart';
import 'pagination_status.dart';

class CursorResult<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;

  CursorResult({required this.items, required this.nextCursor, required this.hasMore});
}

class CursorPaginationController<T> extends PaginationController<T> {
  final Future<CursorResult<T>> Function(String? cursor) fetcher;

  String? _cursor;

  CursorPaginationController({required this.fetcher});

  @override
  Future<void> fetchNext({bool refresh = false}) async {
    if (isFetching) return;
    if (!refresh && !state.hasMore) return;

    startFetching();

    if (refresh) {
      _cursor = null;
      setState(state.copyWith(status: PaginationStatus.loading, hasMore: true, clearError: true));
    }

    try {
      final result = await fetcher(_cursor);

      final items = refresh ? result.items : [...state.items, ...result.items];

      _cursor = result.nextCursor;

      setState(PaginationState<T>(items: items, status: PaginationStatus.success, hasMore: result.hasMore, nextCursor: result.nextCursor));
    } catch (e) {
      setState(state.copyWith(status: PaginationStatus.failure, errorMessage: mapError(e)));
    }

    stopFetching();
  }
}
