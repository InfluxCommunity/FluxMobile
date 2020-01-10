import 'package:flutter/material.dart';

/// Class to manage color schemes in a manner similar to how colors work in InfluxDB UI dashboards.
class InfluxDBColorScheme {
  /// Number of colors that the scheme should be able to produce.
  final int size;
  /// [List[] of [Color]s that define a default theme, using 3 predefined colors.
  final List<Color> _defaultThemeColors = [
    Color(_hexStringToHexInt("#31C0F6")),
    Color(_hexStringToHexInt("#A500A5")),
    Color(_hexStringToHexInt("#FF7E27"))
  ];

  /// [List[] of [Color]s that define a theme. 
  List<Color> themeColors = [];

  /// Creates an instance of [InfluxDBColorScheme], by passing number of elements that it
  /// should render and list of colors that the theme should be based on.
  InfluxDBColorScheme({@required this.size, this.themeColors}) {
    _setThemeColors();
  }

  /// Initializes an instance of [InfluxDBColorScheme] by passing number of elements that it
  /// should render and [List] of colors from parsed JSON data from API call.
  InfluxDBColorScheme.fromAPIData(
      {@required this.size, List<dynamic> colorData}) {
    if (colorData != null) {
      colorData.forEach((dynamic c) {
        themeColors.add(Color(_hexStringToHexInt(c["hex"])));
      });
    }
    _setThemeColors();
  }

  /// Creates a new instance of [InfluxDBColorScheme] by changing the number of colors that it should render.
  InfluxDBColorScheme withSize(int size) {
    return InfluxDBColorScheme(size: size, themeColors: themeColors);
  }

  _setThemeColors() {
    if (themeColors == null) themeColors = _defaultThemeColors;
  }

  /// Getter to obtain a specific color by passing number of color. The `index` should be between `0 and `size - 1`.
  Color operator [](int index) {
    if (size < 4) return themeColors[index];
    if (index <= 0) return themeColors[0];
    if (index >= size - 1) return (themeColors[themeColors.length - 1]);

    double t = ((themeColors.length - 1) * index) / size;
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
