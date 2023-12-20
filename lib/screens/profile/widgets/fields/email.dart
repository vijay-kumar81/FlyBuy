import 'package:flybuy/constants/styles.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flutter/material.dart';

import 'get_field.dart';
import 'validate_field.dart';

class AddressFieldEmail extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final bool borderFields;
  final Map<String, dynamic> field;

  const AddressFieldEmail({
    Key? key,
    this.value,
    this.borderFields = false,
    required this.onChanged,
    required this.field,
  }) : super(key: key);

  @override
  State<AddressFieldEmail> createState() => _AddressFieldEmail();
}

class _AddressFieldEmail extends State<AddressFieldEmail> with Utility {
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
  void didUpdateWidget(covariant AddressFieldEmail oldWidget) {
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
            )
          : InputDecoration(
              labelText: labelText,
              hintText: placeholder,
            ),
      keyboardType: TextInputType.emailAddress,
    );
  }
}
