import 'package:flutter/material.dart';
import 'package:smart_pagination/src/core/pagination_controller.dart';

class PaginatedListView<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget onEmpty;
  final Widget? onError;

  const PaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.onEmpty = const Center(child: Text("No items found")),
    this.onError,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.fetchNext(refresh: true);
    });
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      widget.controller.fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (_, __) {
        final state = widget.controller.state;

        if (state.isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return widget.onError ?? Center(child: Text(state.errorMessage ?? 'An error occurred'));
        }

        if (state.items.isEmpty) {
          return widget.onEmpty;
        }

        return RefreshIndicator(
          onRefresh: () => widget.controller.fetchNext(refresh: true),
          child: ListView.builder(
            controller: _scroll,
            itemCount: state.items.length,
            itemBuilder: (context, index) => widget.itemBuilder(context, state.items[index], index),
          ),
        );
      },
    );
  }
}
