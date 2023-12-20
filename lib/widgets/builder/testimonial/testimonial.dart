import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'layout/carousel.dart';

import 'template/default.dart';
import 'template/style2.dart';

class TestimonialWidget extends StatelessWidget with Utility, ContainerMixin {
  final WidgetConfig? widgetConfig;

  TestimonialWidget({
    Key? key,
    this.widgetConfig,
  }) : super(key: key);

  Widget buildItem({
    dynamic item,
    int? index,
    int? length,
    Color? background,
    double? radius,
    required String languageKey,
    required String themeModeKey,
    required String imageKey,
  }) {
    if (item is Map<String, dynamic> &&
        item['template'] is String &&
        item['data'] is Map<String, dynamic>) {
      return buildTemplate(
        template: item['template'],
        data: item['data'],
        background: background,
        radius: radius,
        languageKey: languageKey,
        themeModeKey: themeModeKey,
        imageKey: imageKey,
      );
    }
    return Container();
  }

  Widget buildTemplate({
    String? template,
    Map<String, dynamic>? data,
    Color? background,
    double? radius,
    required String languageKey,
    required String themeModeKey,
    required String imageKey,
  }) {
    switch (template) {
      case 'style2':
        return Style2(
          item: data,
          color: background,
          languageKey: languageKey,
          themeModeKey: themeModeKey,
          imageKey: imageKey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 0)),
        );
      default:
        return Default(
          item: data,
          color: background,
          languageKey: languageKey,
          themeModeKey: themeModeKey,
          imageKey: imageKey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 0)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    SettingStore settingStore = Provider.of<SettingStore>(context);
    String themeModeKey = settingStore.themeModeKey;
    String languageKey = settingStore.languageKey;
    String imageKey = settingStore.imageKey;

    // Styles
    Map<String, dynamic> styles = widgetConfig?.styles ?? {};
    Map<String, dynamic>? margin = get(styles, ['margin'], {});
    Map<String, dynamic>? padding = get(styles, ['padding'], {});
    Map<String, dynamic>? background =
        get(styles, ['background', themeModeKey], {});

    // General
    Map<String, dynamic> fields = widgetConfig?.fields ?? {};
    List items = get(fields, ['items'], []);
    dynamic radius = get(fields, ['radius'], 0);
    Map? backgroundItem = get(fields, ['backgroundItem', themeModeKey], {});
    dynamic pad = get(fields, ['pad'], 0);

    Color backgroundItemColor =
        ConvertData.fromRGBA(backgroundItem, theme.cardColor);
    double? paddingItem = ConvertData.stringToDouble(pad);
    double? radiusItem = ConvertData.stringToDouble(radius);

    Color backgroundView = ConvertData.fromRGBA(background, Colors.transparent);

    return Container(
      margin: ConvertData.space(margin, 'margin'),
      padding: ConvertData.space(padding, 'padding'),
      decoration: decorationColorImage(color: backgroundView),
      width: double.infinity,
      child: Carousel(
        length: items.length,
        pad: paddingItem,
        renderItem: (_, int index) => buildItem(
          item: items[index],
          index: index,
          length: items.length,
          background: backgroundItemColor,
          radius: radiusItem,
          languageKey: languageKey,
          themeModeKey: themeModeKey,
          imageKey: imageKey,
        ),
      ),
    );
  }
}
