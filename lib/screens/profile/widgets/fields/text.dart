import 'package:flybuy/constants/styles.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flutter/material.dart';

import 'get_field.dart';
import 'validate_field.dart';

class AddressFieldText extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final bool borderFields;
  final Map<String, dynamic> field;
  final Widget? suffixIcon;

  const AddressFieldText({
    Key? key,
    this.value,
    this.borderFields = false,
    required this.onChanged,
    required this.field,
    this.suffixIcon,
  }) : super(key: key);

  @override
  State<AddressFieldText> createState() => _AddressFieldText();
}

class _AddressFieldText extends State<AddressFieldText> with Utility {
  final _txtInputText = TextEditingController();

  @override
  void initState() {
    String defaultValue = get(widget.field, ['default'], '');
    _txtInputText.text = widget.value ?? defaultValue;
    _txtInputText.addListener(_onChanged);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AddressFieldText oldWidget) {
    /// Update only if this widget initialized.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (oldWidget.value != widget.value &&
          widget.value != _txtInputText.text) {
        String defaultValue = get(widget.field, ['default'], '');
        _txtInputText.text = widget.value ?? defaultValue;
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _txtInputText.dispose();
    super.dispose();
  }

  /// Save data in current state
  ///
  _onChanged() {
    if (_txtInputText.text != widget.value) {
      widget.onChanged(_txtInputText.text);
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
              suffixIcon: widget.suffixIcon,
            )
          : InputDecoration(
              labelText: labelText,
              hintText: placeholder,
              suffixIcon: widget.suffixIcon,
            ),
    );
  }
}
