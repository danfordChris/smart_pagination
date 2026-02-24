

# 📦 smart_pagination

A clean, reusable, production-ready Flutter pagination package supporting offset-based and cursor-based pagination with a built-in infinite scroll widget.
___

## ✨ Features
- ✅ Offset pagination (page + limit)
- ✅ Cursor pagination (nextCursor)
- ✅ Pull-to-refresh support
- ✅ Infinite scrolling
- ✅ Prevents duplicate requests
- ✅ Safe disposal handling
- ✅ Framework-independent core
- ✅ Optional Flutter UI layer
- ✅ Provider / Riverpod / Bloc friendly
___

## 📦 Installation

Add to your pubspec.yaml:

```bash
dependencies:
  smart_pagination: ^1.0.0
```
Then run:

```bash 
flutter pub get
```
___

## 🚀 Quick Start
____

### 1️⃣ Offset Pagination (Page + Limit)

Best for:
- REST APIs
- Traditional page-based endpoints
___

### Example API


```bash
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

Create Controller

```bash
final usersController = OffsetPaginationController<User>(
  fetcher: fetchUsers,
  limit: 20,
);
```
___
### Use in UI

```bash
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

That’s it. Infinite scrolling works automatically.
___

### 🚀 2️⃣ Cursor Pagination

Best for:
- Firebase
- GraphQL
- Infinite feeds
- Timeline-style APIs

___

## Example API Response

```bash
{
    "data": [...],
    "nextCursor": "abc123"
}
```
___

### Create Fetcher

```bash
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
___

### Create Controller
```bash
final postsController = CursorPaginationController<Post>(
    fetcher: fetchPosts,
);
```
___

### Use in UI
```bash
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
⸻

## 🔄 Pull To Refresh

Pull down to refresh automatically calls:

```bash
controller.fetchNext(refresh: true);
```

No extra setup required.

___

## 🧠 Manual Controls

You can control pagination manually:

```bash 
controller.fetchNext();              // Load next page
controller.fetchNext(refresh: true); // Refresh from start
controller.reset();                  // Clear all data
```
___

## 🏗 Architecture Overview

```bash
smart_pagination/
│
├── core/
│   ├── PaginationState
│   ├── PaginationController
│   ├── OffsetPaginationController
│   └── CursorPaginationController
│
└── flutter/
└── PaginatedListView
```
___

## 📊 PaginationState

### **controller.state**

### Properties:

| Property     | Description                                   |
|--------------|-----------------------------------------------|
| items        | Loaded data                                   |
| status       | initial / loading / success / failure         |
| hasMore      | Whether more pages exist                      |
| errorMessage | Error message if failed                       |
| nextCursor   | Cursor (for cursor-based pagination)          |

___

## 🧩 Using With Provider (Recommended)

Create Controller Class
```bash
class UsersController extends OffsetPaginationController<User> {
  UsersController() : super(fetcher: fetchUsers);
}
```

### Register

```bash 
ChangeNotifierProvider(
  create: (_) => UsersController(),
)
```

### Use
```bash
Consumer<UsersController>(
    builder: (_, controller, __) {
        return PaginatedListView<User>(
            controller: controller,
            itemBuilder: ...
        );
    },
);
```
___

### 🎯 When To Use What?

| Use Case                         | Controller                    |
|----------------------------------|------------------------------|
| REST APIs with page & limit      | OffsetPaginationController   |
| Firebase                         | CursorPaginationController   |
| GraphQL                          | CursorPaginationController   |
| Infinite feeds                   | CursorPaginationController   |
___

### 🛡 Production Safety

The package automatically:
- Prevents duplicate fetch calls
- Stops fetching when no more data
- Handles disposal safely
- Maps common network errors
- Prevents race conditions

___

## ⚙ Advanced Usage

You can build your own UI:
```bash
AnimatedBuilder(
animation: controller,
    builder: (_, __) {
        final state = controller.state;
            if (state.isInitialLoading) {
              return const CircularProgressIndicator();
            }
            if (state.hasError) {
              return Text(state.errorMessage!);
            }
        
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (_, i) => Text(state.items[i].toString()),
            );
    },
);
```
___

## 🧪 Testing

Since the core layer is framework-independent, you can unit test:

```bash
test('loads next page correctly', () async {
    final controller = OffsetPaginationController<int>(
        fetcher: (page, limit) async => [1, 2, 3],
    );
    await controller.fetchNext();
    expect(controller.state.items.length, 3);
});
```
___

## 📌 Best Practices
- Always use Provider/Riverpod/Bloc in production
- Avoid creating global controllers
- Dispose controllers properly
- Prefer cursor pagination for large datasets

___

## 📈 Roadmap
•	Grid view support
•	Smart prefetching
•	Built-in caching
•	Offline-first mode
•	Exponential retry
•	Riverpod adapter
•	Bloc adapter

___

### 🤝 Contributing

Pull requests are welcome. Please follow the existing code style and include tests for new features.
___

## 📄 License

MIT License
___

## 💬 Support

If you find this package helpful, give it a ⭐ on GitHub.
___