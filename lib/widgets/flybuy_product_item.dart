import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flybuy/constants/color_block.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/filters/filter_quantity.dart';
import 'package:flybuy/mixins/cart_mixin.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/models/product/product_type.dart';
import 'package:flybuy/screens/auth/login_screen.dart';
import 'package:flybuy/screens/product/product.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/url_launcher.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:ui/ui.dart';

class FlybuyProductItem extends StatefulWidget {
  final Product? product;

  // Product item template
  final String? template;

  final double width;

  final double height;

  final Map<String, dynamic>? dataTemplate;

  final Color? background;
  final Color? textColor;
  final Color? subTextColor;
  final Color? priceColor;
  final Color? salePriceColor;
  final Color? regularPriceColor;
  final Color? wishlistColor;

  final Color? labelNewColor;
  final Color? labelNewTextColor;
  final double? labelNewRadius;

  final Color? labelSaleColor;
  final Color? labelSaleTextColor;
  final double? labelSaleRadius;

  final IconData? iconAddCart;
  final double? radiusAddCart;
  final bool? outlineAddCart;

  /// use card vertical or card horizontal
  final bool? enableIconCart;

  final double? radius;
  final double? radiusImage;

  final List<BoxShadow>? boxShadow;

  final Border? border;
  final EdgeInsetsGeometry? padding;

  const FlybuyProductItem({
    Key? key,
    this.product,
    this.template = Strings.productItemContained,
    this.width = 160,
    this.height = 190,
    this.dataTemplate = const {},
    this.background,
    this.textColor,
    this.subTextColor,
    this.priceColor,
    this.salePriceColor,
    this.regularPriceColor,
    this.wishlistColor,
    this.labelNewColor,
    this.labelNewTextColor,
    this.labelNewRadius = 10,
    this.labelSaleColor,
    this.labelSaleTextColor,
    this.labelSaleRadius = 10,
    this.radius,
    this.radiusImage,
    this.boxShadow,
    this.border,
    this.iconAddCart,
    this.outlineAddCart,
    this.radiusAddCart,
    this.enableIconCart,
    this.padding,
  }) : super(key: key);

  @override
  State<FlybuyProductItem> createState() => _FlybuyProductItemState();
}

