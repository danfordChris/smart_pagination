# Changelog

## 1.1.0
- **BREAKING CHANGE**: Renamed package to `easy_scroll_pagination`.
- **NEW**: Introduced `PaginatedView`, a highly flexible widget supporting multiple layouts:
    - `PaginatedView.list()`: For infinite lists.
    - `PaginatedView.grid()`: For infinite grids.
    - `PaginatedView.page()`: For paginated `PageView` (horizontal/vertical).
    - `PaginatedView.layout()`: For custom layouts like `Column`, `Row`, or `StaggeredGrid`.
- **FIX**: Fixed a runtime error in `PaginatedView.page` related to `PageController` casting.
- **ENHANCEMENT**: Added support for custom loading, error, and empty state widgets.
- **ENHANCEMENT**: `PaginatedListView` is now a convenience wrapper around `PaginatedView.list()`.

## 1.0.0
- Initial release.
- Support for offset, cursor, and parallel pagination.
