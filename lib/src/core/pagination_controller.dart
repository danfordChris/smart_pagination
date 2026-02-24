import 'package:flutter/foundation.dart';

import 'pagination_state.dart';

abstract class PaginationController<T> extends ChangeNotifier {
  PaginationState<T> _state = const PaginationState();
  PaginationState<T> get state => _state;

  bool _isFetching = false;
  bool _disposed = false;

  Future<void> fetchNext({bool refresh = false});

  void reset() {
    _state = const PaginationState();
    _notify();
  }

  void setState(PaginationState<T> newState) {
    _state = newState;
    _notify();
  }

  String mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('Socket')) return 'No internet connection';
    if (msg.contains('Timeout')) return 'Request timeout';
    if (msg.contains('401')) return 'Unauthorized';
    if (msg.contains('403')) return 'Forbidden';
    if (msg.contains('404')) return 'Not found';
    return 'Something went wrong';
  }

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
