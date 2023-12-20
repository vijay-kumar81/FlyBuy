import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/store/store.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/flybuy_post_item.dart';
import 'package:provider/provider.dart';

int _perPage = 4;

class PostRelated extends StatefulWidget {
  final Post? post;
  final String queryBy;

  const PostRelated({
    Key? key,
    this.post,
    this.queryBy = 'tag',
  }) : super(key: key);

  @override
  State<PostRelated> createState() => _PostRelatedState();
}

class _PostRelatedState extends State<PostRelated> {
  late PostStore _postStore;
  late SettingStore _settingStore;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settingStore = Provider.of<SettingStore>(context);

    Post? post = widget.post;
    List<Post> exclude = post is Post ? [post] : [];

    List<Post> include = [];
    List<PostTag> tags = [];
    List<PostCategory> categories = [];

    switch (widget.queryBy) {
      case "tag":
        tags.addAll(post?.postTags ?? []);
        break;
      case "category":
        categories.addAll(post?.postCategories ?? []);
        break;
      case "custom-field":
        include
            .addAll(post?.relatedIds?.map((e) => Post(id: e)).toList() ?? []);
        break;
    }

    _postStore = PostStore(
      _settingStore.requestHelper,
      lang: _settingStore.locale,
      perPage: _perPage,
      exclude: exclude,
      include: include,
      tags: tags,
      categories: categories,
    );

    _postStore.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TranslateType translate = AppLocalizations.of(context)!.translate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate('post_related'), style: theme.textTheme.titleLarge),
        buildView(translate),
      ],
    );
  }

  Widget buildView(TranslateType translate) {
    return Observer(
      builder: (_) {
        List<Post> data = _postStore.posts;
        return Column(
          children: [
            if (data.isNotEmpty)
              ...List.generate(data.length, (index) {
                return Column(
                  children: [
                    FlybuyPostItem(
                      post: data[index],
                      template: Strings.postItemHorizontal,
                      paddingContent: paddingVerticalLarge,
                    ),
                    const Divider(height: 1, thickness: 1),
                  ],
                );
              }),
            if (_postStore.loading)
              ...List.generate(_perPage, (index) {
                return const Column(
                  children: [
                    FlybuyPostItem(
                      template: Strings.postItemHorizontal,
                      paddingContent: paddingVerticalLarge,
                    ),
                    Divider(height: 1, thickness: 1),
                  ],
                );
              }),
            if (_postStore.canLoadMore)
              Padding(
                padding: const EdgeInsets.only(top: itemPaddingSmall),
                child: ElevatedButton(
                  onPressed: () => _postStore.getPosts(),
                  child: Text(translate('load_more')),
                ),
              ),
          ],
        );
      },
    );
  }
}
