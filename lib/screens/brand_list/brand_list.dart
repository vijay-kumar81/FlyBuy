import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/flybuy_cart_icon.dart';
import 'package:ui/notification/notification_screen.dart';
import 'package:ui/ui.dart';

import 'brand_search.dart';
import 'widgets/item_brand.dart';

String strAlphabet = 'abcdefghijklmnopqrstuvwxwz#';
double fixedHeading = 64;

class BrandListScreen extends StatefulWidget {
  static const routeName = '/brand_list';

  const BrandListScreen({Key? key, this.args, this.store}) : super(key: key);

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();

  final Map? args;
  final SettingStore? store;
}

class _BrandListScreenState extends State<BrandListScreen> with LoadingMixin {
  late BrandStore _brandStore;

  @override
  void didChangeDependencies() {
    _brandStore = BrandStore(widget.store!.requestHelper, perPage: 100)
      ..getBrands();
    super.didChangeDependencies();
  }

  Map<String, List<Brand>> convertData(List<Brand> brands) {
    Map<String, List<Brand>> initDataAlpha =
        List.generate(strAlphabet.length, (int index) => strAlphabet[index])
            .fold({}, (previousValue, element) {
      Map data = previousValue;
      Map<String, List<Brand>> value = {element: []};
      data.addAll(value);
      return data as Map<String, List<Brand>>;
    });

    return brands.fold(initDataAlpha, (previousValue, element) {
      Map<String, List<Brand>> data = previousValue;
      String name = element.name!.trim();
      String keyName =
          name.isNotEmpty && strAlphabet.contains(name[0].toLowerCase())
              ? name[0].toLowerCase()
              : '#';
      data.update(keyName, (c) {
        c.add(element);
        return c;
      });
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        List<Brand> brands = _brandStore.brands;
        return Scaffold(
          body: ScrollAlphabet(
            dataAlpha: convertData(brands),
            store: widget.store,
            brands: brands,
            brandStore: _brandStore,
          ),
        );
      },
    );
  }
}

class ScrollAlphabet extends StatefulWidget {
  final Map<String, List<Brand>>? dataAlpha;
  final SettingStore? store;
  final List<Brand> brands;
  final BrandStore? brandStore;

  const ScrollAlphabet({
    Key? key,
    this.dataAlpha,
    this.store,
    required this.brands,
    this.brandStore,
  }) : super(key: key);
  @override
  State<ScrollAlphabet> createState() => _ScrollAlphabet();
}

