import 'package:flutter/material.dart';

class InfluxDBColorScheme {
  final int size;
  final List<Color> _defaultThemeColors = [
    Color(_hexStringToHexInt("#31C0F6")),
    Color(_hexStringToHexInt("#A500A5")),
    Color(_hexStringToHexInt("#FF7E27"))
  ];
  List<Color> themeColors = [];

  InfluxDBColorScheme({@required this.size, this.themeColors}) {
    _setThemeColors();
  }

  InfluxDBColorScheme.fromAPIData(
      {@required this.size, List<dynamic> colorData}) {
    if (colorData != null) {
      colorData.forEach((dynamic c) {
        themeColors.add(Color(_hexStringToHexInt(c["hex"])));
      });
    }
    _setThemeColors();
  }

  InfluxDBColorScheme withSize(int size) {
    return InfluxDBColorScheme(size: size, themeColors: themeColors);
  }

  _setThemeColors() {
    if (themeColors == null) themeColors = _defaultThemeColors;
  }

  Color operator [](int index) {
    if (size < 4) return themeColors[index];
    if (index == 0) return themeColors[0];
    if (index == size - 1) return (themeColors[2]);

    double t = (2 * index) / size;
    int i = t.floor();
    if (i == 2) i = 1;

    return HSVColor.lerp(HSVColor.fromColor(themeColors[i]),
            HSVColor.fromColor(themeColors[i + 1]), t - i)
        .toColor();
  }

  static int _hexStringToHexInt(String hex) {
    hex = hex.replaceFirst('#', '');
    hex = hex.length == 6 ? 'ff' + hex : hex;
    int val = int.parse(hex, radix: 16);
    return val;
  }
}
