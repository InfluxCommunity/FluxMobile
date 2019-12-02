import 'package:flutter/material.dart';

class InfluxDBColorScheme {
  final int size;
  final List<dynamic> colorData;

  InfluxDBColorScheme(this.size, this.colorData);

  Color operator [] (int index){
    return Colors.black;
  }


}

    // List<Color> colors, int seriesIndex, int seriesCount) {
    // if (seriesCount < 1 || colors.length < 2) {
    //   return colors[0];
    // }
    // double t = ((colors.length - 1.0) * seriesIndex) / seriesCount;
    // int i = t.floor();
    // if (i == colors.length - 1) {
    //   i -= 1;
    // }
    // return HSVColor.lerp(
    //   HSVColor.fromColor(colors[i]),
    //   HSVColor.fromColor(colors[i + 1]),
    //   t - i,
    // ).toColor();