import 'package:flybuy/constants/styles.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/address/address.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/screens/profile/widgets/address_field_form3.dart';
import 'package:flybuy/screens/profile/widgets/fields/loading_field_address.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flybuy/store/store.dart';
import 'package:provider/provider.dart';

import 'checkout_address_book.dart';

class CheckoutViewBillingAddress extends StatefulWidget {
  final CartStore cartStore;

  const CheckoutViewBillingAddress({
    Key? key,
    required this.cartStore,
  }) : super(key: key);

  @override
  State<CheckoutViewBillingAddress> createState() =>
      _CheckoutViewBillingAddressState();
}

class _CheckoutViewBillingAddressState extends State<CheckoutViewBillingAddress>
    with Utility {
  late SettingStore _settingStore;
  late AuthStore _authStore;
  late AddressDataStore _addressDataStore;
  AddressBookStore? _addressBookStore;
  String _name = 'billing';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingStore = Provider.of<SettingStore>(context);
    _authStore = Provider.of<AuthStore>(context);

    WidgetConfig? widgetConfig =
        _settingStore.data?.screens?['profile']?.widgets?['profilePage']!;
    Map<String, dynamic>? fields = widgetConfig?.fields;

    bool enableAddressBook = get(fields, ['enableAddressBook'], false);

    if (enableAddressBook && _authStore.isLogin) {
      _addressBookStore = AddressBookStore(_settingStore.requestHelper)
        ..getAddressBook();
    }
    Map<String, dynamic> billing = {
      ...?widget.cartStore.cartData?.billingAddress,
      ...widget.cartStore.checkoutStore.billingAddress,
    };
    String country = get(billing, ['country'], '');
    _addressDataStore = AddressDataStore(_settingStore.requestHelper)
      ..getAddressData(queryParameters: {
        'country': country,
        'lang': _settingStore.locale,
      });
  }

  void onChanged(Map<String, dynamic> value, [String? name]) async {
    if (name != null) {
      setState(() {
        _name = name;
      });
    }

    await widget.cartStore.checkoutStore.changeAddress(
      billing: value,
      shipping:
          widget.cartStore.checkoutStore.shipToDifferentAddress ? null : value,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;
    return Observer(
      builder: (_) {
        Map<String, dynamic> billing = {
          ...?widget.cartStore.cartData?.billingAddress,
          ...widget.cartStore.checkoutStore.billingAddress,
        };

        Map<String, dynamic>? addressFields =
            _addressDataStore.address?.billing;
        bool loading = _addressDataStore.loading != false &&
            addressFields?.isNotEmpty != true;

        if (billing["country"] is String &&
            billing["country"] != "" &&
            !_addressDataStore.loading &&
            _addressDataStore.address?.country != null &&
            billing["country"] != _addressDataStore.address?.country) {
          /// Update only if this widget initialized.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _addressDataStore.getAddressData(queryParameters: {
              'country': billing["country"],
              'lang': _settingStore.locale,
            });
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate('checkout_billing_detail'),
                style: theme.textTheme.titleLarge),
            Padding(
              padding: paddingVerticalMedium,
              child: Column(
                children: [
                  if (_addressBookStore != null &&
                      _addressBookStore?.addressBook?.billingEnable ==
                          true) ...[
                    if (_addressBookStore!.loading != true)
                      CheckoutAddressBook(
                        valueSelected: _name,
                        data: _addressBookStore?.addressBook ?? AddressBook(),
                        onChanged: onChanged,
                      )
                    else
                      const LoadingFieldAddressItem(width: double.infinity),
                    const SizedBox(height: 15),
                  ],
                  loading
                      ? const LoadingFieldAddress(count: 10)
                      : addressFields?.isNotEmpty == true
                          ? AddressFieldForm3(
                              key: Key(_name),
                              keyForm: _name,
                              data: billing,
                              addressData:
                                  _addressDataStore.address ?? AddressData(),
                              onChanged: onChanged,
                              onGetAddressData: (String country) {},
                              formType: FieldFormType.checkoutBilling,
                            )
                          : Center(
                              child: Text(translate('address_empty_shipping'))),
                ],
              ),
            )
          ],
        );
      },
    );
  }
}
