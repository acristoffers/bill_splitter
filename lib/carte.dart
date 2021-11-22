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

import 'dart:async';

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
  TextEditingController _qtyController = TextEditingController(text: '1');
  FocusNode _nameFocus = FocusNode();
  GlobalKey<AnimatedListState> _listView = GlobalKey();
  bool _storeLoaded = false;

  @override
  void initState() {
    super.initState();

    _store = listenToStore(storeToken);
    _store.triggerOnAction(addItem, (item) {
      if (_listView.currentState == null) return;
      final index = _store.items.indexOf(item);
      _listView.currentState.insertItem(index);
    });

    // The store is only available after the widget was created, so the items
    // are not available during construction. We then hook up a listener
    // and add the existing items the first time they come through.
    _store.listen((store) {
      if (!_storeLoaded) {
        for (final item in _store.items) {
          final index = _store.items.indexOf(item);
          _listView.currentState.insertItem(index);
        }
        _storeLoaded = true;
      }
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
              initialItemCount: 0, //_store.items.length,
              itemBuilder: (context, index, animation) {
                final item = _store.items[index];
                return _card(index, item, animation);
              },
            ),
          )
        ],
      ),
    );
  }

  Container _header() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.queue),
                    border: UnderlineInputBorder(),
                    labelText: 'Unidades',
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 8)),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.monetization_on),
                    border: UnderlineInputBorder(),
                    labelText: 'Preço',
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocus,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.tag_faces),
                    border: UnderlineInputBorder(),
                    labelText: 'Nome',
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  try {
                    final name = _nameController.text.trim();
                    final qty = int.parse(_qtyController.text.trim());
                    final price = double.parse(
                      _priceController.text.trim().replaceAll(',', '.'),
                    );

                    if (name.isNotEmpty) {
                      addItem(Item(qty, name, price));
                      _nameController.clear();
                      _priceController.clear();
                      _qtyController.text = '1';
                    }

                    _nameFocus.requestFocus();
                  } catch (_) {}
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(int index, Item item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
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
                      _listView.currentState.removeItem(
                        index,
                        (context, animation) {
                          return _card(index, item, animation);
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
                  itemCount: _store.people
                      .where((p) => p.consumed.contains(item))
                      .length,
                  itemBuilder: (context, index) {
                    final people = _store.people
                        .where((p) => p.consumed.contains(item))
                        .toList();

                    final person = people[index];
                    final count =
                        person.consumed.where((i) => i == item).length;
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
      ),
    );
  }
}
