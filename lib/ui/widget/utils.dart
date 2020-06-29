import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


String Function(String) basicValidator = (value) => value == null || value.isEmpty ? "Invalid" : null;

class BasicScrollWithoutGlow extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}


// source : https://stackoverflow.com/questions/58360989/programmatically-lighten-or-darken-a-hex-color-in-dart
class ColorTransformation {
  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}


class RandomColorGenerator {
  static List<Color> _colors = [
    Colors.red, Colors.teal, Colors.blue, Colors.brown, 
    Colors.cyan, Colors.green, Colors.indigo, Colors.lime, Colors.orange, 
    Colors.pink, Colors.purple
  ];
  static int _last = 0;
  
  static Color generate() {
    _last += 1;
    return _colors.elementAt(_last);
  }
}


class SnackBarFactory {

  SnackBarFactory._();
  
  static showSuccessSnackbar({@required context, @required message}) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      )
    );
  }

  static showErrorSnabar({@required context, @required message}) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      )
    );
  }
}

