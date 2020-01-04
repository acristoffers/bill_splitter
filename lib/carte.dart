import 'package:bill_splitter/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_flux/flutter_flux.dart';

class Carte extends StatefulWidget {
  @override
  _CarteState createState() => _CarteState();
}

class _CarteState extends State<Carte> with StoreWatcherMixin<Carte> {
  SplitterStore _store;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();
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
              itemCount: _store.items.length,
              itemBuilder: (context, index) {
                final item = _store.items[index];
                return _card(item);
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Unidades',
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 8)),
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocus,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Nome',
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(left: 8)),
          Expanded(
            child: TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Preço',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              try {
                final name = _nameController.text;
                final price = double.parse(_priceController.text);
                final qty = int.parse(_qtyController.text);

                if (name.isNotEmpty) {
                  addItem(Item(qty, name, price));
                  _nameController.clear();
                  _priceController.clear();
                  _qtyController.text = '1';
                }

                _nameFocus.requestFocus();
              } catch (_) {}
            },
          )
        ],
      ),
    );
  }

  Card _card(Item item) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${item.name} (R\$${item.value.toStringAsFixed(2)} x${item.qty} R\$${(item.value * item.qty).toStringAsFixed(2)})',
                  ),
                ),
                PopupMenuButton<Person>(
                  icon: Icon(Icons.add_shopping_cart),
                  onSelected: (person) {
                    person.consumed.add(item);
                    setPerson(person);
                  },
                  itemBuilder: (_) {
                    return _store.people
                        .map((p) => PopupMenuItem(
                              child: Text(p.name),
                              value: p,
                            ))
                        .toList();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    delItem(item);
                  },
                )
              ],
            ),
            Container(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _store.people
                    .where((p) => p.consumed.contains(item))
                    .length,
                itemBuilder: (context, index) {
                  final people = _store.people
                      .where((p) => p.consumed.contains(item))
                      .toList();

                  final person = people[index];
                  final count = person.consumed.where((i) => i == item).length;
                  final total = people
                      .map((p) => p.consumed.where((i) => i == item).length)
                      .fold(0, (a, e) => a + e);
                  final value = (count / total * item.value * item.qty);

                  return Container(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            person.consumed.remove(item);
                            setPerson(person);
                          },
                        ),
                        Expanded(child: Text('${person.name} x$count')),
                        Container(child: Text(value.toStringAsFixed(2)))
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}