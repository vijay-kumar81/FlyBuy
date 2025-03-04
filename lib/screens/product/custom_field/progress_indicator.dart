import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/flybuy_animation_indicator.dart';
import 'package:flutter/material.dart';

class ProgressIndicatorField extends StatelessWidget {
  final dynamic value;

  const ProgressIndicatorField({
    Key? key,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double data = ConvertData.stringToDouble(value);
    double percent = data > 100
        ? 100
        : data < 0
            ? 0
            : data;

    return FlybuyAnimationIndicator(
      value: percent / 100,
      strokeWidth: 6,
      radiusStrokeWidth: 0,
    );
  }
}
