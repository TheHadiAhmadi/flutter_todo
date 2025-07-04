import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade800),
      ),
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<StatefulWidget> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final todos = [
    {"id": "todo-1", "order": 1, "title": "Todo 1", "done": false},
    {"id": "todo-2", "order": 2, "title": "Todo 2", "done": false},
    {"id": "todo-3", "order": 3, "title": "Todo 3", "done": false},
    {"id": "todo-4", "order": 4, "title": "Todo 4", "done": true},
  ];

  void test() {
    print('this is test');
  }

  void onChanged(id, title, done) {
    print('this is onChanged ' + id);
    var index = todos.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      setState(() {
        todos[index]['done'] = done;
        todos[index]['title'] = title;
      });
    }
  }

  void onSave(String text) {
    setState(() {
      todos.add({
        "id": 'todo-${DateTime.now().millisecondsSinceEpoch}',
        "order": todos.length + 1,
        "title": text,
        "done": false,
      });
      todos.sort((a, b) => (a["order"] as int).compareTo(b["order"] as int));
    });
  }

  @override
  build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(onPressed: test, icon: Icon(Icons.menu)),
        title: Text("Hello"),
        actions: [IconButton(onPressed: test, icon: Icon(Icons.search))],
      ),
      body: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) => {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = todos.removeAt(oldIndex);
            todos.insert(newIndex, item);

            for (int i = 0; i < todos.length; i++) {
              todos[i]["order"] = i + 1;
            }
          }),
        },
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoItem(
            key: ValueKey(todo['id']),
            id: todo["id"] as String,
            title: todo['title'] as String,
            done: todo['done'] as bool,
            onChanged: onChanged,
          );
        },
      ),
      floatingActionButton: EditTodoButton(
        onSave: onSave,
        text: "",
        icon: Icon(Icons.add),
      ),
    );
  }
}

class EditTodoButton extends StatelessWidget {
  EditTodoButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onSave,
  });

  final onSave;
  final String text;
  final Icon icon;

  void onOpenModal(context) {
    print('Open modal');
    TextEditingController controller = TextEditingController(text: text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Save"),
              onPressed: () {
                print(controller.text);
                onSave(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter todo title...'),
          ),
        );
      },
    );
  }

  @override
  build(BuildContext context) {
    return Container(
      decoration: text == ''
          ? BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            )
          : null,
      child: IconButton(
        onPressed: () => onOpenModal(context),
        icon: icon,
        color: text == '' ? Colors.white : null,
      ),
    );
  }
}

class TodoItem extends StatelessWidget {
  const TodoItem({
    super.key,
    required this.id,
    required this.title,
    required this.done,
    required this.onChanged,
  });

  final String id;
  final bool done;
  final String title;
  final onChanged;

  void onSave(String text) {
    onChanged(id, text, done);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(id, title, !done);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.circle_outlined,
              color: done ? Colors.grey.shade400 : Colors.black,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: done ? Colors.grey : Colors.black,
                  decoration: done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            EditTodoButton(onSave: onSave, text: title, icon: Icon(Icons.edit)),
            SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
