import 'package:bill_splitter/carte.dart';
import 'package:bill_splitter/menu.dart';
import 'package:bill_splitter/people.dart';
import 'package:flutter/material.dart';

void main() => runApp(Application());

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Split',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
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
                                  style: TextStyle(
                                      fontSize: 36, color: Colors.greenAccent),
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
                                  style: TextStyle(
                                      fontSize: 36, color: Colors.yellowAccent),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
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
}
