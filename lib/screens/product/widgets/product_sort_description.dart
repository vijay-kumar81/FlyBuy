import 'package:flybuy/widgets/flybuy_html.dart';
import 'package:flutter/material.dart';

import 'package:flybuy/mixins/utility_mixin.dart';

import 'package:flybuy/models/product/product.dart';

class ProductSortDescription extends StatelessWidget with Utility {
  final Product? product;

  const ProductSortDescription({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlybuyHtml(html: product?.shortDescription ?? '');
  }
}
