import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_dapp/todolist/todo_model.dart';

class TodoListView extends StatelessWidget {
  TodoListView({Key? key}) : super(key: key);

  final tController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var listModel = Provider.of<TodoModel>(context);
    return listModel.isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text("TODOLIST"),
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: ListView.builder(
                    itemCount: listModel.todos.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(listModel.todos[index].taskName),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tController,
                        ),
                        flex: 5,
                      ),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            listModel.addTask(tController.text);
                          },
                          child: const Text("Add"),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
