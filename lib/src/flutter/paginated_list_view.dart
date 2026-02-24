import 'package:easy_scroll_pagination/easy_pagination.dart';
import 'package:flutter/material.dart';

/// A ready-to-use infinite list widget powered by a [PaginationController].
///
/// This is now a convenience wrapper around [PaginatedView.list].
class PaginatedListView<T> extends StatelessWidget {
  final PaginationController<T> controller;
  final PaginatedItemBuilder<T> itemBuilder;
  final Widget? onEmpty;
  final Widget? onError;
  final Widget? onInitialLoading;
  final Widget? onLoadingMore;
  final ScrollController? scrollController;
  final double scrollThreshold;
  final bool autoFetch;
  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const PaginatedListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.onEmpty,
    this.onError,
    this.onInitialLoading,
    this.onLoadingMore,
    this.scrollController,
    this.scrollThreshold = 200.0,
    this.autoFetch = true,
    this.reverse = false,
    this.primary,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return PaginatedView<T>.list(
      controller: controller,
      itemBuilder: itemBuilder,
      onEmpty: onEmpty,
      onError: onError,
      onInitialLoading: onInitialLoading,
      onLoadingMore: onLoadingMore,
      scrollController: scrollController,
      scrollThreshold: scrollThreshold,
      autoFetch: autoFetch,
      reverse: reverse,
      primary: primary,
      physics: physics,
      padding: padding,
    );
  }
}
