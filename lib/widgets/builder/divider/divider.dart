import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DividerWidget extends StatelessWidget with Utility, ContainerMixin {
  final WidgetConfig? widgetConfig;

  DividerWidget({
    Key? key,
    required this.widgetConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SettingStore settingStore = Provider.of<SettingStore>(context);
    String themeModeKey = settingStore.themeModeKey;

    // Styles
    Map<String, dynamic> styles = widgetConfig?.styles ?? {};
    Map<String, dynamic>? margin = get(styles, ['margin'], {});
    Map<String, dynamic>? padding = get(styles, ['padding'], {});
    Map<String, dynamic>? background =
        get(styles, ['background', themeModeKey], {});
    Map<String, dynamic>? color = get(styles, ['color', themeModeKey], {});

    // General config
    Map<String, dynamic> fields = widgetConfig?.fields ?? {};
    dynamic height = get(fields, ['height'], 1);
    String? type = get(fields, ['type'], 'solid');

    double? heightDivider = ConvertData.stringToDouble(height);
    Color colorDivider =
        ConvertData.fromRGBA(color, Theme.of(context).dividerColor);

    return Container(
      margin: ConvertData.space(margin, 'margin'),
      padding: ConvertData.space(padding, 'padding'),
      decoration: decorationColorImage(
        color: ConvertData.fromRGBA(background, Colors.transparent),
      ),
      child: _buildType(type: type, height: heightDivider, color: colorDivider),
    );
  }

  ///
  /// The render dashed divider
  /// The [height] argument for height divider
  /// The [color] argument for color divider
  ///
  Widget _dashed({double? height, Color? color}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 2 * height!;
        final double dashHeight = height;
        final dashCount = (boxWidth / (1.5 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }

  ///
  /// The render dotted divider
  /// The [height] argument for height divider
  /// The [color] argument for color divider
  ///
  Widget _dotted({double? height, Color? color}) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashHeight = height!;
        final dashCount = (boxWidth / (1.7 * dashHeight)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(dashHeight / 2),
              child: SizedBox(
                width: dashHeight,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  ///
  /// The render solid divider
  /// The [height] argument for height divider
  /// The [color] argument for color divider
  ///
  Widget _solid({double? height, Color? color}) {
    return Divider(
      height: height,
      color: color,
      thickness: height,
    );
  }

  ///
  /// The render type divider
  /// The [type] argument for type divider
  /// The [height] argument for height divider
  /// The [color] argument for color divider
  ///
  Widget _buildType({String? type, double? height, Color? color}) {
    switch (type) {
      case 'dashed':
        return _dashed(height: height, color: color);
      case 'dotted':
        return _dotted(height: height, color: color);
      default:
        return _solid(height: height, color: color);
    }
  }
}
