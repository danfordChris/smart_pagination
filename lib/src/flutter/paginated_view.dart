import 'package:easy_scroll_pagination/easy_pagination.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef PaginatedItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

typedef PaginatedLayoutBuilder<T> = Widget Function(
    BuildContext context, ScrollController? scrollController, List<T> items, Widget? loadMoreIndicator);

/// A flexible pagination widget that supports various layouts like ListView, GridView, PageView, etc.
class PaginatedView<T> extends StatefulWidget {
  final PaginationController<T> controller;
  final PaginatedItemBuilder<T> itemBuilder;
  final PaginatedLayoutBuilder<T> layoutBuilder;
  final Widget? onEmpty;
  final Widget? onError;
  final Widget? onInitialLoading;
  final Widget? onLoadingMore;
  final ScrollController? scrollController;
  final double scrollThreshold;
  final bool autoFetch;

  const PaginatedView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.layoutBuilder,
    this.onEmpty,
    this.onError,
    this.onInitialLoading,
    this.onLoadingMore,
    this.scrollController,
    this.scrollThreshold = 200.0,
    this.autoFetch = true,
  });

  /// A pre-configured PaginatedView for ListView.
  factory PaginatedView.list({
    Key? key,
    required PaginationController<T> controller,
    required PaginatedItemBuilder<T> itemBuilder,
    Widget? onEmpty,
    Widget? onError,
    Widget? onInitialLoading,
    Widget? onLoadingMore,
    ScrollController? scrollController,
    double scrollThreshold = 200.0,
    bool autoFetch = true,
    bool reverse = false,
    bool? primary,
    ScrollPhysics? physics,
    EdgeInsetsGeometry? padding,
  }) {
    return PaginatedView<T>(
      key: key,
      controller: controller,
      itemBuilder: itemBuilder,
      onEmpty: onEmpty,
      onError: onError,
      onInitialLoading: onInitialLoading,
      onLoadingMore: onLoadingMore,
      scrollController: scrollController,
      scrollThreshold: scrollThreshold,
      autoFetch: autoFetch,
      layoutBuilder: (context, scroll, items, loadMoreIndicator) {
        return ListView.builder(
          controller: scroll,
          reverse: reverse,
          primary: primary,
          physics: physics,
          padding: padding,
          itemCount: items.length + (loadMoreIndicator != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < items.length) {
              return itemBuilder(context, items[index], index);
            }
            return loadMoreIndicator!;
          },
        );
      },
    );
  }

  /// A pre-configured PaginatedView for GridView.
  factory PaginatedView.grid({
    Key? key,
    required PaginationController<T> controller,
    required PaginatedItemBuilder<T> itemBuilder,
    required SliverGridDelegate gridDelegate,
    Widget? onEmpty,
    Widget? onError,
    Widget? onInitialLoading,
    Widget? onLoadingMore,
    ScrollController? scrollController,
    double scrollThreshold = 200.0,
    bool autoFetch = true,
    EdgeInsetsGeometry? padding,
    bool reverse = false,
    bool? primary,
    ScrollPhysics? physics,
  }) {
    return PaginatedView<T>(
      key: key,
      controller: controller,
      itemBuilder: itemBuilder,
      onEmpty: onEmpty,
      onError: onError,
      onInitialLoading: onInitialLoading,
      onLoadingMore: onLoadingMore,
      scrollController: scrollController,
      scrollThreshold: scrollThreshold,
      autoFetch: autoFetch,
      layoutBuilder: (context, scroll, items, loadMoreIndicator) {
        if (loadMoreIndicator == null) {
          return GridView.builder(
            controller: scroll,
            gridDelegate: gridDelegate,
            padding: padding,
            reverse: reverse,
            primary: primary,
            physics: physics,
            itemCount: items.length,
            itemBuilder: (context, index) => itemBuilder(context, items[index], index),
          );
        }

        return CustomScrollView(
          controller: scroll,
          reverse: reverse,
          primary: primary,
          physics: physics,
          slivers: [
            SliverPadding(
              padding: padding ?? EdgeInsets.zero,
              sliver: SliverGrid(
                gridDelegate: gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => itemBuilder(context, items[index], index),
                  childCount: items.length,
                ),
              ),
            ),
            SliverToBoxAdapter(child: loadMoreIndicator),
          ],
        );
      },
    );
  }

  /// A pre-configured PaginatedView for PageView.
  factory PaginatedView.page({
    Key? key,
    required PaginationController<T> controller,
    required PaginatedItemBuilder<T> itemBuilder,
    Widget? onEmpty,
    Widget? onError,
    Widget? onInitialLoading,
    Widget? onLoadingMore,
    PageController? pageController,
    double scrollThreshold = 200.0,
    bool autoFetch = true,
    Axis scrollDirection = Axis.horizontal,
    bool reverse = false,
    ScrollPhysics? physics,
    bool pageSnapping = true,
    void Function(int)? onPageChanged,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    bool allowImplicitScrolling = false,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
    ScrollBehavior? scrollBehavior,
    bool padEnds = true,
  }) {
    return PaginatedView<T>(
      key: key,
      controller: controller,
      itemBuilder: itemBuilder,
      onEmpty: onEmpty,
      onError: onError,
      onInitialLoading: onInitialLoading,
      onLoadingMore: onLoadingMore,
      scrollController: pageController ?? PageController(),
      scrollThreshold: scrollThreshold,
      autoFetch: autoFetch,
      layoutBuilder: (context, scroll, items, loadMoreIndicator) {
        if (scroll is! PageController) {
          throw FlutterError(
            'PaginatedView.page requires a PageController. '
            'Check if you are passing a ScrollController to scrollController parameter.',
          );
        }
        return PageView.builder(
          controller: scroll,
          scrollDirection: scrollDirection,
          reverse: reverse,
          physics: physics,
          pageSnapping: pageSnapping,
          onPageChanged: (index) {
            if (onPageChanged != null) onPageChanged(index);
            // Trigger fetchNext when reaching near the end of the PageView
            if (index >= items.length - 1 && controller.state.hasMore) {
              controller.fetchNext();
            }
          },
          itemCount: items.length + (loadMoreIndicator != null ? 1 : 0),
          dragStartBehavior: dragStartBehavior,
          allowImplicitScrolling: allowImplicitScrolling,
          restorationId: restorationId,
          clipBehavior: clipBehavior,
          scrollBehavior: scrollBehavior,
          padEnds: padEnds,
          itemBuilder: (context, index) {
            if (index < items.length) {
              return itemBuilder(context, items[index], index);
            }
            return loadMoreIndicator!;
          },
        );
      },
    );
  }

  /// A pre-configured PaginatedView for Column or Row.
  /// Note: These layouts do not support scrolling by default,
  /// so you must wrap the PaginatedView in a SingleChildScrollView
  /// and pass its controller to [scrollController].
  factory PaginatedView.layout({
    Key? key,
    required PaginationController<T> controller,
    required PaginatedItemBuilder<T> itemBuilder,
    required Widget Function(List<Widget> children) layoutBuilder,
    Widget? onEmpty,
    Widget? onError,
    Widget? onInitialLoading,
    Widget? onLoadingMore,
    ScrollController? scrollController,
    double scrollThreshold = 200.0,
    bool autoFetch = true,
  }) {
    return PaginatedView<T>(
      key: key,
      controller: controller,
      itemBuilder: itemBuilder,
      onEmpty: onEmpty,
      onError: onError,
      onInitialLoading: onInitialLoading,
      onLoadingMore: onLoadingMore,
      scrollController: scrollController,
      scrollThreshold: scrollThreshold,
      autoFetch: autoFetch,
      layoutBuilder: (context, scroll, items, loadMoreIndicator) {
        final children = items.asMap().entries.map((e) => itemBuilder(context, e.value, e.key)).toList();
        if (loadMoreIndicator != null) {
          children.add(loadMoreIndicator);
        }
        return layoutBuilder(children);
      },
    );
  }

  @override
  State<PaginatedView<T>> createState() => _PaginatedViewState<T>();
}

