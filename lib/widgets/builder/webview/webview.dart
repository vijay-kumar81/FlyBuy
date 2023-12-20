import 'dart:async';

import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/service/constants/endpoints.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/models/models.dart';
import 'package:provider/provider.dart';
import 'package:flybuy/webview_flutter.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/widgets/flybuy_webview.dart';

class WebviewWidget extends StatefulWidget {
  final WidgetConfig? widgetConfig;

  const WebviewWidget({
    Key? key,
    required this.widgetConfig,
  }) : super(key: key);

  @override
  State<WebviewWidget> createState() => _WebviewWidgetState();
}

class _WebviewWidgetState extends State<WebviewWidget>
    with LoadingMixin, NavigationMixin, ContainerMixin {
  SettingStore? _settingStore;
  late AuthStore _authStore;

  @override
  void didChangeDependencies() {
    _settingStore = Provider.of<SettingStore>(context);
    _authStore = Provider.of<AuthStore>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    double heightWindow = MediaQuery.of(context).size.height;

    String themeModeKey = _settingStore?.themeModeKey ?? 'value';
    String languageKey = _settingStore?.languageKey ?? "text";

    bool isLogin = _authStore.isLogin;

    // Styles
    Map<String, dynamic> styles = widget.widgetConfig?.styles ?? {};
    Map<String, dynamic>? margin = get(styles, ['margin'], {});
    Map<String, dynamic>? padding = get(styles, ['padding'], {});
    Color background = ConvertData.fromRGBA(
        get(styles, ['background', themeModeKey], {}), Colors.transparent);

    // general config
    Map<String, dynamic> fields = widget.widgetConfig?.fields ?? {};
    double? height =
        ConvertData.stringToDouble(get(fields, ['height'], 200), 200);
    String url = ConvertData.textFromConfigs(fields['url'], languageKey);
    bool syncAuthWebToApp = get(fields, ['syncAuthWebToApp'], false);
    List<dynamic> items = get(fields, ['items'], []);
    bool syncAuth = get(fields, ['syncAuth'], false);

    // Check validate URL
    bool validURL = Uri.parse(url).isAbsolute;

    String uri = url;
    Map<String, String> headers = {};

    if (isLogin && syncAuth) {
      headers = {"Authorization": "Bearer ${_authStore.token!}"};

      Map<String, String?> queryParams = {
        'app-builder-decode': 'true',
        'redirect': url,
      };

      if (isLogin) {
        queryParams.putIfAbsent('app-builder-decode', () => 'true');
      }

      if (_settingStore!.isCurrencyChanged) {
        queryParams.putIfAbsent('currency', () => _settingStore!.currency);
      }

      if (_settingStore!.languageKey != "text") {
        queryParams.putIfAbsent(
            isLogin ? '_lang' : 'lang', () => _settingStore!.locale);
      }

      uri =
          "${Endpoints.restUrl}${Endpoints.loginToken}?${Uri(queryParameters: queryParams).query}";
    }

    return Container(
      decoration: decorationColorImage(color: background),
      margin: ConvertData.space(margin, 'margin'),
      padding: ConvertData.space(padding, 'padding'),
      height: url.isNotEmpty
          ? height == 0
              ? heightWindow
              : height
          : null,
      child: validURL
          ? FlybuyWebView(
              /// CookieManager
              uri: Uri.parse(uri),
              headers: headers,
              userAgent: !syncAuthWebToApp
                  ? null
                  : 'Mozilla/5.0 (Linux; Android 11; LM-V500N Build/RKQ1.210420.001; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/102.0.5005.125 Mobile Safari/537.36 Flybuy/3.0.0',
              onNavigationRequest: (NavigationRequest request) {
                Uri uri = Uri.parse(request.url);
                String? token = uri.queryParameters['flybuy-token'];
                if (token != null) {
                  _handleLogin(token);
                }
                return _handleNavigate(request.url, items);
              },
              loading: buildLoading(context, isLoading: true),
            )
          : const SizedBox(),
    );
  }

  /// Handle redirect URL
  NavigationDecision _handleNavigate(String url, List<dynamic> items) {
    Map<String, dynamic>? action;

    for (dynamic item in items) {
      Map<String, dynamic>? data = item['data'];
      if (data != null &&
          data['value'] != null &&
          data['value'] != '' &&
          data['condition'] != 'no_condition') {
        if ((data['condition'] == 'url_start' &&
                url.startsWith(data['value'])) ||
            (data['condition'] == 'url_end' && url.endsWith(data['value'])) ||
            (data['condition'] == 'equal_to' && url == data['value']) ||
            (data['condition'] == 'url_contain' &&
                url.contains(data['value']))) {
          action = data['action'];
          break;
        }
      }
    }

    if (action != null) {
      navigate(context, action);
    }

    return NavigationDecision.navigate;
  }

  /// Handle login with param Token
  Future<void> _handleLogin(String token) async {
    try {
      await _authStore.loginByToken(token);
    } catch (e) {
      avoidPrint(e);
    }
  }
}
