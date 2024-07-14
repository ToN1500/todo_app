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
    final response = await http.post(Uri.parse(API_URL),
        body: json.encode({'title': task.text}),
        headers: {
          'Content-Type': 'application/json',
        });
    if (response.statusCode == 201) {
      print('Add todo success');
      fetchTodoList().then((value) {
        print(value);
        setState(() {
          todoList = value;
        });
      });
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<void> deleteTodoList(int todoId) async {
    final url = Uri.parse('$API_URL/$todoId');
    final response = await http.delete(url);

    if (response.statusCode == 204) {
      print('Delete todo success');
      fetchTodoList().then((value) {
        setState(() {
          todoList = value;
        });
      });
    } else {
      throw Exception('Failed to delete todo');
    }
  }

  Future<void> editTodoList(int todoId) async {
    final url = Uri.parse('$API_URL/$todoId');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      print('edit todo success');
      fetchTodoList().then((value) {
        setState(() {
          todoList = value;
        });
      });
    } else {
      throw Exception('Failed to edit todo');
    }
  }

  @override
  initState() {
    super.initState();
    fetchTodoList().then((value) {
      print(value);
      setState(() {
        todoList = value;
      });
    });
  }

  List todoList = [];

  final task = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isChecked = false;

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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // deleteTodoList(todoList[index]['id']);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      scrollable: true,
                                      title: Text('แก้ไขรายการ'),
                                      content: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Form(
                                          child: Column(
                                            children: <Widget>[
                                              TextFormField(
                                                decoration: InputDecoration(
                                                  labelText: 'สิ่งที่ต้องทำ',
                                                  border: OutlineInputBorder(),
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Checkbox(
                                                    value: isChecked,
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        isChecked = newValue!;
                                                      });
                                                    },
                                                  ),
                                                  Text('ทำสำเร็จแล้ว'),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              ElevatedButton(
                                                onPressed: addTodoList,
                                                child: Text('แก้ไข'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteTodoList(todoList[index]['id']);
                          },
                        ),
                      ],
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
