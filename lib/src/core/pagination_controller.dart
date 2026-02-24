import 'package:flutter/foundation.dart';

import 'pagination_state.dart';

/// Base controller for pagination.
///
/// Concrete implementations provide a `fetchNext` strategy and update
/// the [state] accordingly.
abstract class PaginationController<T> extends ChangeNotifier {
  PaginationState<T> _state = const PaginationState();
  PaginationState<T> get state => _state;

  bool _isFetching = false;
  bool _disposed = false;

  /// Fetch the next page of data.
  ///
  /// When [refresh] is true, the controller should reload from the start.
  Future<void> fetchNext({bool refresh = false});

  /// Resets the controller to the initial empty state.
  void reset() {
    _state = const PaginationState();
    _notify();
  }

  /// Updates the controller state and notifies listeners.
  void setState(PaginationState<T> newState) {
    _state = newState;
    _notify();
  }

  /// Maps common error strings to user-friendly messages.
  String mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('Socket')) return 'No internet connection';
    if (msg.contains('Timeout')) return 'Request timeout';
    if (msg.contains('401')) return 'Unauthorized';
    if (msg.contains('403')) return 'Forbidden';
    if (msg.contains('404')) return 'Not found';
    return 'Something went wrong';
  }

  /// Whether a fetch operation is currently running.
  bool get isFetching => _isFetching;

  void startFetching() => _isFetching = true;
  void stopFetching() => _isFetching = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
