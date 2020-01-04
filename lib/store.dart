import 'dart:convert';

import 'package:flutter_flux/flutter_flux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Person {
  Person(this.name);

  String name;
  List<Item> consumed = List<Item>();
}

class Item {
  Item(this.qty, this.name, this.value);

  int id;
  int qty;
  String name;
  double value;
}

final addPerson = Action<Person>();
final setPerson = Action<Person>();
final delPerson = Action<Person>();

final addItem = Action<Item>();
final setItem = Action<Item>();
final delItem = Action<Item>();

class SplitterStore extends Store {
  bool _loaded = false;

  List<Person> _people = List<Person>();
  List<Item> _items = List<Item>();

  List<Person> get people => _people;
  List<Item> get items => _items;

  SplitterStore() {
    _load();

    triggerOnAction(addPerson, (person) {
      _people.add(person);
      _people.sort((p1, p2) => p1.name.compareTo(p2.name));
      _save();
    });

    triggerOnAction(delPerson, (person) {
      _people.remove(person);
      _people.sort((p1, p2) => p1.name.compareTo(p2.name));
      _save();
    });

    triggerOnAction(setPerson, (person) {
      _people.remove(person);
      _people.add(person);
      _people.sort((p1, p2) => p1.name.compareTo(p2.name));
      _save();
    });

    triggerOnAction(addItem, (item) {
      _items.add(item);
      _items.sort((p1, p2) => p1.name.compareTo(p2.name));
      _save();
    });

    triggerOnAction(delItem, (item) {
      _items.remove(item);
      for (var person in _people) {
        person.consumed.remove(item);
        person.consumed.sort((p1, p2) => p1.name.compareTo(p2.name));
      }
      _items.sort((p1, p2) => p1.name.compareTo(p2.name));
      _save();
    });

    triggerOnAction(setItem, (item) {
      _items.remove(item);
      _items.add(item);
      _items.sort((p1, p2) => p1.name.compareTo(p2.name));
      _save();
    });
  }

  void _save() {
    int counter = 1;
    _items.forEach((i) => i.id = counter++);

    final items = _items
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'qty': i.qty,
              'value': i.value,
            })
        .toList();

    final people = _people
        .map((p) => {
              'name': p.name,
              'consumed': p.consumed.map((i) => i.id).toList(),
            })
        .toList();

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('items', jsonEncode(items));
      prefs.setString('people', jsonEncode(people));
    });
  }

  void _load() {
    if (!_loaded) {
      _loaded = true;

      SharedPreferences.getInstance().then((prefs) {
        if (!prefs.containsKey('items') || !prefs.containsKey('people')) return;

        List<dynamic> ts = jsonDecode(prefs.getString('items'));
        List<dynamic> ps = jsonDecode(prefs.getString('people'));

        _items = ts.map((i) {
          final item = Item(i['qty'], i['name'], i['value']);
          item.id = i['id'];
          return item;
        }).toList();

        _people = ps.map((p) {
          final person = Person(p['name']);
          for (final id in p['consumed']) {
            final item = _items.firstWhere((i) => i.id == id);
            person.consumed.add(item);
          }
          return person;
        }).toList();
      });
    }
  }
}

final StoreToken storeToken = StoreToken(SplitterStore());
