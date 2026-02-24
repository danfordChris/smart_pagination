import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smart_pagination/smart_pagination.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Pagination Example',
      theme: ThemeData(useMaterial3: true),
      home: const UsersPage(),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late final OffsetPaginationController<User> _controller;

  @override
  void initState() {
    super.initState();
    _controller = OffsetPaginationController<User>(
      fetcher: _fetchUsers,
      limit: 20,
    );
  }

  Future<List<User>> _fetchUsers(int page, int limit) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final start = (page - 1) * limit;

    if (page > 5) return [];

    return List.generate(
      limit,
      (index) => User(
        id: start + index + 1,
        name: 'User ${start + index + 1}',
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: PaginatedListView<User>(
        controller: _controller,
        itemBuilder: (context, user, index) {
          return ListTile(
            leading: CircleAvatar(child: Text(user.id.toString())),
            title: Text(user.name),
          );
        },
      ),
    );
  }
}

class User {
  final int id;
  final String name;

  User({required this.id, required this.name});
}
