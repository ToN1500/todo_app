import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String API_URL = 'http://127.0.0.1:5001/todos';

  Future<List> fetchTodoList() async {
    final response = await http.get(Uri.parse(API_URL));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> addTodoList() async {
    final res = await http.post(Uri.parse(API_URL),
        body: json.encode({'title': task.text}),
        headers: {
          'Content-Type': 'application/json',
        });
    if (res.statusCode == 201) {
      print('Add todo success');
      fetchTodoList().then((value) {
        setState(() {
          todoList = value;
        });
      });
    }
  }

  // Futrue<void> deleteTodoList() async {
  //   final res = await http.delete(Uri.parse(API_URL));
  // }

  @override
  initState() {
    super.initState();
    fetchTodoList().then((value){
      print(value);
      setState(() {
        todoList = value;
      });
    });
  }

  List todoList = [];

  final task = TextEditingController();

  // void addTodo() {
  //   setState(() {
  //     todoList.add(task.'title');
  //     task.clear();
  //   });
  // }

  void editTodo() {}

  void deleteTodo(index) {
    setState(() {
      todoList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: task,
                    decoration: InputDecoration(
                      labelText: 'สิ่งที่ต้องทำ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: addTodoList,
                    child: Text('เพิ่ม'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(todoList[index]['title']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        deleteTodo(index);
                      },
                    ),
                  );
                },
                itemCount: todoList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
