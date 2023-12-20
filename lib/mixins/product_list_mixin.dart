import 'dart:convert';

import 'package:flybuy/mixins/utility_mixin.dart';
import 'package:flybuy/models/brand/brand.dart';
import 'package:flybuy/models/product_category/product_category.dart';
import 'package:flybuy/utils/convert_data.dart';

abstract class ProductListMixin {
  /// Filter product on catalog screen
  bool productCatalog(product) {
    return product.catalogVisibility == 'visible' ||
        product.catalogVisibility == 'catalog';
  }

  List<ProductCategory>? getCategories(Map? args) {
    return get(args, ['category']) is ProductCategory
        ? [
            get(args, ['category'])
          ]
        : ConvertData.stringToInt(get(args, ['id'])) > 0
            ? [
                ProductCategory(
                  id: ConvertData.stringToInt(get(args, ['id'])),
                  name: get(args, ['name'], ''),
                  categories: [],
                )
              ]
            : null;
  }

  Brand? getBrand(Map? args) {
    dynamic brand = get(args, ['brand']);
    if (brand is Brand) {
      return brand;
    }
    if (brand is String && brand.isNotEmpty) {
      Map<String, dynamic> data = json.decode(brand);
      return Brand.fromJson(data);
    }
    return null;
  }

  List<int>? getTag(Map? args) {
    List<int>? data;
    dynamic tagArgs = get(args, ['tag'], '');
    if (tagArgs is List<int>) {
      data = tagArgs;
    } else if (tagArgs is String && tagArgs.isNotEmpty) {
      List tags = tagArgs.split(',');
      data = tags.map((t) => ConvertData.stringToInt(t)).toList();
    }
    return data;
  }
}
