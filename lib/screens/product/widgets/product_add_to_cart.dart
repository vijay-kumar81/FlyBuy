import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/product/product.dart';
import 'package:flybuy/models/product/product_type.dart';
import 'package:flybuy/utils/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/utils/url_launcher.dart';

class ProductAddToCart extends StatelessWidget with LoadingMixin {
  final Product? product;
  final Function? onPress;
  final bool? loading;

  const ProductAddToCart({
    Key? key,
    this.product,
    this.onPress,
    this.loading,
  }) : super(key: key);

  void addToCart() async {
    if (loading!) return;
    if (product!.type == productTypeExternal) {
      await launch(product!.externalUrl!);
      return;
    }

    onPress!();
  }

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = product?.stockStatus == 'outofstock';
    return SizedBox(
      height: 48,
      width: 159,
      child: ElevatedButton(
        onPressed: isOutOfStock ? null : addToCart,
        child: loading!
            ? entryLoading(context, color: Colors.white)
            : Text(
                product!.type == productTypeExternal
                    ? product!.buttonText != null && product!.buttonText != ''
                        ? product!.buttonText!
                        : AppLocalizations.of(context)!
                            .translate('product_buy_now')
                    : AppLocalizations.of(context)!
                        .translate('product_add_to_cart'),
              ),
      ),
    );
  }
}
