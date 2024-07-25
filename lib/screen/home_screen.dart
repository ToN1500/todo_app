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

  Future<void> editTodoList(int todoId, String title, bool completed) async {
    final url = Uri.parse('$API_URL/$todoId');
    final response = await http.put(
      url,
      body: json.encode({'title': title, 'completed': completed}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Edit todo success');
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
  final task2 = TextEditingController();

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
                    onPressed: () {
                      if (task.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('กรุณากรอกข้อมูล'),
                          ),
                        );
                        return;
                      }
                      addTodoList();
                      task.clear();
                    },
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
                itemCount: todoList.length,
                itemBuilder: (context, index) {
                  bool isChecked = todoList[index]['completed'];
                  TextEditingController editTaskController =
                      TextEditingController(text: todoList[index]['title']);

                  return Container(
                    color: isChecked ? Colors.grey[200] : null,
                    child: ListTile(
                      title: Text(
                        todoList[index]['title'],
                      ),
                      titleTextStyle:
                          TextStyle(color: Colors.black, fontSize: 15),
                      subtitle: Text(
                        todoList[index]['completed'] == true
                            ? ' ทำแล้ว'
                            : ' ยังไม่ได้ทำ',
                      ),
                      subtitleTextStyle: TextStyle(
                        color: todoList[index]['completed'] == true
                            ? Colors.green
                            : Colors.red,
                        fontSize: 12,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              bool editCompleted = todoList[index]['completed'];
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        scrollable: true,
                                        title: Text('แก้ไขรายการ'),
                                        content: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Form(
                                            child: Column(
                                              children: <Widget>[
                                                TextFormField(
                                                  controller:
                                                      editTaskController,
                                                  decoration: InputDecoration(
                                                    labelText: 'สิ่งที่ต้องทำ',
                                                    border:
                                                        OutlineInputBorder(),
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
                                                      value: editCompleted,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          editCompleted =
                                                              newValue!;
                                                        });
                                                      },
                                                    ),
                                                    Text('ทำเสร็จแล้ว'),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (editTaskController
                                                        .text.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'กรุณากรอกข้อมูล'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    editTodoList(
                                                      todoList[index]['id'],
                                                      editTaskController.text,
                                                      editCompleted,
                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('แก้ไข'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