class _ScrollAlphabet extends State<ScrollAlphabet>
    with AppBarMixin, TransitionMixin, LoadingMixin {
  final ScrollController _controller = ScrollController();
  List itemKeys = [];
  int visitSelect = 0;
  bool updateByController = true;
  late BrandStore _brandStore;

  @override
  void initState() {
    _brandStore = widget.brandStore!;
    List.generate(
        widget.dataAlpha!.length, (index) => itemKeys.add(GlobalKey()));
    super.initState();
    _controller.addListener(() {
      if (updateByController) {
        double offsetController = _controller.offset;
        double maxScrollExtent = _controller.position.maxScrollExtent;
        if (offsetController >= maxScrollExtent) {
          setState(() {
            visitSelect = itemKeys.length - 1;
          });
        } else {
          double safePaddingTop = MediaQuery.of(context).padding.top;
          int visit = 0;
          for (int i = 0; i < itemKeys.length - 1; i++) {
            RenderBox renderBox = itemKeys[i].currentContext.findRenderObject();
            Offset offsetVisit = renderBox.localToGlobal(Offset.zero);
            Offset offset = renderBox.localToGlobal(
                Offset(0, offsetController - fixedHeading - safePaddingTop));
            int lengthCount =
                widget.dataAlpha![widget.dataAlpha!.keys.toList()[i]]!.length;
            double value = offsetVisit.dy < renderBox.size.height
                ? offset.dy - lengthCount * 66
                : offset.dy;

            if (value <= offsetController) {
              visit = i;
            } else {
              break;
            }

            setState(() {
              visitSelect = visit;
            });
          }
        }
        _onScrollMore();
      } else {
        setState(() {
          updateByController = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void scrollTo(int index) {
    setState(() {
      visitSelect = index;
      updateByController = false;
    });
    Scrollable.ensureVisible(itemKeys[index].currentContext);
  }

  void _onScrollMore() {
    if (!_controller.hasClients ||
        _brandStore.loading ||
        !_brandStore.canLoadMore) return;

    final thresholdReached =
        _controller.position.extentAfter < endReachedThreshold;

    if (thresholdReached) {
      _brandStore.getBrands();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    bool loading = _brandStore.loading;
    bool? canLoadMore = loading && !_brandStore.canLoadMore;
    bool brandsIsNotEmpty = _brandStore.brands.isNotEmpty;

    List<String> keyAlpha = widget.dataAlpha!.keys.toList();
    Map<String, Data>? screens = widget.store?.data?.screens;
    Data? data = get(screens, ['brands'], null);
    Map<String, dynamic>? configs = data is Data ? data.configs : null;

    WidgetConfig? widgetConfig =
        data is Data ? data.widgets!['brandListPage'] : null;
    Map<String, dynamic>? fields =
        widgetConfig is WidgetConfig ? widgetConfig.fields : null;

    bool enableCenterTitle = get(configs, ['enableCenterTitle'], true);
    bool enableAppbarCart = get(configs, ['enableAppbarCart'], true);

    bool enableImage = get(fields, ['enableImage'], true);
    bool enableNumber = get(fields, ['enableNumber'], true);
    bool enableBorderImage = get(fields, ['enableBorderImage'], true);

    return SafeArea(
      top: true,
      bottom: false,
      child: Stack(
        children: [
          CustomScrollView(
            controller: _controller,
            slivers: [
              SliverAppBar(
                shadowColor: Colors.transparent,
                backgroundColor: theme.appBarTheme.backgroundColor,
                leading: leading(),
                centerTitle: enableCenterTitle,
                title: Text(
                  translate('brand_title'),
                  style: theme.appBarTheme.titleTextStyle,
                ),
                actions: enableAppbarCart
                    ? [
                        const Padding(
                          padding: EdgeInsetsDirectional.only(end: 17),
                          child: FlybuyCartIcon(
                            icon: Icon(FeatherIcons.shoppingCart),
                            enableCount: true,
                            color: Colors.transparent,
                          ),
                        ),
                      ]
                    : null,
              ),
              if (brandsIsNotEmpty) ...[
                // Display screen with data
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: StickyTabBarDelegate(
                    child: Container(
                      height: fixedHeading,
                      alignment: AlignmentDirectional.topCenter,
                      color: theme.scaffoldBackgroundColor,
                      padding: paddingHorizontal,
                      child: SizedBox(
                        height: fixedHeading - 16,
                        child: Search(
                          icon: const Icon(FeatherIcons.search, size: 16),
                          label: Text(translate('brand_search'),
                              style: theme.textTheme.bodyLarge),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side:
                                BorderSide(width: 1, color: theme.dividerColor),
                          ),
                          color: theme.colorScheme.surface,
                          padding: paddingHorizontalMedium,
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, _, __) => BrandSearch(
                                  brands: widget.brands,
                                  enableImage: enableImage,
                                  enableNumber: enableNumber,
                                ),
                                transitionsBuilder: slideTransition,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    height: fixedHeading,
                  ),
                ),
                ...List.generate(
                  keyAlpha.length,
                  (index) {
                    String alpha = keyAlpha[index];
                    List<Brand>? brands = widget.dataAlpha![alpha];
                    bool loadingAlpha = loading && brands!.isEmpty;
                    return SliverPadding(
                      padding:
                          const EdgeInsetsDirectional.only(start: 20, end: 30),
                      sliver: SliverStickyHeader.builder(
                        builder: (_, SliverStickyHeaderState state) {
                          Color color =
                              theme.textTheme.titleLarge?.color ?? Colors.black;

                          // remove " dataAlpha " with no data of the mark
                          if (!canLoadMore &&
                              brands.isNotEmpty &&
                              brandsIsNotEmpty) {
                            return Container(
                              key: itemKeys[index],
                              padding: const EdgeInsets.only(
                                  top: itemPaddingMedium, bottom: itemPadding),
                              color: theme.scaffoldBackgroundColor,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                alpha.toUpperCase(),
                                style: theme.textTheme.titleLarge?.copyWith(
                                    color: color.withOpacity(
                                        1 - state.scrollPercentage)),
                              ),
                            );
                          }
                          return SizedBox(key: itemKeys[index]);
                        },
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              return ItemBrand(
                                brand: loadingAlpha ? null : brands[i],
                                enableImage: enableImage,
                                enableNumber: enableNumber,
                                enableBorderImage: enableBorderImage,
                              );
                            },
                            childCount: loadingAlpha ? 4 : brands!.length,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ]
            ],
          ),
          //
          if (brandsIsNotEmpty) ...[
            // Display screen with data
            PositionedDirectional(
              top: 0,
              end: 4,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(keyAlpha.length, (index) {
                  String alpha = keyAlpha[index];
                  List<Brand>? brands = widget.dataAlpha![alpha];
                  if (!canLoadMore && brands!.isNotEmpty && brandsIsNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(1),
                      child: InkWell(
                        child: Text(
                          keyAlpha[index].toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: visitSelect == index
                                ? theme.textTheme.titleLarge?.color
                                : null,
                            fontWeight:
                                visitSelect == index ? FontWeight.w700 : null,
                          ),
                        ),
                        onTap: () => scrollTo(index),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
              ),
            )
          ] else ...[
            // Display loading screen and no data
            loading
                ? Center(child: buildLoading(context, isLoading: loading))
                : _buildBrandEmpty(),
          ]
        ],
      ),
    );
  }

  Widget _buildBrandEmpty() {
    TranslateType translate = AppLocalizations.of(context)!.translate;
    return NotificationScreen(
      title: Text(
        translate('brand_title'),
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      content: Text(translate('brand_empty'),
          style: Theme.of(context).textTheme.bodyMedium),
      iconData: FeatherIcons.box,
      isButton: false,
    );
  }
}
