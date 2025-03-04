import 'dart:async';
import 'dart:convert';

// import 'package:flybuy/service/constants/endpoints.dart';
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  // localization variables
  final Locale locale;
  late Map<String, String> localizedStrings;
  static RegExp exp = RegExp(r"\{(.*?)\}");

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // constructor
  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<String> _loadAssets() async {
    try {
      String languageCode = locale.languageCode;
      if (locale.countryCode != null) {
        languageCode =
            '${locale.languageCode}-${locale.countryCode!.toLowerCase()}';
      }
      return await rootBundle.loadString('assets/lang/$languageCode.json');
    } catch (_) {
      return await rootBundle.loadString('assets/lang/en.json');
    }
  }

  // This is a helper method that will load local specific strings from file
  // present in lang folder
  Future<bool> load() async {
    String jsonString = await _loadAssets();
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // final dio = Dio();
    // dio..options.baseUrl = '${Endpoints.restUrl}';
    // Response response = await dio.get('/', queryParameters: {'app-builder-lang': '${locale.languageCode}.json'});
    //
    // Map<String, dynamic> jsonMap = response.data;

    localizedStrings = jsonMap.map((key, value) {
      return MapEntry(
          key, value.toString().replaceAll(r"\'", "'").replaceAll(r"\t", " "));
    });

    return true;
  }

  static String replace(txt, Map<String, String?> options) =>
      txt.replaceAllMapped(exp, (Match m) {
        if (options.isEmpty) return m.group(0) ?? '';
        if (m.group(0) == null || m.group(1) == null) return '';
        return options[m.group(1)] ?? m.group(0) ?? '';
      });

  // This method will be called from every widget which needs a localized text
  String translate(String key, [Map<String, String?>? options]) {
    String? txt = localizedStrings[key];
    if (txt == null || txt.isEmpty) {
      return key;
    }

    if (options == null || options.isEmpty) {
      return txt;
    }

    return replace(txt, options);
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // ignore: non_constant_identifier_names
  final String TAG = "AppLocalizations";

  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      kMaterialSupportedLanguages.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
