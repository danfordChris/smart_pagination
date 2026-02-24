# smart_pagination

Lightweight pagination controllers and a Flutter list widget for offset, cursor, and parallel pagination. The core controllers are framework-agnostic (ChangeNotifier-based) and easy to integrate with Provider, Riverpod, or Bloc.

## Features
- Offset pagination (page + limit)
- Cursor pagination (nextCursor)
- Parallel offset pagination (merge multiple sources in one list)
- Infinite scroll widget with pull-to-refresh
- Prevents duplicate fetches
- Safe disposal handling
- Clear pagination state model

## Installation
Add to `pubspec.yaml`:

```yaml
dependencies:
  smart_pagination: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Offset Pagination (Page + Limit)
Use for REST APIs or classic page-based endpoints.

Fetcher:

```dart
Future<List<User>> fetchUsers(int page, int limit) async {
  final response = await api.get('/users', query: {
    'page': page,
    'limit': limit,
  });

  return (response.data as List)
      .map((e) => User.fromJson(e))
      .toList();
}
```

Controller:

```dart
final usersController = OffsetPaginationController<User>(
  fetcher: fetchUsers,
  limit: 20,
);
```

UI:

```dart
PaginatedListView<User>(
  controller: usersController,
  itemBuilder: (context, user, index) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
    );
  },
)
```

### Cursor Pagination
Use for Firebase, GraphQL, infinite feeds, or cursor-based APIs.

Response shape (example):

```json
{ "data": [...], "nextCursor": "abc123" }
```

Fetcher:

```dart
Future<CursorResult<Post>> fetchPosts(String? cursor) async {
  final response = await api.get('/posts', query: {
    'cursor': cursor,
  });

  return CursorResult<Post>(
    items: (response.data['data'] as List)
        .map((e) => Post.fromJson(e))
        .toList(),
    nextCursor: response.data['nextCursor'],
    hasMore: response.data['nextCursor'] != null,
  );
}
```

Controller:

```dart
final postsController = CursorPaginationController<Post>(
  fetcher: fetchPosts,
);
```

UI:

```dart
PaginatedListView<Post>(
  controller: postsController,
  itemBuilder: (context, post, index) {
    return ListTile(
      title: Text(post.title),
      subtitle: Text(post.body),
    );
  },
)
```

### Parallel Offset Pagination
Use when you need to merge multiple paginated sources into one list.

```dart
final controller = ParallelOffsetPaginationController<Item>(
  fetchers: [
    (page, limit) => apiA.fetchItems(page, limit),
    (page, limit) => apiB.fetchItems(page, limit),
  ],
  limit: 20,
);
```

## Refresh and Manual Controls

```dart
controller.fetchNext();              // Load next page
controller.fetchNext(refresh: true); // Refresh from start
controller.reset();                  // Clear all data
```

The `PaginatedListView` already wires pull-to-refresh to `fetchNext(refresh: true)`.

## Lifecycle
Controllers are `ChangeNotifier`s. Dispose them when no longer used:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

## Pagination State
`controller.state` exposes:

- `items` - currently loaded items
- `status` - initial | loading | success | failure
- `hasMore` - whether more data is available
- `errorMessage` - error details for failures
- `nextCursor` - cursor for cursor-based pagination

Helpers:

- `isInitialLoading`
- `hasError`
- `isEmpty`

## Use With Provider

```dart
class UsersController extends OffsetPaginationController<User> {
  UsersController() : super(fetcher: fetchUsers);
}
```

```dart
ChangeNotifierProvider(
  create: (_) => UsersController(),
)
```

```dart
Consumer<UsersController>(
  builder: (_, controller, __) {
    return PaginatedListView<User>(
      controller: controller,
      itemBuilder: ...,
    );
  },
)
```

## Architecture Overview

```
lib/
  smart_pagination.dart
  src/
    core/
      pagination_controller.dart
      offset_pagination_controller.dart
      cursor_pagination_controller.dart
      parallel_offset_pagination_controller.dart
      pagination_state.dart
      pagination_status.dart
    flutter/
      paginated_list_view.dart
```

## Example
A runnable demo is available in `example/`.

## Testing

```dart
test('loads next page correctly', () async {
  final controller = OffsetPaginationController<int>(
    fetcher: (page, limit) async => [1, 2, 3],
  );

  await controller.fetchNext();
  expect(controller.state.items.length, 3);
});
```

## License
MIT License. See `LICENSE`.
