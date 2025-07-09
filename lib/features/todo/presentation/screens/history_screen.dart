import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    final history = provider.getHistory();

    return Scaffold(
      appBar: AppBar(title: const Text('Task History')),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (_, index) {
          final todo = history[index];
          return TodoTile(
            todo: todo,
            onComplete: () {},
            onDelete: () {},
            showMeta: true,
          );
        },
      ),
    );
  }
}