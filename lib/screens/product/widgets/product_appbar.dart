import 'package:awesome_icons/awesome_icons.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/product/product.dart';
import 'package:flybuy/screens/product/product_action_share.dart';
import 'package:flybuy/widgets/flybuy_cart_icon.dart';

class ProductAppbar extends StatefulWidget {
  final Map<String, dynamic>? configs;
  final Product? product;
  final Map<String, dynamic>? fields;

  const ProductAppbar({
    Key? key,
    this.configs,
    this.product,
    this.fields,
  }) : super(key: key);

  @override
  State<ProductAppbar> createState() => _ProductAppbarState();
}

class _ProductAppbarState extends State<ProductAppbar>
    with AppBarMixin, Utility, NavigationMixin, WishListMixin {
  @override
  Widget build(BuildContext context) {
    bool enableAppbarSearch =
        get(widget.configs, ['enableAppbarSearch'], false);
    bool enableAppbarHome = get(widget.configs, ['enableAppbarHome'], false);
    bool enableAppbarShare = get(widget.configs, ['enableAppbarShare'], true);
    bool enableAppbarWishList =
        get(widget.configs, ['enableAppbarWishList'], true);
    bool enableAppbarCart = get(widget.configs, ['enableAppbarCart'], true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leadingPined(),
        Row(
          children: [
            if (enableAppbarHome) iconHome(context),
            if (enableAppbarSearch) iconSearch(context),
            if (enableAppbarShare) iconShare(context),
            if (enableAppbarWishList) iconWishList(context),
            if (enableAppbarCart) iconCart(context)
          ],
        )
      ],
    );
  }

  Widget iconHome(BuildContext context) {
    return Row(
      children: [
        leadingButton(
          icon: FeatherIcons.home,
          onPress: () => navigate(context, {
            'type': 'tab',
            'route': '/',
            'args': {'key': 'screens_home'}
          }),
        ),
        const SizedBox(width: 8.0)
      ],
    );
  }

  Widget iconSearch(BuildContext context) {
    return Row(
      children: [
        leadingButton(
          icon: FeatherIcons.search,
          onPress: () => navigate(context, {
            'type': 'tab',
            'route': '/',
            'args': {'key': 'screens_category'}
          }),
        ),
        const SizedBox(width: 8.0)
      ],
    );
  }

  Widget iconWishList(BuildContext context) {
    return Row(
      children: [
        leadingButton(
          icon: existWishList(productId: widget.product!.id)
              ? FontAwesomeIcons.solidHeart
              : FontAwesomeIcons.heart,
          onPress: () {
            addWishList(productId: widget.product!.id);
          },
        ),
        const SizedBox(width: 8.0)
      ],
    );
  }

  Widget iconShare(BuildContext context) {
    return Row(
      children: [
        leadingButton(
          icon: FeatherIcons.share2,
          onPress: () => productActionShare(
            permalink: widget.product!.permalink!,
            name: widget.product!.name,
            context: context,
            fields: widget.fields,
          ),
        ),
        const SizedBox(width: 8.0)
      ],
    );
  }

  Widget iconCart(BuildContext context) {
    return Row(
      children: [
        FlybuyCartIcon(
          color:
              Theme.of(context).appBarTheme.backgroundColor!.withOpacity(0.6),
        ),
      ],
    );
  }
}
