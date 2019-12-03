import 'package:flutter/material.dart';

class InfluxDBColorScheme {
  final int size;
  List<Color> themeColors = [
    Color(_hexStringToHexInt("#31C0F6")),
    Color(_hexStringToHexInt("#A500A5")),
    Color(_hexStringToHexInt("#FF7E27"))
  ];

  InfluxDBColorScheme({@required this.size, this.themeColors});

  InfluxDBColorScheme.fromAPIData(
      {@required this.size, List<dynamic> colorData}) {
    if (colorData != null) {
      colorData.forEach((dynamic c) {
        themeColors.add(Color(_hexStringToHexInt(c["hex"])));
      });
    }
  }

  Color operator [](int index) {
    if (size < 1) return themeColors[0];
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