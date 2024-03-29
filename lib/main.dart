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

import 'package:bill_splitter/carte.dart';
import 'package:bill_splitter/menu.dart';
import 'package:bill_splitter/people.dart';
import 'package:bill_splitter/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flux/flutter_flux.dart';

void main() => runApp(Application());

class Application extends StatefulWidget {
  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application>
    with StoreWatcherMixin<Application> {
  late SplitterStore _store;

  @override
  void initState() {
    super.initState();

    _store = listenToStore(storeToken) as SplitterStore;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Split',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: _store.page == Pages.Carte
              ? Colors.deepOrange
              : Colors.deepPurple,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return _tabletLayout();
                } else {
                  return Menu();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Flex _tabletLayout() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Flexible(
          child: Stack(
            children: [
              People(),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.deepPurple,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Pessoas',
                    style: TextStyle(fontSize: 36, color: Colors.greenAccent),
                  ),
                ),
              )
            ],
          ),
        ),
        Flexible(
          child: Stack(
            children: [
              Carte(),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.deepOrange,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Cardápio',
                    style: TextStyle(fontSize: 36, color: Colors.yellowAccent),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
