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
import 'package:bill_splitter/people.dart';
import 'package:bill_splitter/store.dart';
import 'package:flutter/material.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with TickerProviderStateMixin {
  Pages? _currentAnimation;
  Pages _currentPage = Pages.Menu;
  late AnimationController _animationController;
  late Animation<double> _a1;
  late Animation<double> _a2;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _a1 = _animationController.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ),
    );

    _a2 = _animationController.drive(
      Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.fastLinearToSlowEaseIn)),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, widget) {
            return Stack(
              children: <Widget>[
                _currentPage == Pages.People ? People() : Carte(),
                _carte(constraints),
                _people(constraints),
              ],
            );
          },
        );
      },
    );
  }

  Widget _people(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final maxHeight = constraints.maxHeight;

    double left = 0;
    double right = 0;
    double? bottom = _a1.value == 0 ? 0 : null;
    double? height = _a1.value == 0 ? null : _interpol(_a1.value, maxHeight, 58);
    CustomClipper<Path> clipper = _PersonOutClipper(_a1.value);

    if (_currentAnimation == Pages.Carte) {
      left = 0;
      right = 0;
      bottom = 0;
      height = null;
      clipper = _CarteOutClipper(_a1.value);
    }

    return Positioned(
      top: 0,
      left: left,
      right: right,
      bottom: bottom,
      height: height,
      child: ClipPath(
        clipper: clipper,
        child: GestureDetector(
          onTap: () {
            if (_currentPage == Pages.Menu) {
              _currentPage = Pages.People;
              _currentAnimation = Pages.People;
              _animationController.forward();
            } else {
              _currentPage = Pages.Menu;
              _animationController.reverse();
            }
            setPage(_currentPage);
          },
          child: Container(
            key: Key('PeopleMenuOption'),
            color: Colors.deepPurple,
            padding: EdgeInsets.only(
              top: _interpol(_a2.value, 0.25 * maxHeight, 8),
              left: _interpol(_a2.value, 0.25 * maxWidth, 8),
            ),
            child: Text(
              'Pessoas',
              style: TextStyle(fontSize: 36, color: Colors.greenAccent),
            ),
            constraints: BoxConstraints.expand(),
          ),
        ),
      ),
    );
  }

  Widget _carte(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;
    final maxHeight = constraints.maxHeight;

    double left = 0;
    double right = 0;
    double? bottom = _a1.value == 0 ? 0 : null;
    double? height = _a1.value == 0 ? null : _interpol(_a1.value, maxHeight, 58);

    if (_currentAnimation == Pages.People) {
      left = _interpol(_a1.value, 0, -maxWidth);
      right = _interpol(_a1.value, 0, maxWidth);
      bottom = 0;
      height = null;
    }

    return Positioned(
      top: 0,
      left: left,
      right: right,
      bottom: bottom,
      height: height,
      child: GestureDetector(
        onTap: () {
          if (_currentPage == Pages.Menu) {
            _currentPage = Pages.Carte;
            _currentAnimation = Pages.Carte;
            _animationController.forward();
          } else {
            _currentPage = Pages.Menu;
            _animationController.reverse();
          }
          setPage(_currentPage);
        },
        child: Container(
          key: Key('CarteMenuOption'),
          color: Colors.deepOrange,
          padding: EdgeInsets.only(
            top: _interpol(_a1.value, 0.75 * maxHeight, 8),
            left: _interpol(_a1.value, 0.50 * maxWidth, 8),
          ),
          child: Text(
            'Cardápio',
            style: TextStyle(fontSize: 36, color: Colors.yellowAccent),
          ),
          constraints: BoxConstraints.expand(),
        ),
      ),
    );
  }

  double _interpol(double i, double start, double end) {
    return start + (end - start) * i;
  }
}

enum Pages { People, Carte, Menu }

class _CarteOutClipper extends CustomClipper<Path> {
  _CarteOutClipper(this._i);

  double _i;

  @override
  getClip(Size size) {
    final w = 1.2 * size.width + _i * (-1.2 * size.width);
    final h = 0.8 * size.height;

    final path = Path()
      ..lineTo(w, 0)
      ..lineTo(0, h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper _) {
    return true;
  }
}

class _PersonOutClipper extends CustomClipper<Path> {
  _PersonOutClipper(this._i);

  double _i;

  @override
  getClip(Size size) {
    final w = size.width + (1.0 - _i) * (0.2 * size.width);
    final h = _i * 58;
    final h2 = 58 + (1.0 - _i) * (0.8 * size.height - 58);

    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(w, h)
      ..lineTo(0, h2)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper _) {
    return true;
  }
}
