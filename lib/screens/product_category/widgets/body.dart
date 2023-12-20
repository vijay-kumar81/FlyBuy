import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/constants/assets.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/product_category/product_category.dart';
import 'package:flybuy/models/setting/setting.dart';
import 'package:flybuy/screens/search/search_feature.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/flybuy_cache_image.dart';
import 'package:ui/ui.dart';

abstract class Body extends StatefulWidget with Utility {
  // List top categories (parent = 0)
  final List<ProductCategory>? categories;

  // setting page category list
  final WidgetConfig? widgetConfig;

  // Config style category list
  final Map<String, dynamic>? configs;

  // Key set language
  final String languageKey;

  // Key set theme darkmode
  final String themeModeKey;

  // Key set language
  final String imageKey;

  const Body({
    Key? key,
    this.categories,
    this.widgetConfig,
    this.configs = const {},
    this.themeModeKey = 'value',
    this.languageKey = 'text',
    this.imageKey = "src",
  }) : super(key: key);

  Widget buildBody(
    BuildContext context, {
    ProductCategory? parent,
    Widget? appBar,
    Widget? tab,
    Widget? banner,
    WidgetConfig? widgetConfig,
    String languageKey = "text",
    String themeModeKey = "value",
  });

  Widget? buildAppBar(BuildContext context, {Map<String, dynamic>? configs});

  // Build Banner
  Widget? buildBanner(BuildContext context,
      {Map<String, dynamic>? configs, required String imageKey});

  // Builder Layout Tabs
  Widget buildTabs(
    BuildContext context, {
    TabController? tabController,
    List<ProductCategory>? categories,
    Function? onChanged,
    WidgetConfig? widgetConfig,
  });

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: widget.categories!.length);
  }

  void _onChanged(index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? appBar = widget.buildAppBar(context, configs: widget.configs);
    Widget? banner = widget.buildBanner(context,
        configs: widget.configs, imageKey: widget.imageKey);

    Widget tabs = widget.buildTabs(
      context,
      tabController: _tabController,
      categories: widget.categories,
      onChanged: _onChanged,
      widgetConfig: widget.widgetConfig,
    );

    Widget body = widget.buildBody(
      context,
      parent: widget.categories?.isNotEmpty == true
          ? widget.categories![_index]
          : null,
      tab: tabs,
      appBar: appBar,
      banner: banner,
      widgetConfig: widget.widgetConfig,
      languageKey: widget.languageKey,
      themeModeKey: widget.themeModeKey,
    );

    return SafeArea(child: body);
  }
}

class SearchProductWidget extends StatelessWidget {
  const SearchProductWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;
    return SearchFeature(
      searchLabel: translate('product_category_search'),
      child: Search(
        icon: const Icon(FeatherIcons.search, size: 16),
        label: Text(translate('product_category_search'),
            style: theme.textTheme.bodyMedium),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(width: 1, color: theme.dividerColor),
        ),
        color: theme.colorScheme.surface,
      ),
    );
  }
}

class BannerWidget extends StatelessWidget {
  final Map<String, dynamic>? configs;
  final String imageKey;

  const BannerWidget({
    Key? key,
    this.configs,
    this.imageKey = "src",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? imageBanner =
        ConvertData.imageFromConfigs(get(configs, ['imageBanner']), imageKey);
    double? widthBanner =
        ConvertData.stringToDouble(get(configs, ['widthBanner'], 335));
    double? heightBanner =
        ConvertData.stringToDouble(get(configs, ['heightBanner'], 80));
    double? radiusBanner =
        ConvertData.stringToDouble(get(configs, ['radiusBanner'], 8));

    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        double widthImage = constraints.maxWidth;
        double heightImage = (widthImage * heightBanner) / widthBanner;
        return ClipRRect(
          borderRadius: BorderRadius.circular(radiusBanner),
          child: FlybuyCacheImage(
            imageBanner != '' ? imageBanner : Assets.noImageUrl,
            width: widthImage,
            height: heightImage,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
