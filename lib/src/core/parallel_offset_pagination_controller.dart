import 'pagination_controller.dart';
import 'pagination_state.dart';
import 'pagination_status.dart';

class ParallelOffsetPaginationController<T> extends PaginationController<T> {
  final List<Future<List<T>> Function(int page, int limit)> fetchers;
  final int limit;

  /// Track the current page of each fetcher independently
  final List<int> _pages;

  ParallelOffsetPaginationController({required this.fetchers, this.limit = 20})
    : assert(fetchers.isNotEmpty, "At least one fetcher required"),
      _pages = List.filled(fetchers.length, 1);

  @override
  Future<void> fetchNext({bool refresh = false}) async {
    if (isFetching) return;

    startFetching();

    if (refresh) {
      for (var i = 0; i < _pages.length; i++) {
        _pages[i] = 1;
      }
      setState(state.copyWith(status: PaginationStatus.loading, hasMore: true, errorMessage: null));
    } else if (!state.hasMore) {
      stopFetching();
      return;
    }

    try {
      // Run each fetcher with its own page
      final results = await Future.wait(
        fetchers.asMap().entries.map((entry) {
          final index = entry.key;
          final fetcher = entry.value;
          return fetcher(_pages[index], limit);
        }),
      );

      // Merge all results
      final allItems = results.expand((list) => list).toList();

      // Increment page of each fetcher only if it returned data
      for (var i = 0; i < results.length; i++) {
        if (results[i].isNotEmpty) _pages[i]++;
      }

      // Update combined state
      setState(
        PaginationState<T>(
          items: refresh ? allItems : [...state.items, ...allItems],
          status: PaginationStatus.success,
          // hasMore is true if any fetcher still has enough data to continue
          hasMore: results.any((r) => r.length >= limit),
        ),
      );
    } catch (e) {
      setState(state.copyWith(status: PaginationStatus.failure, errorMessage: mapError(e)));
    }

    stopFetching();
  }
}
