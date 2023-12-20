import 'package:flutter/material.dart';
import 'product_item.dart';

/// A post widget display full width on the screen
///
class ProductCardVerticalItem extends ProductItem {
  /// Widget image
  final Widget image;

  /// Widget name. It must required
  final Widget name;

  /// Widget price
  final Widget price;

  /// Widget rating
  final Widget? rating;

  /// Widget wishlist
  final Widget? wishlist;

  /// Widget category
  final Widget? category;

  /// Widget button Add cart
  final Widget? addCart;

  /// Widget extra tags in information
  final Widget? tagExtra;

  /// Widget quantity
  final Widget? quantity;

  /// Widget above name
  final Widget? aboveName;

  /// Widget above price
  final Widget? abovePrice;

  /// Widget above rating
  final Widget? aboveRating;

  /// Widget beside wishlist
  final Widget? besideWishlist;

  /// Width item
  final double? width;

  /// shadow card
  final List<BoxShadow>? boxShadow;

  /// Border of item post
  final Border? border;

  /// Color Card of item post
  final Color? color;

  /// Border of item post
  final BorderRadius? borderRadius;

  /// Function click item
  final Function onClick;

  /// Padding content
  final EdgeInsetsGeometry? padding;

  /// Create Product Contained Item
  const ProductCardVerticalItem({
    Key? key,
    required this.image,
    required this.name,
    required this.onClick,
    required this.price,
    this.rating,
    this.wishlist,
    this.category,
    this.addCart,
    this.tagExtra,
    this.quantity,
    this.aboveName,
    this.abovePrice,
    this.aboveRating,
    this.besideWishlist,
    this.width,
    this.boxShadow,
    this.border,
    this.color = Colors.transparent,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding,
  }) : super(
          key: key,
          colorProduct: color,
          boxShadowProduct: boxShadow,
          borderProduct: border,
          borderRadiusProduct: borderRadius,
        );

  @override
  Widget buildLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (_, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;
        double screenWidth = MediaQuery.of(context).size.width;
        double defaultWidth = maxWidth != double.infinity ? maxWidth : screenWidth;
        double widthItem = width ?? defaultWidth;
        Widget imageWidget = tagExtra != null
            ? Stack(
                children: [
                  image,
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: tagExtra,
                    ),
                  ),
                ],
              )
            : image;
        return SizedBox(
          width: widthItem,
          child: InkWell(
            onTap: () => onClick(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageWidget,
                Padding(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (category is Widget) ...[
                        category ?? Container(),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                aboveName ?? Container(),
                                name,
                                if (rating is Widget || aboveRating is Widget) ...[
                                  const SizedBox(height: 8),
                                  aboveRating ?? Container(),
                                  rating ?? Container(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [abovePrice ?? Container(), price],
                          ),
                        ],
                      ),
                      if (quantity is Widget || addCart is Widget) ...[
                        const SizedBox(height: 24),
                        quantity ?? Container(),
                        if (quantity is Widget && addCart is Widget) const SizedBox(height: 12),
                        addCart ?? Container(),
                      ],
                      if (besideWishlist is Widget || wishlist is Widget) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: besideWishlist ?? Container()),
                            wishlist ?? Container(),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
