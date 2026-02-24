import 'pagination_status.dart';

class PaginationState<T> {
  final List<T> items;
  final PaginationStatus status;
  final bool hasMore;
  final String? errorMessage;

  /// For cursor-based pagination
  final String? nextCursor;

  const PaginationState({this.items = const [], this.status = PaginationStatus.initial, this.hasMore = true, this.errorMessage, this.nextCursor});

  PaginationState<T> copyWith({
    List<T>? items,
    PaginationStatus? status,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
    String? nextCursor,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      status: status ?? this.status,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }

  bool get isInitialLoading => status == PaginationStatus.loading && items.isEmpty;

  bool get hasError => status == PaginationStatus.failure && items.isEmpty;

  bool get isEmpty => status == PaginationStatus.success && items.isEmpty;
}
