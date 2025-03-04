import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../product/product.dart';

class ProductTopRatedWidget extends StatefulWidget {
  final WidgetConfig? widgetConfig;

  const ProductTopRatedWidget({
    Key? key,
    this.widgetConfig,
  }) : super(key: key);

  @override
  State<ProductTopRatedWidget> createState() => _ProductTopRatedState();
}

class _ProductTopRatedState extends State<ProductTopRatedWidget>
    with Utility, ContainerMixin {
  late AppStore _appStore;
  SettingStore? _settingStore;
  AuthStore? _authStore;
  ProductsStore? _productsStore;

  @override
  void didChangeDependencies() {
    _appStore = Provider.of<AppStore>(context);
    _settingStore = Provider.of<SettingStore>(context);
    _authStore = Provider.of<AuthStore>(context);

    Map<String, dynamic> fields = widget.widgetConfig?.fields ?? {};

    // Filter
    int limit = ConvertData.stringToInt(get(fields, ['limit'], '4'));
    List<dynamic> excludeProduct = get(fields, ['excludeProduct'], []);

    // Gen key for store
    List<Product> exProducts = excludeProduct
        .map((e) => Product(id: ConvertData.stringToInt(e['key'])))
        .toList();

    String? key = StringGenerate.getProductKeyStore(
      widget.widgetConfig!.id,
      currency: _settingStore!.currency,
      language: _settingStore!.locale,
      excludeProduct: exProducts,
      limit: limit,
    );

    // Add store to list store
    if (widget.widgetConfig != null && _appStore.getStoreByKey(key) == null) {
      ProductsStore store = ProductsStore(
        _settingStore!.requestHelper,
        key: key,
        perPage: limit,
        language: _settingStore!.locale,
        currency: _settingStore!.currency,
        sort: Map<String, dynamic>.from({
          'key': 'product_list_default',
          'query': {
            'orderby': 'rating',
            'order': 'desc',
          }
        }),
        exclude: exProducts,
        locationStore: _authStore?.locationStore,
      )..getProducts();
      _appStore.addStore(store);
      _productsStore ??= store;
    } else {
      _productsStore = _appStore.getStoreByKey(key);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    String themeModeKey = _settingStore?.themeModeKey ?? 'value';

    // Item style
    WidgetConfig configs = widget.widgetConfig!;

    // Item template
    String layout = configs.layout ?? Strings.productLayoutList;

    // Style
    Map<String, dynamic>? margin = get(configs.styles, ['margin'], {});
    Map<String, dynamic>? padding = get(configs.styles, ['padding'], {});
    Map<String, dynamic>? background =
        get(configs.styles, ['background', themeModeKey], {});

    return Container(
      margin: ConvertData.space(margin, 'margin'),
      decoration: decorationColorImage(
        color: ConvertData.fromRGBA(background, Colors.transparent),
      ),
      child: ProductWidget(
        fields: configs.fields,
        styles: configs.styles,
        productsStore: _productsStore,
        layout: layout,
        padding: ConvertData.space(padding, 'padding'),
      ),
    );
  }
}
