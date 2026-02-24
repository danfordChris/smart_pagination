import 'dart:async';

import 'package:easy_scroll_pagination/easy_scroll_pagination.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Smart Pagination Example', theme: ThemeData(useMaterial3: true), home: const UsersPage());
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
    _controller = OffsetPaginationController<User>(fetcher: _fetchUsers, limit: 20);
  }

  Future<List<User>> _fetchUsers(int page, int limit) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final start = (page - 1) * limit;

    if (page > 5) return [];

    return List.generate(limit, (index) => User(id: start + index + 1, name: 'User ${start + index + 1}'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Smart Pagination Example'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'List'),
              Tab(text: 'Grid'),
              Tab(text: 'Page'),
              Tab(text: 'Column'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildListView(), _buildGridView(), _buildPageView(), _buildColumnView()]),
      ),
    );
  }

  Widget _buildListView() {
    return PaginatedView<User>.list(
      controller: _controller,
      itemBuilder: (context, user, index) => ListTile(
        leading: CircleAvatar(child: Text(user.id.toString())),
        title: Text(user.name),
      ),
    );
  }

  Widget _buildGridView() {
    return PaginatedView<User>.grid(
      controller: _controller,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2),
      itemBuilder: (context, user, index) => Card(child: Center(child: Text(user.name))),
    );
  }

  Widget _buildPageView() {
    return PaginatedView<User>.page(
      controller: _controller,
      itemBuilder: (context, user, index) => Center(child: Text(user.name, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }

  Widget _buildColumnView() {
    final scrollController = ScrollController();
    return SingleChildScrollView(
      controller: scrollController,
      child: PaginatedView<User>.layout(
        controller: _controller,
        scrollController: scrollController,
        itemBuilder: (context, user, index) => ListTile(title: Text(user.name), subtitle: Text('Index: $index')),
        layoutBuilder: (children) => Column(children: children),
      ),
    );
  }
}

class User {
  final int id;
  final String name;

  User({required this.id, required this.name});
}
