import 'package:flybuy/constants/styles.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/app_localization.dart';
import 'package:flybuy/utils/convert_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'get_field.dart';
import 'validate_field.dart';

class AddressFieldColorPicker extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final bool borderFields;
  final Map<String, dynamic> field;

  const AddressFieldColorPicker({
    Key? key,
    this.value,
    this.borderFields = false,
    required this.onChanged,
    required this.field,
  }) : super(key: key);

  @override
  State<AddressFieldColorPicker> createState() =>
      _AddressFieldColorPickerState();
}

class _AddressFieldColorPickerState extends State<AddressFieldColorPicker>
    with Utility {
  final _txtInputText = TextEditingController();

  @override
  void initState() {
    getText();
    _txtInputText.addListener(_onChanged);
    super.initState();
  }

  @override
  void dispose() {
    _txtInputText.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AddressFieldColorPicker oldWidget) {
    /// Update only if this widget initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (oldWidget.value != widget.value &&
          widget.value != _txtInputText.text) {
        getText();
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  void getText() {
    String defaultValue = get(widget.field, ['default'], '');
    _txtInputText.text = widget.value ?? defaultValue;
  }

  /// Save data in current state
  ///
  _onChanged() {
    if (_txtInputText.text != widget.value) {
      widget.onChanged(_txtInputText.text);
    }
  }

  void clearValue() {
    _txtInputText.clear();
  }

  void showColor(BuildContext context, ThemeData theme) async {
    Color? value = await showModalBottomSheet<Color?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: paddingHorizontalExtraLarge
                .add(const EdgeInsets.symmetric(vertical: 80)),
            alignment: Alignment.center,
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: _ModalColor(
                initValue: _txtInputText.text.isNotEmpty
                    ? ConvertData.fromHex(_txtInputText.text, Colors.black)
                    : null,
                onChanged: (Color? color) {
                  Navigator.pop(context, color);
                },
              ),
            ),
          ),
        );
      },
    );

    String? stringColor = value != null
        ? '#${value.value.toRadixString(16).substring(2, 8)}'
        : null;
    if (stringColor != null && stringColor != _txtInputText.text) {
      _txtInputText.text = stringColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    String label = get(widget.field, ['label'], '');
    String placeholder = get(widget.field, ['placeholder'], '');
    bool requiredInput =
        ConvertData.toBoolValue(widget.field["required"]) ?? false;
    List validate = getList(widget.field["validate"]);

    String? labelText = requiredInput ? '$label *' : label;

    return TextFormField(
      controller: _txtInputText,
      readOnly: true,
      validator: (String? value) => validateField(
          translate: translate,
          validate: validate,
          requiredInput: requiredInput,
          value: value),
      decoration: widget.borderFields == true
          ? InputDecoration(
              labelText: labelText,
              hintText: placeholder,
              contentPadding:
                  const EdgeInsetsDirectional.only(start: itemPaddingMedium),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: theme.inputDecorationTheme.border?.borderSide ??
                    const BorderSide(),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    theme.inputDecorationTheme.enabledBorder?.borderSide ??
                        const BorderSide(),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    theme.inputDecorationTheme.focusedBorder?.borderSide ??
                        const BorderSide(),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    theme.inputDecorationTheme.errorBorder?.borderSide ??
                        const BorderSide(),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    theme.inputDecorationTheme.focusedErrorBorder?.borderSide ??
                        const BorderSide(),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    theme.inputDecorationTheme.disabledBorder?.borderSide ??
                        const BorderSide(),
              ),
              suffixIcon: IconButton(
                iconSize: 16,
                icon: const Icon(Icons.close),
                onPressed: clearValue,
              ),
            )
          : InputDecoration(
              labelText: labelText,
              hintText: placeholder,
              suffixIcon: IconButton(
                iconSize: 16,
                icon: const Icon(Icons.close),
                onPressed: clearValue,
              ),
            ),
      onTap: () => showColor(context, theme),
    );
  }
}

class _ModalColor extends StatefulWidget {
  final Color? initValue;
  final Function(Color?) onChanged;

  const _ModalColor({
    Key? key,
    this.initValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_ModalColor> createState() => _ModalColorState();
}

class _ModalColorState extends State<_ModalColor> {
  late Color pickerColor = const Color(0xff443a49);

  @override
  void initState() {
    pickerColor = widget.initValue ?? Colors.black;
    super.initState();
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: theme.canvasColor, borderRadius: borderRadiusExtraLarge),
        padding: paddingHorizontalLarge.add(paddingVerticalExtraLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              enableAlpha: false,
              hexInputBar: true,
              displayThumbColor: true,
              labelTypes: const [],
            ),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onChanged(pickerColor),
                child: Text(AppLocalizations.of(context)!
                    .translate('address_modal_date_ok')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
