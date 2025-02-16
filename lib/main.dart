import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import './util/dbhelper.dart';
import './models/shopping_list.dart';
import './ui/items_screen.dart';
import './ui/shopping_list_dialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  ShoppingListDialog dialog = ShoppingListDialog();

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Shoppping List',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ShList());
  }
}

class ShList extends StatefulWidget {
  const ShList({super.key});

  @override
  _ShListState createState() => _ShListState();
}

class _ShListState extends State<ShList> {
  late List<ShoppingList> shoppingList = [];
  DbHelper helper = DbHelper();
  late ShoppingListDialog dialog;
  @override
  void initState() {
    dialog = ShoppingListDialog();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showData();

    List<ShoppingList> sortedList = List.from(shoppingList);
    sortedList.sort((a, b) => a.priority.compareTo(b.priority));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
      ),
      body: ListView.builder(
          itemCount: (sortedList != null) ? sortedList.length : 0,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
                key: Key(sortedList[index].id.toString()),
                onDismissed: (direction) {
                  String strName = sortedList[index].name;
                  helper.deleteList(sortedList[index]);
                  setState(() {
                    shoppingList
                        .removeWhere((item) => item.id == sortedList[index].id);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$strName deleted")));
                },
                child: ListTile(
                    title: Text(sortedList[index].name),
                    leading: CircleAvatar(
                      child: Text(sortedList[index].priority.toString()),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ItemsScreen(sortedList[index])),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                dialog.buildDialog(
                                    context, sortedList[index], false));
                      },
                    )));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                dialog.buildDialog(context, ShoppingList(0, '', 0), true),
          );
        },
        backgroundColor: Colors.pinkAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showData() async {
    try {
      await helper.openDb();
      final List<ShoppingList> lists = await helper.getLists();

      setState(() {
        shoppingList = lists;
      });
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
    }
  }
}
