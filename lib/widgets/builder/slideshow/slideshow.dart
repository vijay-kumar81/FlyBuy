import 'package:flybuy/constants/assets.dart';
import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class SlideshowWidget extends StatelessWidget
    with Utility, NavigationMixin, ContainerMixin {
  final WidgetConfig? widgetConfig;

  SlideshowWidget({
    Key? key,
    this.widgetConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    SettingStore settingStore = Provider.of<SettingStore>(context);
    String themeModeKey = settingStore.themeModeKey;

    // Layout
    String layout = widgetConfig?.layout ?? Strings.slideshowLayoutBasic;

    // Styles
    Map<String, dynamic> styles = widgetConfig?.styles ?? {};
    Map<String, dynamic>? margin = get(styles, ['margin'], {});
    Map<String, dynamic>? padding = get(styles, ['padding'], {});
    Map<String, dynamic>? background =
        get(styles, ['background', themeModeKey], null);
    double? borderRadius =
        ConvertData.stringToDouble(get(styles, ['borderRadius'], 0));

    // General config
    Map<String, dynamic> fields = widgetConfig?.fields ?? {};
    bool? autoPlay = get(fields, ['autoPlay'], true);
    int scrollDirection =
        ConvertData.stringToInt(get(fields, ['scrollDirection'], 0), 0);
    bool? enableIndicator = get(fields, ['enableIndicator'], true);
    dynamic autoPlayDelay = get(fields, ['autoPlayDelay'], 1000);
    dynamic autoPlayInterval = get(fields, ['autoPlayInterval'], 1800);

    List? items = get(fields, ['items'], []);

    int valueInterval = ConvertData.stringToInt(autoPlayInterval);
    int valueDelay = ConvertData.stringToInt(autoPlayDelay);

    Color backgroundColor =
        ConvertData.fromRGBA(background, Colors.transparent);

    // Config size
    dynamic size = get(fields, ['size'], {'width': 375, 'height': 330});
    double? height =
        ConvertData.stringToDouble(size is Map ? size['height'] : '330');
    double? width =
        ConvertData.stringToDouble(size is Map ? size['width'] : '375');

    if (width == 0) {
      return Container();
    }

    // Indicator
    Map<String, dynamic>? indicatorMargin =
        get(styles, ['indicatorMargin'], {});
    Map<String, dynamic>? indicatorColor =
        get(styles, ['indicatorColor', themeModeKey], null);
    Map<String, dynamic>? indicatorActiveColor =
        get(styles, ['indicatorActiveColor', themeModeKey], null);
    double? indicatorSize =
        ConvertData.stringToDouble(get(styles, ['indicatorSize'], 6));
    double? activeIndicatorSize =
        ConvertData.stringToDouble(get(styles, ['activeIndicatorSize'], 10));
    double? indicatorSpace =
        ConvertData.stringToDouble(get(styles, ['indicatorSpace'], 4));
    AlignmentDirectional indicatorAlignment =
        ConvertData.toAlignmentDirectional(
            get(styles, ['indicatorAlignment'], 'bottom-start'));

    Color colorIndicator =
        ConvertData.fromRGBA(indicatorColor, theme.indicatorColor);
    Color colorIndicatorActive =
        ConvertData.fromRGBA(indicatorActiveColor, theme.indicatorColor);

    SwiperPlugin? pagination = enableIndicator!
        ? FlybuyPaginationSwiper(
            alignment: indicatorAlignment,
            margin: ConvertData.space(indicatorMargin, 'indicatorMargin'),
            builder: DotSwiperPaginationBuilder(
              color: colorIndicator,
              activeColor: colorIndicatorActive,
              size: indicatorSize,
              activeSize: activeIndicatorSize,
              space: indicatorSpace,
            ),
          )
        : null;

    return Container(
      margin: ConvertData.space(margin, 'margin'),
      padding: ConvertData.space(padding, 'padding'),
      decoration: decorationColorImage(color: backgroundColor),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double containerWidth = constraints.maxWidth;
          double containerHeight = height == 0
              ? constraints.maxHeight
              : (containerWidth * height) / width;

          return SizedBox(
            width: containerWidth,
            height: containerHeight,
            child: buildLayout(
              context,
              layout: layout,
              items: items,
              containerWidth: containerWidth,
              containerHeight: containerHeight,
              pagination: pagination,
              scrollDirection: scrollDirection,
              autoPlay: autoPlay,
              autoPlayInterval: valueInterval,
              autoPlayDelay: valueDelay,
              borderRadius: borderRadius,
            ),
          );
        },
      ),
    );
  }

  Widget buildLayout(
    BuildContext context, {
    String? layout,
    List? items,
    double? containerWidth,
    double? containerHeight,
    SwiperPlugin? pagination,
    int scrollDirection = 0,
    bool? autoPlay,
    int? autoPlayInterval,
    int? autoPlayDelay,
    double? borderRadius,
  }) {
    switch (layout) {
      case Strings.slideshowLayoutCenterMode:
        double itemWidth = containerWidth! - 64;
        double itemHeight = (itemWidth * containerHeight!) / containerWidth;
        double viewportFraction = itemWidth / containerWidth;
        double aspectRatio = (itemWidth - 32) / itemWidth;

        return Swiper(
          itemBuilder: (BuildContext context, int index) => _buildItem(
            context,
            items[index],
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            borderRadius: borderRadius,
          ),
          itemCount: items!.length,
          scrollDirection: Axis.values[scrollDirection],
          pagination: pagination,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          viewportFraction: viewportFraction,
          scale: aspectRatio,
          autoplay: autoPlay!,
          autoplayDelay: autoPlayDelay!,
          duration: autoPlayInterval!,
        );
      case Strings.slideshowLayoutStack:
        double itemWidth = containerWidth! - 32;
        double itemHeight = (itemWidth * containerHeight!) / containerWidth;
        double viewportFraction = itemWidth / containerWidth;
        double aspectRatio = (itemWidth - 8) / itemWidth;
        return Swiper(
          itemBuilder: (BuildContext context, int index) => _buildItem(
            context,
            items[index],
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            borderRadius: borderRadius,
          ),
          itemCount: items!.length,
          scrollDirection: Axis.values[scrollDirection],
          pagination: pagination,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          viewportFraction: viewportFraction,
          scale: aspectRatio,
          layout: SwiperLayout.STACK,
          autoplay: autoPlay!,
          autoplayDelay: autoPlayDelay!,
          duration: autoPlayInterval!,
        );
      case Strings.slideshowLayoutTinder:
        double itemWidth = containerWidth!;
        double itemHeight = (itemWidth * containerHeight!) / containerWidth;

        return Swiper(
          itemBuilder: (BuildContext context, int index) => _buildItem(
            context,
            items[index],
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            borderRadius: borderRadius,
          ),
          itemCount: items!.length,
          scrollDirection: Axis.values[scrollDirection],
          pagination: pagination,
          itemWidth: itemWidth,
          itemHeight: itemHeight,
          layout: SwiperLayout.TINDER,
          autoplay: autoPlay!,
          autoplayDelay: autoPlayDelay!,
          duration: autoPlayInterval!,
        );
      case Strings.slideshowLayoutRotate:
        double itemWidth = containerWidth! - 64;
        double heightItem = (itemWidth * containerWidth) / containerWidth;
        double viewportFraction = itemWidth / containerWidth;
        double aspectRatio = (itemWidth - 16) / itemWidth;
        return Swiper(
          itemWidth: itemWidth,
          itemHeight: heightItem,
          itemBuilder: (BuildContext context, int index) => _buildItem(
            context,
            items[index],
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            borderRadius: borderRadius,
          ),
          curve: Curves.linear,
          itemCount: items!.length,
          viewportFraction: viewportFraction,
          scale: aspectRatio,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption: CustomLayoutOption(startIndex: -1, stateCount: 3)
              .addRotate([-0.25, 0.0, 0.25]).addTranslate(
            [
              Offset(-itemWidth - 45, -60),
              const Offset(0.0, 0.0),
              Offset(itemWidth + 45, -60),
            ],
          ),
          autoplay: autoPlay!,
          autoplayDelay: autoPlayDelay!,
          duration: autoPlayInterval!,
        );
      default:
        return Swiper(
          itemBuilder: (BuildContext context, int index) => _buildItem(
            context,
            items[index],
            containerWidth: containerWidth,
            containerHeight: containerHeight,
            borderRadius: borderRadius,
          ),
          itemCount: items!.length,
          scrollDirection: Axis.values[scrollDirection],
          pagination: pagination,
          autoplay: autoPlay!,
          autoplayDelay: autoPlayDelay!,
          duration: autoPlayInterval!,
        );
    }
  }

  _buildItem(
    BuildContext context,
    Map<String, dynamic> item, {
    double? containerWidth,
    double? containerHeight,
    double? borderRadius = 0,
  }) {
    SettingStore settingStore = Provider.of<SettingStore>(context);
    String imageKey = settingStore.imageKey;

    String? url = get(item, ['data', 'image', imageKey], '');
    String? fit = get(item, ['data', 'fit'], 'cover');
    List<dynamic>? layer = get(item, ['data', 'layer'], []);

    // Config size
    dynamic size =
        get(item, ['data', 'imageSize'], {'width': 375, 'height': 300});
    double? height =
        ConvertData.stringToDouble(size is Map ? size['height'] : '300');
    double? width =
        ConvertData.stringToDouble(size is Map ? size['width'] : '375');

    if (width == 0) return Container();

    double? imageHeight =
        height == 0 ? containerHeight : (containerWidth! * height) / width;

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius!),
          child: FlybuyCacheImage(
            url != '' ? url : Assets.noImageUrl,
            fit: ConvertData.toBoxFit(fit),
            width: containerWidth,
            height: imageHeight,
          ),
        ),
        ...List.generate(layer!.length,
            (index) => _buildLayer(context, layerItem: layer[index])),
      ],
    );
  }

  Widget _buildLayer(BuildContext context, {Map<String, dynamic>? layerItem}) {
    ThemeData theme = Theme.of(context);

    SettingStore settingStore = Provider.of<SettingStore>(context);
    String themeModeKey = settingStore.themeModeKey;
    String languageKey = settingStore.languageKey;

    Map<String, dynamic>? value = get(layerItem, ['value'], {});

    String? type = get(value, ['type'], 'text');

    // Action
    Map<String, dynamic>? action =
        get(layerItem, ['value', 'action'], {'type': 'none'});

    // Position
    Map<String, dynamic> position = get(value, ['position'], {});
    double? width =
        ConvertData.stringToDoubleCanBeNull(position['width'], null);
    double? height =
        ConvertData.stringToDoubleCanBeNull(position['height'], null);
    double? left = ConvertData.stringToDoubleCanBeNull(position['left'], null);
    double? top = ConvertData.stringToDoubleCanBeNull(position['top'], null);
    double? right =
        ConvertData.stringToDoubleCanBeNull(position['right'], null);
    double? bottom =
        ConvertData.stringToDoubleCanBeNull(position['bottom'], null);

    // Text
    String text = get(value, ['text', languageKey], '');
    TextStyle textStyle =
        ConvertData.toTextStyle(get(value, ['text'], {}), themeModeKey);

    Widget child = Text(text, style: textStyle);

    if (type == 'button') {
      Map<String, dynamic>? buttonBg =
          get(value, ['buttonBg', themeModeKey], null);
      Map<String, dynamic>? buttonBorderColor =
          get(value, ['buttonBorderColor', themeModeKey], null);
      double borderWidth =
          ConvertData.stringToDouble(get(value, ['buttonBorderWidth'], 0));

      dynamic size = get(value, ['buttonSize'], {'width': 80, 'height': 32});
      double? height =
          ConvertData.stringToDouble(size is Map ? size['height'] : '80');
      double? width =
          ConvertData.stringToDouble(size is Map ? size['width'] : '32');

      double borderRadius =
          ConvertData.stringToDouble(get(value, ['buttonBorderRadius'], 0));

      child = Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ConvertData.fromRGBA(buttonBg, theme.primaryColor),
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          border: Border.all(
              color:
                  ConvertData.fromRGBA(buttonBorderColor, theme.primaryColor),
              width: borderWidth),
        ),
        child: child,
      );
    }

    if (type == 'image') {
      String? src = get(value, ['image', 'src'], '');
      dynamic size = get(value, ['imageSize'], {'width': 32, 'height': 32});
      double? height =
          ConvertData.stringToDouble(size is Map ? size['height'] : '32');
      double? width =
          ConvertData.stringToDouble(size is Map ? size['width'] : '32');
      child = src != ''
          ? Image.network(src!, width: width, height: height)
          : Container();
    }

    if (type == 'icon') {
      Map icon = get(value, ['icon'], {});
      double? iconSize =
          ConvertData.stringToDouble(get(value, ['iconSize'], 14));
      Map<String, dynamic>? iconColor =
          get(value, ['iconColor', themeModeKey], null);
      child = FlybuyIconBuilder(
        data: icon,
        size: iconSize,
        color: ConvertData.fromRGBA(iconColor, theme.primaryColor),
      );
    }

    if (left == right) {
      child = Align(
        alignment: AlignmentDirectional.center,
        child: child,
      );
    }

    return Positioned.directional(
      textDirection: Directionality.of(context),
      width: width,
      height: height,
      start: left,
      top: top,
      end: right,
      bottom: bottom,
      child: InkWell(
        onTap: () => navigate(context, action),
        child: child,
      ),
    );
  }
}