class _FlybuyProductItemState extends State<FlybuyProductItem>
    with
        CartMixin,
        SnackMixin,
        ProductMixin,
        Utility,
        WishListMixin,
        LoadingMixin,
        ShapeMixin,
        GeneralMixin,
        NavigationMixin {
  late int _quantity;
  bool _loading = false;
  late SettingStore _settingStore;
  late AuthStore _authStore;

  @override
  void didChangeDependencies() {
    _settingStore = Provider.of<SettingStore>(context);
    _authStore = Provider.of<AuthStore>(context);
    int min =
        b2bkingFilterQuantity(context, 1, widget.product ?? Product(), "min") ??
            1;
    int step = b2bkingFilterQuantity(
            context, 1, widget.product ?? Product(), "step") ??
        1;
    _quantity = (min / step).ceil() * step;
    super.didChangeDependencies();
  }

  ///
  /// Handle add to cart
  Future<void> _handleAddToCart(BuildContext context) async {
    TranslateType translate = AppLocalizations.of(context)!.translate;

    if (widget.product == null || widget.product!.id == null) return;

    if (widget.product!.type == productTypeExternal) {
      await launch(widget.product!.externalUrl!);
      return;
    }

    final WidgetConfig? widgetConfig = _settingStore.data != null
        ? _settingStore.data!.settings!['general']!.widgets!['general']
        : null;
    final Map<String, dynamic>? fields =
        widgetConfig != null ? widgetConfig.fields : {};

    bool requiredLogin =
        get(fields, ['forceLoginAddToCart'], false) && !_authStore.isLogin;
    bool enableProductQuickView =
        get(fields, ['enableProductQuickView'], false);

    if (requiredLogin) {
      Navigator.of(context).pushNamed(
        LoginScreen.routeName,
        arguments: {
          'showMessage': ({String? message}) {
            avoidPrint('Login Success');
          },
        },
      );
      return;
    }

    if (enableProductQuickView) {
      _showQuickView();
      return;
    }

    if (widget.product!.type == productTypeVariable ||
        widget.product!.type == productTypeGrouped ||
        widget.product!.type == productTypeAppointment) {
      _navigate(context);
      return;
    }

    setState(() {
      _loading = true;
    });
    try {
      await addToCart(productId: widget.product!.id, qty: _quantity);
      if (mounted) {
        showSuccess(
          context,
          translate('product_add_to_cart_success'),
          action: SnackBarAction(
            label: translate('product_view_cart'),
            textColor: Colors.white,
            onPressed: () {
              navigate(context, {
                'type': 'tab',
                'route': '/',
                'args': {'key': 'screens_cart'}
              });
            },
          ),
        );
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showError(context, e);
        setState(() {
          _loading = false;
        });
      }
    }
  }

  ///
  /// Handle navigate
  void _navigate(BuildContext context) {
    if (widget.product == null || widget.product!.id == null) return;
    Navigator.pushNamed(context,
        '${ProductScreen.routeName}/${widget.product!.id}/${widget.product!.slug}',
        arguments: {'product': widget.product});
  }

  ///
  /// Handle wishlist
  void _wishlist(BuildContext context) {
    if (widget.product == null || widget.product!.id == null) return;
    addWishList(productId: widget.product!.id);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    String themeModeKey = _settingStore.themeModeKey;

    final WidgetConfig? widgetConfig = _settingStore.data != null
        ? _settingStore.data!.settings!['general']!.widgets!['general']
        : null;
    final Map<String, dynamic>? fields =
        widgetConfig != null ? widgetConfig.fields : {};

    bool productItemLabelEnableRating =
        get(fields, ['productItemLabelEnableRating'], true);
    bool productItemLabelEnableSale =
        get(fields, ['productItemLabelEnableSale'], true);
    bool productItemLabelEnableNew =
        get(fields, ['productItemLabelEnableNew'], true);
    bool productItemEnableQuantity =
        get(fields, ['productItemEnableQuantity'], false);
    bool productItemEnableAddCart =
        get(fields, ['productItemEnableAddCart'], true);

    bool? enableLabelNew =
        get(widget.dataTemplate, ['enableLabelNew'], productItemLabelEnableNew);
    bool? enableLabelSale = get(
        widget.dataTemplate, ['enableLabelSale'], productItemLabelEnableSale);
    bool? enableCategory = get(widget.dataTemplate, ['enableCategory'], true);
    bool? enableRating = get(
        widget.dataTemplate, ['enableRating'], productItemLabelEnableRating);
    bool enableQuantity =
        get(widget.dataTemplate, ['enableQuantity'], productItemEnableQuantity);
    bool enableAddCart =
        get(widget.dataTemplate, ['enableAddCart'], productItemEnableAddCart);
    String thumbSizes = get(widget.dataTemplate, ['thumbSizes'], 'src');
    BoxFit fit =
        ConvertData.toBoxFit(get(widget.dataTemplate, ['imageSize'], 'cover'));

    TextStyle? stylePrice =
        theme.textTheme.titleSmall?.copyWith(color: widget.priceColor);
    TextStyle? styleSale = theme.textTheme.titleSmall
        ?.copyWith(color: widget.salePriceColor ?? ColorBlock.red);
    TextStyle? styleRegular = theme.textTheme.titleSmall?.copyWith(
        color: widget.regularPriceColor, fontWeight: FontWeight.normal);
    TextStyle? styleTextFrom =
        theme.textTheme.bodySmall?.copyWith(color: widget.subTextColor);

    dynamic customAboveName = get(widget.dataTemplate, ['customAboveName']);
    dynamic customAbovePrice = get(widget.dataTemplate, ['customAbovePrice']);
    dynamic customAboveRating = get(widget.dataTemplate, ['customAboveRating']);

    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        return Observer(
          builder: (_) {
            switch (widget.template) {
              case Strings.productItemHorizontal:
                double widthImage = 86;
                double heightImage =
                    (widthImage * widget.height) / widget.width;
                double widthView = widget.width;
                return SizedBox(
                  width: widthView,
                  child: ProductHorizontalItem(
                    image: buildImage(
                      context,
                      product: widget.product!,
                      width: widthImage,
                      height: heightImage,
                      borderRadius: widget.radiusImage,
                      fit: fit,
                      thumbSizes: thumbSizes,
                    ),
                    name: buildName(
                      context,
                      product: widget.product!,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: widget.textColor),
                    ),
                    price: buildPrice(
                      context,
                      product: widget.product!,
                      priceStyle: stylePrice,
                      saleStyle: styleSale,
                      regularStyle: styleRegular,
                      styleFrom: styleTextFrom,
                    ),
                    tagExtra: enableLabelNew! || enableLabelSale!
                        ? buildTagExtra(
                            context,
                            product: widget.product!,
                            enableNew: enableLabelNew,
                            newColor: widget.labelNewColor,
                            newTextColor: widget.labelNewTextColor,
                            newRadius: widget.labelNewRadius,
                            enableSale: enableLabelSale,
                            saleColor: widget.labelSaleColor,
                            saleTextColor: widget.labelSaleTextColor,
                            saleRadius: widget.labelSaleRadius,
                          )
                        : null,
                    addCart: enableAddCart
                        ? _loading
                            ? _buildLoading(context)
                            : buildAddCart(
                                context,
                                product: widget.product!,
                                onTap: () => _handleAddToCart(context),
                                icon: widget.iconAddCart ?? FeatherIcons.plus,
                                radius: widget.radiusAddCart ?? 8,
                                isButtonOutline: widget.outlineAddCart ?? false,
                              )
                        : null,
                    rating: enableRating!
                        ? buildRating(context,
                            product: widget.product!,
                            color: widget.subTextColor)
                        : null,
                    quantity: enableQuantity
                        ? buildQuantityItem(
                            context,
                            product: widget.product!,
                            quantity: _quantity,
                            onChanged: (int value) => setState(() {
                              _quantity = value;
                            }),
                          )
                        : null,
                    aboveName: buildQueryData(
                      context,
                      product: widget.product,
                      query: customAboveName,
                      color: widget.subTextColor,
                      languageKey: _settingStore.languageKey,
                    ),
                    abovePrice: buildQueryData(
                      context,
                      product: widget.product,
                      query: customAbovePrice,
                      color: widget.subTextColor,
                      languageKey: _settingStore.languageKey,
                    ),
                    aboveRating: buildQueryData(
                      context,
                      product: widget.product,
                      query: customAboveRating,
                      color: widget.subTextColor,
                      languageKey: _settingStore.languageKey,
                    ),
                    borderRadius: BorderRadius.circular(widget.radius ?? 0),
                    border: widget.border,
                    boxShadow: widget.boxShadow,
                    color: widget.background ?? Colors.transparent,
                    onClick: () => _navigate(context),
                    padding: widget.padding ?? EdgeInsets.zero,
                  ),
                );

              case Strings.productItemEmerge:
                return ProductEmergeItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.radiusImage,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: widget.textColor),
                  ),
                  price: buildPrice(
                    context,
                    product: widget.product!,
                    priceStyle: stylePrice,
                    saleStyle: styleSale,
                    regularStyle: styleRegular,
                    styleFrom: styleTextFrom,
                  ),
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  addCart: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : buildAddCart(
                              context,
                              product: widget.product!,
                              onTap: () => _handleAddToCart(context),
                              icon: widget.iconAddCart ?? FeatherIcons.plus,
                              radius: widget.radiusAddCart ?? 34,
                              isButtonOutline: widget.outlineAddCart ?? false,
                            )
                      : null,
                  rating: enableRating!
                      ? buildRating(context,
                          product: widget.product!, color: widget.subTextColor)
                      : null,
                  category: enableCategory!
                      ? buildCategory(context,
                          product: widget.product!, color: widget.subTextColor)
                      : Container(),
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    isSelected: existWishList(productId: widget.product!.id),
                    color: widget.wishlistColor,
                    onTap: () => _wishlist(context),
                  ),
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  aboveRating: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveRating,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  width: widget.width,
                  borderRadius: BorderRadius.circular(widget.radius ?? 0),
                  border: widget.border,
                  boxShadow: widget.boxShadow,
                  color: widget.background,
                  padding: widget.padding,
                  onClick: () => _navigate(context),
                );
              case Strings.productItemVertical:
                return ProductVerticalItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.radiusImage,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: widget.textColor),
                  ),
                  price: buildPrice(
                    context,
                    product: widget.product!,
                    priceStyle: stylePrice,
                    saleStyle: styleSale,
                    regularStyle: styleRegular,
                    styleFrom: styleTextFrom,
                  ),
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  addCart: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : buildAddCart(
                              context,
                              product: widget.product!,
                              icon: widget.iconAddCart ?? FeatherIcons.plus,
                              radius: widget.radiusAddCart ?? 34,
                              isButtonOutline: widget.outlineAddCart ?? false,
                              onTap: () => _handleAddToCart(context),
                            )
                      : null,
                  rating: enableRating!
                      ? buildRating(context,
                          product: widget.product!, color: widget.subTextColor)
                      : null,
                  category: enableCategory!
                      ? buildCategory(context,
                          product: widget.product!, color: widget.subTextColor)
                      : Container(),
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    color: widget.wishlistColor,
                    isSelected: existWishList(productId: widget.product!.id),
                    onTap: () => _wishlist(context),
                  ),
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  aboveRating: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveRating,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  width: widget.width,
                  borderRadius: BorderRadius.circular(widget.radius ?? 0),
                  border: widget.border,
                  boxShadow: widget.boxShadow,
                  color: widget.background,
                  padding: widget.padding,
                  onClick: () => _navigate(context),
                );
              case Strings.productItemVerticalCenter:
                return ProductVerticalItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.radiusImage,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: widget.textColor),
                  ),
                  price: buildPrice(
                    context,
                    product: widget.product!,
                    priceStyle: stylePrice,
                    saleStyle: styleSale,
                    regularStyle: styleRegular,
                    styleFrom: styleTextFrom,
                  ),
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  addCart: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : buildAddCart(
                              context,
                              product: widget.product!,
                              enableIconCart: widget.enableIconCart ?? false,
                              icon: widget.iconAddCart,
                              text: translate('product_add_to_cart'),
                              isButtonOutline: widget.outlineAddCart ?? true,
                              radius: widget.radiusAddCart ?? 8,
                              onTap: () => _handleAddToCart(context),
                            )
                      : null,
                  rating: enableRating!
                      ? buildRating(context,
                          product: widget.product!, color: widget.subTextColor)
                      : null,
                  category: enableCategory!
                      ? buildCategory(context,
                          product: widget.product!, color: widget.subTextColor)
                      : false as Widget,
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    color: widget.wishlistColor,
                    isSelected: existWishList(productId: widget.product!.id),
                    onTap: () => _wishlist(context),
                  ),
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                    textAlign: TextAlign.center,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                    textAlign: TextAlign.center,
                  ),
                  aboveRating: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveRating,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                    textAlign: TextAlign.center,
                  ),
                  width: widget.width,
                  type: ProductVerticalItemType.center,
                  borderRadius: BorderRadius.circular(widget.radius ?? 0),
                  border: widget.border,
                  boxShadow: widget.boxShadow,
                  color: widget.background,
                  padding: widget.padding,
                  onClick: () => _navigate(context),
                );

              case Strings.productItemCardHorizontal:
                bool enablePrice =
                    get(widget.dataTemplate, ['enablePrice'], false);
                double? opacity = ConvertData.stringToDouble(
                    get(widget.dataTemplate, ['opacity'], 0.6), 0.6);
                dynamic opacityColor =
                    get(widget.dataTemplate, ['opacityColor'], Colors.black);
                Color colorOpacity = opacityColor is Color
                    ? opacityColor
                    : opacityColor is Map
                        ? ConvertData.fromRGBA(
                            get(opacityColor, [themeModeKey], {}), Colors.black)
                        : Colors.black;
                return ProductCardHorizontalItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.radiusImage,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  category: enableCategory!
                      ? buildCategory(context,
                          product: widget.product!,
                          color: widget.subTextColor ?? Colors.white)
                      : null,
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: widget.textColor ?? Colors.white),
                  ),
                  price: enablePrice
                      ? buildPrice(
                          context,
                          product: widget.product!,
                          priceStyle: stylePrice,
                          saleStyle: styleSale,
                          regularStyle: styleRegular,
                          styleFrom: styleTextFrom,
                        )
                      : null,
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    color: widget.wishlistColor ?? Colors.black,
                    isSelected: existWishList(productId: widget.product!.id),
                    onTap: () => _wishlist(context),
                  ),
                  addCart: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : buildAddCart(
                              context,
                              product: widget.product!,
                              enableIconCart: widget.enableIconCart ?? false,
                              icon: widget.iconAddCart,
                              text: translate('product_buy_product'),
                              radius: widget.radiusAddCart ?? 8,
                              isButtonOutline: widget.outlineAddCart ?? false,
                              onTap: () => _handleAddToCart(context),
                            )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  width: widget.width,
                  padding: widget.padding ?? paddingMedium,
                  borderRadius: BorderRadius.circular(widget.radius ?? 8),
                  radiusImage: widget.radiusImage ?? 8,
                  border: widget.border,
                  boxShadow: widget.boxShadow,
                  color: widget.background,
                  opacity: opacity,
                  colorOpacity: colorOpacity,
                  onClick: () => _navigate(context),
                );

              case Strings.productItemCardVertical:
                dynamic customBelowWishlist =
                    get(widget.dataTemplate, ['customBelowWishlist']);

                return ProductCardVerticalItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.radiusImage,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  category: enableCategory!
                      ? buildCategory(context,
                          product: widget.product!,
                          color: widget.subTextColor ?? Colors.white)
                      : null,
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: widget.textColor ?? Colors.white),
                  ),
                  price: buildPrice(
                    context,
                    product: widget.product!,
                    priceStyle: stylePrice,
                    saleStyle: styleSale,
                    regularStyle: styleRegular,
                    styleFrom: styleTextFrom,
                  ),
                  rating: enableRating!
                      ? buildRating(context,
                          product: widget.product!, color: widget.subTextColor)
                      : null,
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    color: widget.wishlistColor ?? Colors.black,
                    isSelected: existWishList(productId: widget.product!.id),
                    onTap: () => _wishlist(context),
                  ),
                  addCart: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : SizedBox(
                              width: double.infinity,
                              child: buildAddCart(
                                context,
                                product: widget.product!,
                                enableIconCart: widget.enableIconCart ?? false,
                                icon: widget.iconAddCart,
                                text: translate('product_buy_product'),
                                radius: widget.radiusAddCart ?? 8,
                                isButtonOutline: widget.outlineAddCart ?? false,
                                onTap: () => _handleAddToCart(context),
                              ),
                            )
                      : null,
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  aboveRating: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveRating,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  besideWishlist: buildQueryData(
                    context,
                    product: widget.product,
                    query: customBelowWishlist,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  borderRadius: BorderRadius.circular(widget.radius ?? 8),
                  border: widget.border,
                  color: widget.background,
                  boxShadow: widget.boxShadow ?? initBoxShadow,
                  padding: widget.padding ?? paddingMedium,
                  width: widget.width,
                  onClick: () => _navigate(context),
                );

              case Strings.productItemCurve:
                double pad =
                    widget.padding != null ? widget.padding!.horizontal : 16;
                double widthImage = widget.width - pad;
                double heightImage =
                    (widthImage * widget.height) / widget.width;
                bool enableProgressSale =
                    get(widget.dataTemplate, ['enableProgressSale'], false);

                return ProductCurveItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widthImage,
                    height: heightImage,
                    borderRadius: widget.radiusImage ?? 12,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: widget.textColor),
                  ),
                  price: buildPrice(
                    context,
                    product: widget.product!,
                    priceStyle: stylePrice,
                    saleStyle: styleSale,
                    regularStyle: styleRegular,
                    styleFrom: styleTextFrom,
                  ),
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    color: widget.wishlistColor ?? Colors.black,
                    isSelected: existWishList(productId: widget.product!.id),
                    onTap: () => _wishlist(context),
                  ),
                  addCart: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : buildAddCart(
                              context,
                              product: widget.product!,
                              icon: widget.iconAddCart ?? FeatherIcons.plus,
                              radius: widget.radiusAddCart ?? 8,
                              isButtonOutline: widget.outlineAddCart ?? false,
                              onTap: () => _handleAddToCart(context),
                              enableAllRadius: false,
                            )
                      : null,
                  rating: enableRating!
                      ? buildRating(context,
                          product: widget.product!,
                          showNumber: true,
                          color: widget.subTextColor)
                      : null,
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  progressSale: enableProgressSale
                      ? buildProgressSale(
                          context,
                          product: widget.product,
                          shimmerWidth: double.infinity,
                        )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  aboveRating: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveRating,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  width: widget.width,
                  borderRadius: BorderRadius.circular(widget.radius ?? 16),
                  border: widget.border,
                  boxShadow: widget.boxShadow ?? initBoxShadow,
                  color: widget.background ?? theme.cardColor,
                  padding: widget.padding ?? paddingTiny,
                  onClick: () => _navigate(context),
                );

              default:
                return ProductContainedItem(
                  image: buildImage(
                    context,
                    product: widget.product!,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.radiusImage,
                    fit: fit,
                    thumbSizes: thumbSizes,
                  ),
                  name: buildName(
                    context,
                    product: widget.product!,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: widget.textColor),
                  ),
                  price: buildPrice(
                    context,
                    product: widget.product!,
                    priceStyle: stylePrice,
                    saleStyle: styleSale,
                    regularStyle: styleRegular,
                    styleFrom: styleTextFrom,
                  ),
                  tagExtra: enableLabelNew! || enableLabelSale!
                      ? buildTagExtra(
                          context,
                          product: widget.product!,
                          enableNew: enableLabelNew,
                          newColor: widget.labelNewColor,
                          newTextColor: widget.labelNewTextColor,
                          newRadius: widget.labelNewRadius,
                          enableSale: enableLabelSale,
                          saleColor: widget.labelSaleColor,
                          saleTextColor: widget.labelSaleTextColor,
                          saleRadius: widget.labelSaleRadius,
                        )
                      : null,
                  wishlist: buildWishlist(
                    context,
                    product: widget.product!,
                    color: widget.wishlistColor ?? Colors.black,
                    isSelected: existWishList(productId: widget.product!.id),
                    onTap: () => _wishlist(context),
                  ),
                  addCard: enableAddCart
                      ? _loading
                          ? _buildLoading(context)
                          : buildAddCart(
                              context,
                              product: widget.product!,
                              icon: widget.iconAddCart ?? FeatherIcons.plus,
                              radius: widget.radiusAddCart ?? 8,
                              isButtonOutline: widget.outlineAddCart ?? false,
                              onTap: () => _handleAddToCart(context),
                            )
                      : null,
                  rating: enableRating!
                      ? buildRating(context,
                          product: widget.product!, color: widget.subTextColor)
                      : null,
                  quantity: enableQuantity
                      ? buildQuantityItem(
                          context,
                          product: widget.product!,
                          quantity: _quantity,
                          onChanged: (int value) => setState(() {
                            _quantity = value;
                          }),
                        )
                      : null,
                  aboveName: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveName,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  abovePrice: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAbovePrice,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  aboveRating: buildQueryData(
                    context,
                    product: widget.product,
                    query: customAboveRating,
                    color: widget.subTextColor,
                    languageKey: _settingStore.languageKey,
                  ),
                  width: widget.width,
                  borderRadius: BorderRadius.circular(widget.radius ?? 0),
                  border: widget.border,
                  boxShadow: widget.boxShadow,
                  color: widget.background ?? Colors.transparent,
                  padding: widget.padding,
                  onClick: () => _navigate(context),
                );
            }
          },
        );
      },
    );
  }

  _buildLoading(BuildContext context) {
    return SizedBox(
        width: 32, height: 32, child: Center(child: entryLoading(context)));
  }

  _showQuickView() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      shape: borderRadiusTop(),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: layoutPadding),
          child: ProductScreen(
            store: _settingStore,
            args: {'product': widget.product},
            isQuickView: true,
          ),
        );
      },
    );
  }
}
