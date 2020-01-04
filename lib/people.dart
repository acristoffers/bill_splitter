import 'package:bill_splitter/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

class People extends StatefulWidget {
  @override
  _PeopleState createState() => _PeopleState();
}

class _PeopleState extends State<People> with StoreWatcherMixin<People> {
  SplitterStore _store;
  TextEditingController _nameController = TextEditingController();
  FocusNode _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _store = listenToStore(storeToken);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.only(top: 66, left: 8, right: 8),
      child: Column(
        children: <Widget>[
          _header(),
          Expanded(
            child: ListView.builder(
              itemCount: _store.people.length,
              itemBuilder: (context, index) {
                final person = _store.people[index];
                return _card(person);
              },
            ),
          ),
        ],
      ),
    );
  }

  Container _header() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocus,
        onSubmitted: (name) {
          if (name.isNotEmpty) {
            addPerson(Person(name));
            _nameController.clear();
          }
          _nameFocus.requestFocus();
        },
        decoration: InputDecoration(
          suffixIcon: Icon(Icons.add),
          border: UnderlineInputBorder(),
          labelText: 'Nome',
        ),
      ),
    );
  }

  Card _card(Person person) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: Text(person.name)),
                PopupMenuButton<Item>(
                  icon: Icon(Icons.add_shopping_cart),
                  onSelected: (item) {
                    person.consumed.add(item);
                    setPerson(person);
                  },
                  itemBuilder: (_) {
                    return _store.items
                        .map((i) => PopupMenuItem(
                              child: Text('${i.name} x${i.qty}'),
                              value: i,
                            ))
                        .toList();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    delPerson(person);
                  },
                )
              ],
            ),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: person.consumed.toSet().length,
                itemBuilder: (context, index) {
                  final items = person.consumed.toSet().toList();
                  items.sort((p1, p2) => p1.name.compareTo(p2.name));

                  final item = items[index];
                  final count = person.consumed.where((i) => i == item).length;
                  final total = _store.people
                      .map((p) => p.consumed.where((i) => i == item).length)
                      .fold(0, (a, e) => a + e);
                  final value = (count / total * item.value * item.qty);

                  return Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          person.consumed.remove(item);
                          setPerson(person);
                        },
                      ),
                      Expanded(child: Text('${item.name} x$count')),
                      Container(child: Text(value.toStringAsFixed(2)))
                    ],
                  );
                },
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(child: Container()),
                Text('R\$${personTotal(person).toStringAsFixed(2)}'),
              ],
            )
          ],
        ),
      ),
    );
  }

  double personTotal(Person person) {
    return person.consumed.map((item) {
      final count = person.consumed.where((i) => i == item).length;
      final total = _store.people
          .map((p) => p.consumed.where((i) => i == item).length)
          .fold(0, (a, e) => a + e);

      return count / total * item.value * item.qty;
    }).fold(0, (a, e) => a + e);
  }
}
