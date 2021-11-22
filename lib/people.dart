/*
 * Copyright (c) 2020 Álan Crístoffer
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and / or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
  GlobalKey<AnimatedListState> _listView = GlobalKey();

  @override
  void initState() {
    super.initState();

    _store = listenToStore(storeToken);
    _store.triggerOnAction(addPerson, (person) {
      if (_listView.currentState == null) return;
      final index = _store.people.indexOf(person);
      _listView.currentState.insertItem(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.only(top: 66, left: 8, right: 8),
      child: Column(
        children: <Widget>[
          _header(),
          Expanded(
            child: AnimatedList(
              key: _listView,
              initialItemCount: _store.people.length,
              itemBuilder: (context, index, animation) {
                final person = _store.people[index];
                return _card(index, person, animation);
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
              key: Key('person_name'),
              controller: _nameController,
              focusNode: _nameFocus,
              onSubmitted: (name) {
                if (name.isNotEmpty) {
                  addPerson(Person(name.trim()));
                  _nameController.clear();
                }
                _nameFocus.requestFocus();
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: UnderlineInputBorder(),
                labelText: 'Nome',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isNotEmpty) {
                addPerson(Person(name));
                _nameController.clear();
              }
              _nameFocus.requestFocus();
            },
          )
        ],
      ),
    );
  }

  Widget _card(int index, Person person, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
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
                      _listView.currentState.removeItem(
                        index,
                        (context, animation) {
                          return _card(index, person, animation);
                        },
                      );
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
                    final count =
                        person.consumed.where((i) => i == item).length;
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
                        Expanded(
                          child: Text('${item.name} (x${item.qty}) x$count'),
                        ),
                        Container(child: Text(value.toStringAsFixed(2)))
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(child: Container()),
                  Text('Total: ${personTotal(person).toStringAsFixed(2)}'),
                ],
              )
            ],
          ),
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
