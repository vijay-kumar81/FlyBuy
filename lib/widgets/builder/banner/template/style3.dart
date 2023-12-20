import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/flybuy_cache_image.dart';
import 'package:flutter/material.dart';
import 'package:ui/ui.dart';

class Style3Item extends StatelessWidget with Utility {
  final Map<String, dynamic>? item;
  final Size size;
  final Color background;
  final double? radius;
  final Function(Map<String, dynamic>? action) onClick;
  final String languageKey;
  final String themeModeKey;
  final String imageKey;

  Style3Item({
    Key? key,
    required this.item,
    required this.onClick,
    required this.languageKey,
    required this.themeModeKey,
    required this.imageKey,
    this.size = const Size(375, 330),
    this.background = Colors.transparent,
    this.radius,
  }) : super(key: key);

  Widget buildContent({required double maxWidth, required Widget child}) {
    return SizedBox(
      width: maxWidth,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    dynamic image = get(item, ['image'], '');
    BoxFit fit = ConvertData.toBoxFit(get(item, ['imageSize'], 'cover'));
    bool enableButton = get(item, ['enableButton'], true);
    Map<String, dynamic>? action = get(item, ['action'], {});

    String? linkImage = ConvertData.imageFromConfigs(image, imageKey);

    dynamic title = get(item, ['text1'], {});
    dynamic subTitle = get(item, ['text2'], {});
    dynamic button = get(item, ['textButton'], {});

    String textTitle = ConvertData.textFromConfigs(title, languageKey);
    String textSubTitle = ConvertData.textFromConfigs(subTitle, languageKey);
    String textButton = ConvertData.textFromConfigs(button, languageKey);

    TextStyle titleStyle = ConvertData.toTextStyle(title, themeModeKey);
    TextStyle subtitleStyle = ConvertData.toTextStyle(subTitle, themeModeKey);
    TextStyle buttonStyle = ConvertData.toTextStyle(button, themeModeKey);

    String? typeAction = get(action, ['type'], 'none');

    double maxWidth = size.width / 2;
    return Container(
      width: size.width,
      decoration: BoxDecoration(
          color: background, borderRadius: BorderRadius.circular(radius ?? 0)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ImageAlignmentItem(
        image: FlybuyCacheImage(
          linkImage,
          width: size.width,
          height: size.height,
          fit: fit,
        ),
        title: buildContent(
          maxWidth: maxWidth,
          child: Text(
            textTitle,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.normal, fontSize: 40)
                .merge(titleStyle),
          ),
        ),
        trailing: enableButton
            ? Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                color: buttonStyle.backgroundColor,
                child: Text(
                  textButton,
                  style: theme.textTheme.bodyLarge?.merge(buttonStyle),
                ),
              )
            : null,
        leading: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: secondPaddingHorizontalSmall,
          color: subtitleStyle.backgroundColor ?? Colors.transparent,
          child: Text(
            textSubTitle,
            style: theme.textTheme.bodyLarge?.merge(subtitleStyle),
          ),
        ),
        crossAxisAlignment: CrossAxisAlignment.start,
        width: size.width,
        onTap: () => typeAction != 'none' ? onClick(action) : null,
      ),
    );
  }
}
