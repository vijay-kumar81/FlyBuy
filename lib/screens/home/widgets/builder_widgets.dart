import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/setting/setting.dart';
import 'package:flybuy/store/setting/setting_store.dart';
import 'package:flybuy/utils/convert_data.dart';
import 'package:flybuy/widgets/builder/widgets.dart';
import 'package:provider/provider.dart';

/// Handle build widget from config
class BuilderWidgets extends StatefulWidget {
  const BuilderWidgets({Key? key, this.data}) : super(key: key);

  final Data? data;

  @override
  State<BuilderWidgets> createState() => _BuilderWidgetsState();
}

class _BuilderWidgetsState extends State<BuilderWidgets>
    with Widgets, ScrollMixin, AppBarMixin, LoadingMixin, Utility {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SettingStore _settingStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingStore = Provider.of<SettingStore>(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data == null) return Container();

    // Widgets config
    final Data data = widget.data!;

    List<String> widgetIds = data.widgetIds ?? [];
    Map<String, WidgetConfig> widgets = data.widgets ?? {};

    // Stack
    bool enableStackLayout = get(data.configs, ['enableStackLayout'], false);
    bool? enableAppbar = get(data.configs, ['enableAppbar'], true);
    double? minHeightStack =
        ConvertData.stringToDouble(get(data.configs, ['minHeightStack'], 0.5));
    double? maxHeightStack =
        ConvertData.stringToDouble(get(data.configs, ['maxHeightStack'], 1));
    double? initialChildSize = ConvertData.stringToDouble(
        get(data.configs, ['initialChildSize'], 0.5));

    // Appbar
    String? appbarType = get(data.configs, ['appBarType'], 'floating');
    bool extendBodyBehindAppBar =
        get(data.configs, ['extendBodyBehindAppBar'], true);
    Widget appbar = buildAppBar(
      context,
      data: data,
      type: appbarType,
      isScrolledToTop: isScrolledToTop,
      themeModeKey: _settingStore.themeModeKey,
      languageKey: _settingStore.languageKey,
    );

    bool isAppbar = appbarType == Strings.appbarFixed;

    return Scaffold(
      key: _scaffoldKey,
      primary: true,
      appBar: isAppbar && enableAppbar! ? appbar as PreferredSizeWidget? : null,
      extendBody: true,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      body: enableStackLayout && widgetIds.isNotEmpty
          ? buildStack(
              widgetIds: widgetIds,
              widgets: widgets,
              minHeightStack: minHeightStack,
              maxHeightStack: maxHeightStack,
              initialChildSize: initialChildSize,
            )
          : buildScroll(
              scroll: controller,
              widgetIds: widgetIds,
            ),
    );
  }

  Widget buildStack({
    required List<String> widgetIds,
    required Map<String, WidgetConfig> widgets,
    required double minHeightStack,
    required double maxHeightStack,
    required double initialChildSize,
  }) {
    List<String> newWidgetIds = List<String>.of(widgetIds);
    String id = newWidgetIds.removeAt(0);

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        if ((1 - notification.extent) * MediaQuery.of(context).size.height <
            appbarEmptySpace) {
          if (isScrolledToTop) {
            setScrollState(false);
          }
        } else {
          if (!isScrolledToTop) {
            setScrollState(true);
          }
        }

        return true;
      },
      child: Stack(
        children: [
          buildWidget(widgets[id]),
          DraggableScrollableActuator(
            child: DraggableScrollableSheet(
              initialChildSize: initialChildSize,
              minChildSize: minHeightStack,
              maxChildSize: maxHeightStack,
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                return buildScroll(
                    scroll: scrollController,
                    widgetIds: newWidgetIds,
                    isRefresh: false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildScroll(
      {ScrollController? scroll,
      required List<String> widgetIds,
      bool isRefresh = true}) {
    final Data data = widget.data!;
    Map<String, WidgetConfig> widgets = data.widgets ?? {};

    // Appbar
    String? appbarType = get(data.configs, ['appBarType'], 'floating');
    bool? enableAppbar = get(data.configs, ['enableAppbar'], true);
    Widget appbar = buildAppBar(
      context,
      data: data,
      type: appbarType,
      isScrolledToTop: isScrolledToTop,
      themeModeKey: _settingStore.themeModeKey,
      languageKey: _settingStore.languageKey,
    );

    bool isAppbar = appbarType == Strings.appbarFixed;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      controller: scroll,
      slivers: <Widget>[
        if (!isAppbar && enableAppbar!) appbar,
        if (isRefresh)
          CupertinoSliverRefreshControl(
            onRefresh: _settingStore.getSetting,
            builder: (
              BuildContext context,
              RefreshIndicatorMode refreshState,
              double pulledExtent,
              double refreshTriggerPullDistance,
              double refreshIndicatorExtent,
            ) =>
                Padding(
              padding: const EdgeInsets.only(bottom: itemPaddingLarge),
              child: buildAppRefreshIndicator(
                context,
                refreshState,
                pulledExtent,
                refreshTriggerPullDistance,
                refreshTriggerPullDistance,
              ),
            ),
          ),
        buildWidgets(context, widgetIds: widgetIds, widgets: widgets)
      ],
    );
  }
}
