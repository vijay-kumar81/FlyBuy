import 'package:flybuy/models/models.dart';
import 'package:flybuy/types/types.dart';
import 'package:flutter/material.dart';

class LayoutCarousel extends StatelessWidget {
  final List<ProductCategory?>? categories;
  final BuildItemProductCategoryType? buildItem;
  final double? pad;
  final EdgeInsetsDirectional? padding;

  const LayoutCarousel({
    Key? key,
    this.categories,
    this.buildItem,
    this.pad = 0,
    this.padding = EdgeInsetsDirectional.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => Column(
        children: [
          buildItem!(context,
              category: categories![index], width: null, height: null)
        ],
      ),
      separatorBuilder: (context, index) => SizedBox(width: pad),
      itemCount: categories!.length,
    );
  }
}
