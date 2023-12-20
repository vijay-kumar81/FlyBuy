import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/mixins/utility_mixin.dart';
import 'package:flybuy/utils/convert_data.dart';
import 'package:flybuy/widgets/flybuy_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class Style7Item extends StatelessWidget with Utility {
  final Map<String, dynamic>? item;
  final Size size;
  final Color background;
  final double? radius;
  final Function(Map<String, dynamic>? action) onClick;
  final String languageKey;
  final String themeModeKey;
  final String imageKey;

  Style7Item({
    Key? key,
    required this.item,
    required this.onClick,
    required this.languageKey,
    required this.themeModeKey,
    required this.imageKey,
    this.size = const Size(375, 330),
    this.background = Colors.transparent,
    this.radius = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    dynamic image = get(item, ['image'], '');
    BoxFit fit = ConvertData.toBoxFit(get(item, ['imageSize'], 'cover'));
    Map<String, dynamic>? action = get(item, ['action'], {});

    String? linkImage = ConvertData.imageFromConfigs(image, imageKey);

    dynamic title = get(item, ['text1'], {});
    dynamic subTitle = get(item, ['text2'], {});

    String textTitle = ConvertData.textFromConfigs(title, languageKey);
    String textSubtitle = ConvertData.textFromConfigs(subTitle, languageKey);

    TextStyle titleStyle = ConvertData.toTextStyle(title, themeModeKey);
    TextStyle subtitleStyle = ConvertData.toTextStyle(subTitle, themeModeKey);

    String? typeAction = get(action, ['type'], 'none');

    return Container(
      width: size.width,
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(radius!)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ImageAlignmentItem(
        image: FlybuyCacheImage(
          linkImage,
          width: size.width,
          height: size.height,
          fit: fit,
        ),
        title: Text(
          textTitle.toUpperCase(),
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.normal, fontSize: 18)
              .merge(titleStyle),
          textAlign: TextAlign.center,
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(bottom: secondItemPaddingSmall),
          child: Text(
            textSubtitle.toUpperCase(),
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.normal, fontSize: 18)
                .merge(subtitleStyle),
            textAlign: TextAlign.center,
          ),
        ),
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        width: size.width,
        onTap: () => typeAction != 'none' ? onClick(action) : null,
      ),
    );
  }
}
