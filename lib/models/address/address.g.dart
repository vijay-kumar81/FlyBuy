// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
      country: json['country'] as String?,
      billing: AddressData._toMapString(json['billing']),
      shipping: AddressData._toMapString(json['shipping']),
      additional: AddressData._toMapString(json['additional']),
      format: AddressData._toMapString(json['address_format']),
      billingStates:
          AddressData._toMapCountryData(json['billing_countries_states']),
      billingCountries: AddressData._toCountryData(json['billing_countries']),
      shippingStates:
          AddressData._toMapCountryData(json['shipping_country_states']),
      shippingCountries: AddressData._toCountryData(json['shipping_countries']),
      shippingSelected: json['shipping_countries_selected'] as String?,
    );

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'billing': instance.billing,
      'shipping': instance.shipping,
      'additional': instance.additional,
      'address_format': instance.format,
      'billing_countries_states': instance.billingStates,
      'billing_countries': instance.billingCountries,
      'shipping_countries': instance.shippingCountries,
      'shipping_country_states': instance.shippingStates,
      'shipping_countries_selected': instance.shippingSelected,
    };
