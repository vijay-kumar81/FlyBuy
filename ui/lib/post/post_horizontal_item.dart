import 'package:flutter/material.dart';
import 'post_item.dart';

/// A post widget display full width on the screen
///
class PostHorizontalItem extends PostItem {
  /// Widget name. It must required
  final Widget name;

  /// Widget image
  final Widget? image;

  /// Widget category
  final Widget? category;

  /// Widget excerpt
  final Widget? excerpt;

  /// Widget date
  final Widget? date;

  /// Widget author
  final Widget? author;

  /// Widget comment
  final Widget? comment;

  /// Widget above
  final Widget? above;

  /// Widget below
  final Widget? below;

  /// Widget below name
  final Widget? belowName;

  ///  width Item
  final double width;

  ///  padding Item
  final EdgeInsetsGeometry padding;

  /// Function click item
  final Function onClick;

  /// shadow card
  final List<BoxShadow>? boxShadow;

  /// Border of item post
  final Border? border;

  /// Color Card of item post
  final Color? color;

  /// Border of item post
  final BorderRadius? borderRadius;

  /// if [isRightImage] = true, widget image will show in the right item
  final bool isRightImage;

  /// Create Post Horizontal Item
  const PostHorizontalItem({
    Key? key,
    required this.name,
    required this.onClick,
    this.image,
    this.category,
    this.excerpt,
    this.date,
    this.author,
    this.comment,
    this.above,
    this.below,
    this.belowName,
    this.width = 300,
    this.padding = EdgeInsets.zero,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.isRightImage = false,
  }) : super(
          key: key,
          borderRadiusPost: borderRadius,
          boxShadowPost: boxShadow,
          colorPost: color,
          borderPost: border,
        );

  @override
  Widget buildLayout(BuildContext context) {
    return InkWell(
      onTap: () => onClick(),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (image != null && !isRightImage) ...[
                image!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (above is Widget) ...[
                      above ?? Container(),
                      const SizedBox(height: 8),
                    ],
                    if (category is Widget) ...[
                      category ?? Container(),
                      const SizedBox(height: 16),
                    ],
                    name,
                    if (belowName is Widget) ...[
                      const SizedBox(height: 8),
                      belowName ?? Container(),
                    ],
                    const SizedBox(height: 8),
                    if (excerpt is Widget) ...[
                      excerpt ?? Container(),
                      const SizedBox(height: 8),
                    ],
                    if (date is Widget) ...[
                      date ?? Container(),
                      const SizedBox(height: 16),
                    ],
                    if (author is Widget || comment is Widget)
                      Wrap(
                        spacing: 16,
                        children: [
                          if (author is Widget) author ?? Container(),
                          comment ?? Container(),
                        ],
                      ),
                    if (below is Widget) ...[
                      const SizedBox(height: 8),
                      below ?? Container(),
                    ],
                  ],
                ),
              ),
              if (image != null && isRightImage) ...[
                const SizedBox(width: 16),
                image!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
