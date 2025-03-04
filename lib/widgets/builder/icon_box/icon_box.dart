import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ui.dart';

import 'layout/layout_list.dart';
import 'layout/layout_carousel.dart';
import 'layout/layout_grid.dart';
import 'layout/layout_masonry.dart';
import 'layout/layout_slideshow.dart';

class IconBoxWidget extends StatelessWidget
    with Utility, NavigationMixin, ContainerMixin {
  final WidgetConfig? widgetConfig;

  IconBoxWidget({
    Key? key,
    required this.widgetConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SettingStore settingStore = Provider.of<SettingStore>(context);
    String themeModeKey = settingStore.themeModeKey;

    // layout
    String layout = widgetConfig!.layout ?? 'list';

    // Styles
    Map<String, dynamic> styles = widgetConfig?.styles ?? {};
    Map<String, dynamic>? margin = get(styles, ['margin'], {});
    Map<String, dynamic>? padding = get(styles, ['padding'], {});
    Color background = ConvertData.fromRGBA(
        get(styles, ['background', themeModeKey], {}), Colors.transparent);
    double height = ConvertData.stringToDouble(get(styles, ['height'], 300));

    // General config
    Map<String, dynamic> fields = widgetConfig?.fields ?? {};
    List items = get(fields, ['items'], []);

    return Container(
      margin: ConvertData.space(margin, 'margin'),
      decoration: decorationColorImage(color: background),
      height: layout == 'carousel' || layout == 'slideshow' ? height : null,
      child: buildLayout(
        layout,
        items: items,
        height: height,
        padding: ConvertData.space(padding, 'padding'),
        styles: styles,
        themeModeKey: themeModeKey,
      ),
    );
  }

  Widget? buildLayout(
    String layout, {
    required List items,
    double height = 300,
    EdgeInsetsDirectional? padding,
    Map<String, dynamic>? styles,
    String? themeModeKey,
  }) {
    if (items.isEmpty) {
      return null;
    }
    double? pad = ConvertData.stringToDouble(get(styles, ['pad'], 12));

    switch (layout) {
      case 'carousel':
        double? width = ConvertData.stringToDouble(get(styles, ['width'], 300));
        return LayoutCarousel(
          items: items,
          padding: padding,
          pad: pad,
          buildItem: (BuildContext context,
              {dynamic item, int? index, double? width, double? height}) {
            return buildItem(
              context,
              item: item,
              styles: styles,
              width: width,
              height: height,
            );
          },
          height: height,
          width: width,
        );
      case 'grid':
        int column = ConvertData.stringToInt(get(styles, ['col'], 2), 2);
        double? ratio =
            ConvertData.stringToDouble(get(styles, ['ratio'], 1), 1);
        return LayoutGrid(
          items: items,
          padding: padding,
          pad: pad,
          column: column,
          ratio: ratio,
          buildItem: (BuildContext context,
              {dynamic item, int? index, double? width, double? height}) {
            return buildItem(
              context,
              item: item,
              styles: styles,
              width: width,
              height: height,
            );
          },
        );
      case 'masonry':
        return LayoutMasonry(
          items: items,
          padding: padding,
          pad: pad,
          buildItem: (BuildContext context,
              {dynamic item, int? index, double? width, double? height}) {
            return buildItem(
              context,
              item: item,
              styles: styles,
              width: width,
              height: height,
            );
          },
        );
      case 'slideshow':
        double? maxWidth =
            ConvertData.stringToDouble(get(styles, ['maxWidth']), 300);
        Color indicatorColor = ConvertData.fromRGBA(
            get(styles, ['indicatorColor', themeModeKey], {}), Colors.black);
        Color indicatorActiveColor = ConvertData.fromRGBA(
            get(styles, ['indicatorActiveColor', themeModeKey], {}),
            Colors.black);
        return LayoutSlideshow(
          items: items,
          padding: padding,
          height: height,
          indicatorColor: indicatorColor,
          indicatorActiveColor: indicatorActiveColor,
          buildItem: (BuildContext context,
              {dynamic item, int? index, double? width, double? height}) {
            return buildItem(
              context,
              item: item,
              styles: styles,
              width: width,
              maxWidth: maxWidth,
              height: height,
            );
          },
        );
      default:
        return LayoutList(
          items: items,
          padding: padding,
          pad: pad,
          buildItem: (BuildContext context,
              {dynamic item, int? index, double? width, double? height}) {
            return buildItem(
              context,
              item: item,
              styles: styles,
              width: width,
              height: height,
            );
          },
        );
    }
  }

  Widget buildItem(
    BuildContext context, {
    dynamic item,
    Map<String, dynamic>? styles,
    double? width,
    double? height,
    double? maxWidth,
  }) {
    ThemeData theme = Theme.of(context);

    SettingStore settingStore = Provider.of<SettingStore>(context);
    String themeModeKey = settingStore.themeModeKey;
    String languageKey = settingStore.languageKey;

    String? typeTemplate = get(item, ['template'], 'default');
    Map<String, dynamic>? dataTemplate = get(item, ['data'], {});

    Map<String, dynamic>? action =
        Map<String, dynamic>.from(get(dataTemplate, ['action'], {}));

    String? title = get(dataTemplate, ['title', languageKey], '');
    String? description = get(dataTemplate, ['description', languageKey], '');

    TextStyle titleStyle =
        ConvertData.toTextStyle(get(dataTemplate, ['title'], {}), themeModeKey);
    TextStyle descriptionStyle = ConvertData.toTextStyle(
        get(dataTemplate, ['description'], {}), themeModeKey);

    Map? iconData = get(dataTemplate, ['icon'], {});
    String? alignment = get(dataTemplate, ['alignment'], 'left');

    TextAlign textAlign = ConvertData.toTextAlignDirection(
        get(dataTemplate, ['alignment'], 'left'));

    // Config
    Color background = ConvertData.fromRGBA(
        get(styles, ['backgroundColorItem', themeModeKey], {}),
        theme.cardColor);
    Color borderColor = ConvertData.fromRGBA(
        get(styles, ['borderColor', themeModeKey], {}), theme.dividerColor);
    double? radius = ConvertData.stringToDouble(get(styles, ['radius'], 0));

    // box shadow
    Color shadowColor = ConvertData.fromRGBA(
        get(styles, ['shadowColor', themeModeKey], {}), Colors.black);
    double offsetX = ConvertData.stringToDouble(get(styles, ['offsetX'], 0));
    double offsetY = ConvertData.stringToDouble(get(styles, ['offsetY'], 4));
    double blurRadius =
        ConvertData.stringToDouble(get(styles, ['blurRadius'], 24));
    double spreadRadius =
        ConvertData.stringToDouble(get(styles, ['spreadRadius'], 0));
    List<BoxShadow> boxShadow = [
      BoxShadow(
        color: shadowColor,
        offset: Offset(offsetX, offsetY),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
      )
    ];

    TextStyle? titleStyleItem = theme.textTheme.titleMedium?.merge(titleStyle);
    TextStyle? descriptionStyleItem =
        theme.textTheme.bodyMedium?.merge(descriptionStyle);

    switch (typeTemplate) {
      case 'contained':
        return IconBoxHorizontalItem(
            icon: buildIcon(
              iconData: iconData,
              styles: styles,
              themeModeKey: themeModeKey,
            ),
            title: Text(title!, style: titleStyleItem, textAlign: textAlign),
            description: Text(description!,
                style: descriptionStyleItem, textAlign: textAlign),
            width: width,
            height: height,
            maxWidth: width ?? 340,
            color: background,
            border: Border.all(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: boxShadow,
            onClick: () {
              if (action.isEmpty) {
                return null;
              }
              navigate(context, action);
            });
      case 'group':
        return IconBoxHorizontalItem(
            icon: buildIcon(
              iconData: iconData,
              styles: styles,
              themeModeKey: themeModeKey,
            ),
            title: Text(title!, style: titleStyleItem, textAlign: textAlign),
            description: Text(description!,
                style: descriptionStyleItem, textAlign: textAlign),
            width: width,
            height: height,
            maxWidth: width ?? 340,
            color: background,
            border: Border.all(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(radius),
            boxShadow: boxShadow,
            type: IconBoxHorizontalItemType.style2,
            onClick: () {
              if (action.isEmpty) {
                return null;
              }
              navigate(context, action);
            });
      default:
        CrossAxisAlignment crossAxisAlignment = alignment == 'left'
            ? CrossAxisAlignment.start
            : alignment == 'right'
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center;
        return IconBoxContainedItem(
          icon: buildIcon(
            iconData: iconData,
            styles: styles,
            themeModeKey: themeModeKey,
          ),
          title: Text(title!, style: titleStyleItem, textAlign: textAlign),
          description: Text(description!,
              style: descriptionStyleItem, textAlign: textAlign),
          width: width,
          height: height,
          maxWidth: width ?? 280,
          alignment: crossAxisAlignment,
          color: background,
          border: Border.all(width: 1, color: borderColor),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: boxShadow,
          onClick: () {
            if (action.isEmpty) {
              return null;
            }
            navigate(context, action);
          },
        );
    }
  }

  Widget buildIcon(
      {Map? iconData, Map<String, dynamic>? styles, String? themeModeKey}) {
    bool enableBoxIcon = get(styles, ['enableBoxIcon'], false);

    double? sizeIcon =
        ConvertData.stringToDouble(get(styles, ['sizeIcon'], 36));
    double? sizeBoxIcon =
        ConvertData.stringToDouble(get(styles, ['sizeBoxIcon'], 54));

    Color iconColor = ConvertData.fromRGBA(
        get(styles, ['iconColor', themeModeKey], {}), Colors.white);
    Color iconBoxColor = ConvertData.fromRGBA(
        get(styles, ['iconBoxColor', themeModeKey], {}), Colors.black);
    Color iconBorder = ConvertData.fromRGBA(
        get(styles, ['iconBorder', themeModeKey], {}), Colors.black);

    Widget icon =
        FlybuyIconBuilder(data: iconData, size: sizeIcon, color: iconColor);

    return enableBoxIcon
        ? Container(
            width: sizeBoxIcon,
            height: sizeBoxIcon,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBoxColor,
              border: Border.all(width: 1, color: iconBorder),
              shape: BoxShape.circle,
            ),
            child: icon,
          )
        : icon;
  }
}
