import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_dapp/todolist/todo_model.dart';
import 'package:todo_dapp/todolist/todo_view.dart';

void main() {
  runApp(const TodoListDapp());
}

class TodoListDapp extends StatelessWidget {
  const TodoListDapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoModel(),
      child: MaterialApp(
        title: "Todo List Dapp",
        home: TodoListView(),
      ),
    );
  }
}