class _PaginatedViewState<T> extends State<PaginatedView<T>> {
  late final ScrollController _scrollController;
  bool _isExternalController = false;

  @override
  void initState() {
    super.initState();
    _isExternalController = widget.scrollController != null;
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);

    if (widget.autoFetch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.controller.fetchNext(refresh: true);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    if (!_isExternalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    // For PageController, we handle pagination in onPageChanged because position.pixels
    // might not behave the same way as standard ScrollController during page transitions.
    if (_scrollController is PageController) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - widget.scrollThreshold) {
      widget.controller.fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;

        if (state.isInitialLoading) {
          return widget.onInitialLoading ?? const Center(child: CircularProgressIndicator());
        }

        if (state.hasError) {
          return widget.onError ?? Center(child: Text(state.errorMessage ?? 'An error occurred'));
        }

        if (state.items.isEmpty) {
          return widget.onEmpty ?? const Center(child: Text("No items found"));
        }

        Widget? loadMoreIndicator;
        if (state.status == PaginationStatus.loading && state.items.isNotEmpty) {
          loadMoreIndicator = widget.onLoadingMore ??
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        return RefreshIndicator(
          onRefresh: () => widget.controller.fetchNext(refresh: true),
          child: widget.layoutBuilder(context, _scrollController, state.items, loadMoreIndicator),
        );
      },
    );
  }
}
