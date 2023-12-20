import 'package:flutter/material.dart';
import 'post_item.dart';

/// A post widget display full width on the screen
///
class PostContainedItem extends PostItem {
  /// Widget image
  final Widget? image;

  /// Widget name. It must required
  final Widget name;

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

  /// Widget bottom left
  final Widget? bottomLeft;

  /// Widget bottom right
  final Widget? bottomRight;

  /// Widget top left image
  final Widget? topLeftImage;

  /// Widget top right image
  final Widget? topRightImage;

  /// Widget above name
  final Widget? aboveName;

  /// Width item
  final double width;

  /// Function click item
  final Function? onClick;

  /// shadow card
  final List<BoxShadow>? boxShadow;

  /// Border of item post
  final Border? border;

  /// Color Card of item post
  final Color? color;

  /// Border of item post
  final BorderRadius? borderRadius;

  /// Padding content image of safe
  final EdgeInsetsGeometry paddingContent;

  /// Padding contained item
  final EdgeInsetsGeometry padding;

  /// Create Post Contained Item
  const PostContainedItem({
    Key? key,
    required this.name,
    this.image,
    this.onClick,
    this.category,
    this.excerpt,
    this.date,
    this.author,
    this.comment,
    this.bottomLeft,
    this.bottomRight,
    this.topLeftImage,
    this.topRightImage,
    this.aboveName,
    this.color,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.width = 300,
    this.paddingContent = const EdgeInsets.only(top: 8),
    this.padding = EdgeInsets.zero,
  }) : super(
          key: key,
          colorPost: color,
          borderPost: border,
          borderRadiusPost: borderRadius,
          boxShadowPost: boxShadow,
        );

  @override
  Widget buildLayout(BuildContext context) {
    Widget? renderImage;
    if (image is Widget) {
      renderImage = category is Widget || topLeftImage is Widget || topRightImage is Widget
          ? Stack(
              children: [
                image!,
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            category ?? Container(),
                            if (category != null && topLeftImage != null) const SizedBox(height: 8),
                            topLeftImage ?? Container(),
                          ],
                        ),
                      ),
                      if (topRightImage != null) ...[
                        const SizedBox(width: 12),
                        Expanded(child: topRightImage ?? Container()),
                      ],
                    ],
                  ),
                ),
              ],
            )
          : image;
    }

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: () => onClick?.call(),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (renderImage is Widget) renderImage,
              Padding(
                padding: paddingContent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (aboveName != null) ...[
                      aboveName!,
                      const SizedBox(height: 5),
                    ],
                    name,
                    if (excerpt is Widget) ...[
                      const SizedBox(height: 8),
                      excerpt ?? Container(),
                    ],
                    if (date is Widget || author is Widget || comment is Widget) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (date is Widget) date ?? Container(),
                          if (author is Widget) author ?? Container(),
                          comment ?? Container(),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (bottomLeft != null || bottomRight != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (bottomLeft != null) Flexible(child: bottomLeft!),
                    if (bottomLeft != null && bottomRight != null) const SizedBox(width: 16),
                    if (bottomRight != null) Flexible(child: bottomRight!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
