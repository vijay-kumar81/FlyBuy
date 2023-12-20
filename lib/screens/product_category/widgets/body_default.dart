import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/product_category/product_category.dart';
import 'package:flybuy/models/setting/setting.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/widgets.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:ui/notification/notification_screen.dart';

import 'body.dart';
import 'list_category_scroll_load_more.dart';

/// Default layout Category
///
class DefaultCategory extends StatelessWidget with LoadingMixin, Utility {
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

  // Key set image
  final String imageKey;

  DefaultCategory({
    Key? key,
    this.categories,
    this.widgetConfig,
    this.configs,
    this.themeModeKey = "value",
    this.languageKey = "text",
    this.imageKey = "src",
  }) : super(key: key);

  List<ProductCategory?>? getListItem(
      ProductCategory parent, enableShowAll, positionShowAll) {
    if (enableShowAll) {
      if (positionShowAll == 'start') {
        return [parent, ...parent.categories!];
      } else {
        return [...parent.categories!, parent];
      }
    }
    return parent.categories;
  }

  @override
  Widget build(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    String? layoutView =
        get(widgetConfig!.fields, ['styleView'], Strings.layoutCategoryList);
    int col = ConvertData.stringToInt(
        get(widgetConfig!.fields, ['columnGrid'], 2), 2);
    double? ratio = ConvertData.stringToDouble(
        get(widgetConfig!.fields, ['childAspectRatio'], 1), 1);

    // Config item show all
    // bool enableShowAll = get(widgetConfig.fields, ['enableShowAll'], true);
    // bool enableChangeNameShowAll = get(widgetConfig.fields, ['enableChangeNameShowAll'], true);
    // String positionShowAll = get(widgetConfig.fields, ['positionShowAll'], 'start');
    String? textShowAll = get(widgetConfig?.fields,
        ['textShowAll', languageKey], translate('product_category_show_all'));

    double? pad =
        ConvertData.stringToDouble(get(widgetConfig!.fields, ['padItem'], 16));

    Map<String, dynamic>? template = get(widgetConfig!.fields, ['template'],
        {'template': Strings.productCategoryItemHorizontal, 'data': {}});

    Widget? appBar = buildAppBar(context, configs: configs);
    Widget? banner = buildBanner(context, configs: configs, imageKey: imageKey);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (appBar != null) appBar,
        if (banner != null) banner,
        if (categories?.isNotEmpty != true)
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              child: NotificationScreen(
                title: Text(
                  translate('product_category'),
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                content: Text(
                  translate('product_category_no_found'),
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                iconData: FeatherIcons.grid,
                isButton: false,
              ),
            ),
          )
        else
          SliverPadding(
            padding: paddingHorizontal,
            sliver: ListCategoryScrollLoadMore(
              // categories: getListItem(parent, enableShowAll, positionShowAll),
              categories: categories,
              layout: layoutView,
              col: col,
              ratio: ratio,
              enableTextShowAll: false,
              textShowAll: textShowAll,
              idShowAll: -1,
              template: template,
              styles: widgetConfig?.styles ?? {},
              pad: pad,
              themeModeKey: themeModeKey,
            ),
          ),
      ],
    );
  }

  // Build Layout App bar
  Widget? buildAppBar(BuildContext context, {Map<String, dynamic>? configs}) {
    String? type = get(configs, ['appBarType'], Strings.appbarFloating);
    bool enableSearch = get(configs, ['enableSearch'], true);
    bool? enableCart = get(configs, ['enableCart'], true);

    if (!enableSearch && !enableCart!) {
      return null;
    }

    // ==== Title
    Widget? title = enableSearch ? const SearchProductWidget() : null;

    // ==== Actions
    List<Widget> actions = [
      if (enableCart!)
        const Padding(
          padding: EdgeInsetsDirectional.only(end: 17),
          child: FlybuyCartIcon(
            icon: Icon(FeatherIcons.shoppingCart),
            enableCount: true,
            color: Colors.transparent,
          ),
        ),
    ];
    return SliverAppBar(
      floating: type == Strings.appbarFloating,
      elevation: 0,
      primary: true,
      pinned: true,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: title,
      actions: actions,
      expandedHeight: 73,
      leadingWidth: 0,
      titleSpacing: 20,
    );
  }

  // Build Banner
  Widget? buildBanner(BuildContext context,
      {Map<String, dynamic>? configs, required String imageKey}) {
    bool enableBanner = get(configs, ['enableBanner'], true);

    if (!enableBanner) {
      return null;
    }
    return SliverPadding(
      padding: paddingHorizontal.copyWith(bottom: itemPaddingMedium),
      sliver: SliverToBoxAdapter(
        child: BannerWidget(configs: configs, imageKey: imageKey),
      ),
    );
  }
}
