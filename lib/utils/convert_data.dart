import 'package:flybuy/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// This is utility convert data for app
///
class ConvertData {
  /// This helper function convert any value to `double`
  ///
  static double stringToDouble(dynamic value, [double defaultValue = 0]) {
    if (value == null || value == "") {
      return defaultValue;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }

    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  /// This helper function convert any value to `double` and `null`
  ///
  /// In some case we need this, like when both value `double` and `null` accepted
  /// If you want always return `double` value try function [stringToDouble] instead
  ///
  static double? stringToDoubleCanBeNull(dynamic value,
      [double? defaultValue]) {
    if (value == null || value == "") {
      return defaultValue;
    }

    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  /// Convert String to int
  static int stringToInt([dynamic value = '0', int initValue = 0]) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? initValue;
    }
    return initValue;
  }

  /// This helper function convert any value to `int` and `null`
  ///
  /// In some case we need this, like when both value `int` and `null` accepted
  /// If you want always return `int` value try function [stringToInt] instead
  ///
  static int? stringToIntCanBeNull(dynamic value, [int? defaultValue]) {
    if (value == null || value == "") {
      return defaultValue;
    }

    if (value is double) {
      return value.toInt();
    }

    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }

    return defaultValue;
  }

  /// Convert any value to bool or null
  static bool? toBoolValue(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value == "true" || value == 1 || value == "1") {
      return true;
    }

    if (value == "false" || value == 0 || value == "0") {
      return false;
    }
    return null;
  }

  static Color fromRgba(String rgbaString) {
    if (rgbaString == "" || rgbaString.substring(0, 5) != 'rgba(') {
      return Colors.black;
    }

    List textNumber = rgbaString.substring(5, rgbaString.length - 1).split(',');
    int r = stringToInt(textNumber[0], 255);
    int g = stringToInt(textNumber[1], 255);
    int b = stringToInt(textNumber[2], 255);
    double o = stringToDouble(textNumber[3], 1);

    return Color.fromRGBO(r, g, b, o);
  }

  /// Create a color from red, green, blue, and opacity
  static Color fromRGBA(Map? color, [defaultColor]) {
    if (color is! Map<String, dynamic> ||
        color['r'] == null ||
        color['g'] == null ||
        color['b'] == null) {
      return defaultColor ?? Colors.white;
    }

    int r = color['r'].toInt();
    int? g = color['g'].toInt();
    int? b = color['b'].toInt();
    double? a = color['a'] == null ? 1 : color['a'].toDouble();

    if (r < 0 || r > 255) return defaultColor ?? Colors.white;
    if (g! < 0 || g > 255) return defaultColor ?? Colors.white;
    if (b! < 0 || b > 255) return defaultColor ?? Colors.white;
    return Color.fromRGBO(r, g, b, a!);
  }

  ///
  /// Convert color from hex
  static Color? fromHex(String hex, [defaultColor = Colors.white]) {
    if (!RegExp(r'^#+([a-fA-F0-9]{6}|[a-fA-F0-9]{5}|[a-fA-F0-9]{3})$')
        .hasMatch(hex)) {
      return defaultColor;
    }
    String color = hex.replaceAll('#', '');
    String value = color.length == 6 ? color : '';
    if (value.length != 6) {
      if (color.length == 3) {
        for (int i = 0; i < color.length; i++) {
          value = '$value${color[i]}${color[i]}';
        }
      } else if (color.length == 5) {
        value = '${color.substring(0, 4)}0${color[4]}';
      }
    }
    return Color(int.parse('0xff$value'));
  }

  static String fromColor(Color color) {
    String hex = color.value.toRadixString(16);

    return '#${hex.substring(2)}';
  }

  // Get FontWeight to string
  static FontWeight fontWeight(dynamic value) {
    if (value is! String) {
      return FontWeight.normal;
    }
    switch (value) {
      case '100':
        return FontWeight.w100;
      case '200':
        return FontWeight.w200;
      case '300':
        return FontWeight.w300;
      case '400':
        return FontWeight.w400;
      case '500':
        return FontWeight.w500;
      case '600':
        return FontWeight.w600;
      case '700':
        return FontWeight.w700;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      default:
        return FontWeight.normal;
    }
  }

  static TextDecoration toTextDecoration(dynamic value) {
    switch (value) {
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'line-through':
        return TextDecoration.lineThrough;
      default:
        return TextDecoration.none;
    }
  }

  // Get TextStyle to text component
  static TextStyle toTextStyle(
      [dynamic value, String? themeModeKey = 'value']) {
    TextStyle style = const TextStyle();
    if (value is Map && value['style'] is Map<String, dynamic>) {
      Map<String, dynamic> styleComponent = value['style'];
      if (styleComponent['fontSize'] is String ||
          styleComponent['fontSize'] is double ||
          styleComponent['fontSize'] is int) {
        double? fontSize = stringToDouble(styleComponent['fontSize']);
        style = style.copyWith(fontSize: fontSize);
      }
      if (styleComponent['color'] is Map &&
          styleComponent['color'][themeModeKey] is Map) {
        Color color = fromRGBA(styleComponent['color'][themeModeKey]);
        style = style.copyWith(color: color);
      }
      if (styleComponent['backgroundColor'] is Map &&
          styleComponent['backgroundColor'][themeModeKey] is Map) {
        Color background =
            fromRGBA(styleComponent['backgroundColor'][themeModeKey]);
        style = style.copyWith(backgroundColor: background);
      }
      if (styleComponent['fontWeight'] is String &&
          styleComponent['fontWeight'] != '') {
        style = style.copyWith(
            fontWeight: fontWeight(styleComponent['fontWeight']));
      }
      if (styleComponent['textDecoration'] is String &&
          styleComponent['fontFamily'] != '') {
        TextDecoration decoration =
            toTextDecoration(styleComponent['textDecoration']);
        style = style.copyWith(decoration: decoration);
      }
      if (styleComponent['letterSpacing'] is double ||
          styleComponent['letterSpacing'] is int ||
          (styleComponent['letterSpacing'] is String &&
              styleComponent['letterSpacing'] != '')) {
        double letterSpacing = stringToDouble(styleComponent['letterSpacing']);
        if (letterSpacing >= 0) {
          style = style.copyWith(letterSpacing: letterSpacing);
        }
      }
      if (styleComponent['height'] is double ||
          styleComponent['height'] is int ||
          (styleComponent['height'] is String &&
              styleComponent['letterSpacing'] != '')) {
        double height = stringToDouble(styleComponent['height']);
        if (height > 0) {
          style = style.copyWith(height: height);
        }
      }
      if (styleComponent['fontFamily'] is String &&
          styleComponent['fontFamily'] != '') {
        style =
            GoogleFonts.getFont(styleComponent['fontFamily'], textStyle: style);
      }
    }
    return style;
  }

  static TextAlign toTextAlign(String? value) {
    switch (value) {
      case 'left':
        return TextAlign.left;
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'justify':
        return TextAlign.justify;
      case 'end':
        return TextAlign.end;
      default:
        return TextAlign.start;
    }
  }

  static TextAlign toTextAlignDirection(String? value) {
    switch (value) {
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      case 'right':
      case 'end':
        return TextAlign.end;
      default:
        return TextAlign.start;
    }
  }

  static Alignment toAlignment(dynamic value) {
    switch (value) {
      case 'bottom-center':
        return Alignment.bottomCenter;
      case 'top-center':
        return Alignment.topCenter;
      case 'center-left':
        return Alignment.centerLeft;
      case 'bottom-left':
        return Alignment.bottomLeft;
      case 'center-right':
        return Alignment.centerRight;
      case 'bottom-right':
        return Alignment.bottomRight;
      case 'top-left':
        return Alignment.topLeft;
      case 'top-right':
        return Alignment.topRight;
      default:
        return Alignment.center;
    }
  }

  static AlignmentDirectional toAlignmentDirectional(dynamic value) {
    switch (value) {
      case 'bottom-center':
        return AlignmentDirectional.bottomCenter;
      case 'top-center':
        return AlignmentDirectional.topCenter;
      case 'center-left':
      case 'center-start':
        return AlignmentDirectional.centerStart;
      case 'bottom-left':
      case 'bottom-start':
        return AlignmentDirectional.bottomStart;
      case 'center-right':
      case 'center-end':
        return AlignmentDirectional.centerEnd;
      case 'bottom-right':
      case 'bottom-end':
        return AlignmentDirectional.bottomEnd;
      case 'top-left':
      case 'top-start':
        return AlignmentDirectional.topStart;
      case 'top-right':
      case 'top-end':
        return AlignmentDirectional.topEnd;
      default:
        return AlignmentDirectional.center;
    }
  }

  static String textFromConfigs([dynamic value, String languageKey = 'text']) {
    if (value is String) {
      return value;
    }
    if (value is Map<String, dynamic> && value[languageKey] is String) {
      return value[languageKey];
    }
    return '';
  }

  static String? imageFromConfigs([dynamic value, String imageKey = "src"]) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is Map<String, dynamic> &&
        value[imageKey] is String &&
        (value[imageKey]).isNotEmpty) {
      return value[imageKey];
    }
    return null;
  }

  static EdgeInsetsDirectional space(
    Map? data, [
    String key = 'padding',
    EdgeInsetsDirectional defaultValue = defaultScreenPadding,
  ]) {
    if (data == null) return defaultValue;

    return EdgeInsetsDirectional.only(
      start: catchNegativeValue(ConvertData.stringToDouble(data['${key}Left'])),
      end: catchNegativeValue(ConvertData.stringToDouble(data['${key}Right'])),
      top: catchNegativeValue(ConvertData.stringToDouble(data['${key}Top'])),
      bottom:
          catchNegativeValue(ConvertData.stringToDouble(data['${key}Bottom'])),
    );
  }

  static BorderRadius corn(
    dynamic data, [
    BorderRadius defaultValue = BorderRadius.zero,
  ]) {
    if (data is BorderRadius) return data;
    if (data is double || data is int || data is String)
      return BorderRadius.circular(ConvertData.stringToDouble(data));
    if (data == null || data is! Map) return defaultValue;

    return BorderRadius.only(
      topLeft: Radius.circular(ConvertData.stringToDouble(data['topLeft'])),
      topRight: Radius.circular(ConvertData.stringToDouble(data['topRight'])),
      bottomLeft:
          Radius.circular(ConvertData.stringToDouble(data['bottomLeft'])),
      bottomRight:
          Radius.circular(ConvertData.stringToDouble(data['bottomRight'])),
    );
  }

  static List<List> chunk([List data = const [], int size = 2]) {
    List<List> chunks = [];
    int len = data.length;
    for (int i = 0; i < len; i += size) {
      int sizeStart = i + size;
      chunks.add(data.sublist(i, sizeStart > len ? len : sizeStart));
    }
    return chunks;
  }

  static Size toSize([Map? data]) {
    double width = stringToDouble(data is Map ? data['width'] : '0');
    double height = stringToDouble(data is Map ? data['height'] : '0');
    return Size(width, height);
  }

  static BoxFit toBoxFit(String? value) {
    switch (value) {
      case 'fill':
        return BoxFit.fill;
      case 'fit-width':
        return BoxFit.fitWidth;
      case 'fit-height':
        return BoxFit.fitHeight;
      case 'scale-down':
        return BoxFit.scaleDown;
      case 'contain':
        return BoxFit.contain;
      case 'none':
        return BoxFit.none;
      default:
        return BoxFit.cover;
    }
  }

  static MainAxisAlignment mainAxisAlignment(String? value) {
    switch (value) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.values[0];
    }
  }

  static CrossAxisAlignment crossAxisAlignment(String? value) {
    switch (value) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      case 'baseline':
        return CrossAxisAlignment.baseline;
      default:
        return CrossAxisAlignment.values[0];
    }
  }

  static FloatingActionButtonLocation floatingActionButtonLocation(
      String? value) {
    switch (value) {
      case 'startFloat':
        return FloatingActionButtonLocation.startFloat;
      case 'startTop':
        return FloatingActionButtonLocation.startTop;
      case 'startDocked':
        return FloatingActionButtonLocation.startDocked;
      case 'centerDocked':
        return FloatingActionButtonLocation.centerDocked;
      case 'centerFloat':
        return FloatingActionButtonLocation.centerFloat;
      case 'centerTop':
        return FloatingActionButtonLocation.centerTop;
      case 'endFloat':
        return FloatingActionButtonLocation.endFloat;
      case 'endDocked':
        return FloatingActionButtonLocation.endDocked;
      case 'endTop':
        return FloatingActionButtonLocation.endTop;
      case 'miniStartDocked':
        return FloatingActionButtonLocation.miniStartDocked;
      case 'miniCenterDocked':
        return FloatingActionButtonLocation.miniCenterDocked;
      case 'miniCenterFloat':
        return FloatingActionButtonLocation.miniCenterFloat;
      case 'miniCenterTop':
        return FloatingActionButtonLocation.miniCenterTop;
      case 'miniEndDocked':
        return FloatingActionButtonLocation.miniEndDocked;
      case 'miniEndFloat':
        return FloatingActionButtonLocation.miniEndFloat;
      case 'miniEndTop':
        return FloatingActionButtonLocation.miniEndTop;
      case 'miniStartFloat':
        return FloatingActionButtonLocation.miniStartFloat;
      case 'miniStartTop':
        return FloatingActionButtonLocation.miniStartTop;
      default:
        return FloatingActionButtonLocation.centerDocked;
    }
  }

  static double catchNegativeValue(double value, [double defaultValue = 0]) {
    if (value < 0) {
      return defaultValue;
    }
    return value;
  }

  static Size toSizeValue(dynamic value, [Size initValue = Size.zero]) {
    if (value is Size) {
      return value;
    }

    if (value is Map) {
      double width =
          ConvertData.stringToDouble(value['width'], initValue.width);
      double height =
          ConvertData.stringToDouble(value['height'], initValue.height);
      return Size(width, height);
    }

    return initValue;
  }
}
