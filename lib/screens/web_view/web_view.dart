import 'package:flybuy/mixins/loading_mixin.dart';
import 'package:flybuy/utils/debug.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/webview_flutter.dart';
import 'package:flybuy/widgets/flybuy_webview.dart';

class WebViewScreen extends StatefulWidget {
  static const routeName = '/web_view';

  final Map? args;

  const WebViewScreen({Key? key, this.args}) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with LoadingMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.args!['name'] ?? ''),
        ),
        body: widget.args != null && widget.args!['url'] == null
            ? Container()
            : FlybuyWebView(
                uri: Uri.parse(widget.args!['url']),
                onNavigationRequest: (NavigationRequest request) {
                  avoidPrint('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                loading: buildLoading(context, isLoading: true),
              ));
  }
}
