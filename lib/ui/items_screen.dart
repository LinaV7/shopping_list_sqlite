import 'package:flutter/material.dart';
import '../models/list_items.dart';
import '../models/shopping_list.dart';
import '../util/dbhelper.dart';

import 'package:shopping_list/ui/list_item_dialog.dart';

class ItemsScreen extends StatefulWidget {
  final ShoppingList shoppingList;
  late List<ListItem> items = [];
  ItemsScreen(this.shoppingList, {super.key});
  @override
  _ItemsScreenState createState() => _ItemsScreenState(
        this.shoppingList,
        this.items,
      );
}

class _ItemsScreenState extends State<ItemsScreen> {
  ShoppingList shoppingList;
  late List<ListItem> items;
  _ItemsScreenState(this.shoppingList, this.items);
  late DbHelper helper;
  ListItemDialog dialog = ListItemDialog();

  @override
  Widget build(BuildContext context) {
    helper = DbHelper();
    showData(this.shoppingList.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(shoppingList.name),
      ),
      body: ListView.builder(
          itemCount: (items != null) ? items.length : 0,
          itemBuilder: (BuildContext context, int index) {
            return Dismissible(
                key: Key(items[index].name),
                onDismissed: (direction) {
                  String strName = items[index].name;
                  helper.deleteItem(items[index]);
                  setState(() {
                    items.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$strName deleted")));
                },
                child: ListTile(
                  title: Text(items[index].name),
                  subtitle: Text(
                      'Quantity: ${items[index].quantity} - Note:  ${items[index].note}'),
                  onTap: () {},
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              dialog.buildAlert(context, items[index], false));
                    },
                  ),
                ));
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => dialog.buildAlert(
                context,
                ListItem(
                  0,
                  shoppingList.id,
                  '',
                  '',
                  '',
                ),
                true),
          );
        },
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showData(int idList) async {
    try {
      await helper.openDb();

      items = await helper.getItems(idList);

      setState(() {
        items = items;
      });
    } catch (e) {
      print('Ошибка при загрузке данных: $e');
    }
  }
}
