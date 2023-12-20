import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/product/product.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/widgets.dart';

class ProductAdditionInformation extends StatelessWidget with TransitionMixin {
  final Product? product;
  final bool? expand;
  final String? align;

  const ProductAdditionInformation(
      {Key? key, this.product, this.expand, this.align = 'left'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    if (expand!) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              translate('product_addition_information'),
              textAlign: ConvertData.toTextAlignDirection(align),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Column(
            children: buildList(context, product: product!),
          )
        ],
      );
    }

    return FlybuyTile(
      title: Text(translate('product_addition_information'),
          style: theme.textTheme.titleSmall),
      isDivider: false,
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, _, __) =>
                ProductAdditionInformationModal(product: product),
            transitionsBuilder: slideTransition,
          ),
        );
      },
    );
  }
}

class ProductAdditionInformationModal extends StatelessWidget with Utility {
  final Product? product;

  ProductAdditionInformationModal({Key? key, this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(translate('product_addition_information'),
            style: theme.textTheme.titleMedium),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              FeatherIcons.x,
              size: 20.0,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        children: buildList(context, product: product!),
      ),
    );
  }
}

Widget buildText(String text, {TextStyle? style}) {
  return Padding(
    padding: paddingVerticalMedium,
    child: Text(text, style: style),
  );
}

List<Widget> buildList(BuildContext context, {required Product product}) {
  ThemeData theme = Theme.of(context);
  return product.attributes!.map((Map<String, dynamic> attr) {
    int index = product.attributes!.indexOf(attr);
    String nameAttr = get(attr, ['name'], '');
    List options = get(attr, ['options'], []);
    String strOptions = options.whereType<String>().toList().join(', ');

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: buildText(nameAttr, style: theme.textTheme.titleSmall),
              ),
              const VerticalDivider(width: 30, thickness: 1),
              Expanded(
                flex: 3,
                child: buildText(strOptions, style: theme.textTheme.bodyLarge),
              )
            ],
          ),
        ),
        if (index < product.attributes!.length - 1)
          const Divider(height: 1, thickness: 1),
      ],
    );
  }).toList();
}
