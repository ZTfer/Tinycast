import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_by_rss/rss_input_material.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_search_result.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/podcast_search_provider.dart';

class SubscribeByRss extends ConsumerStatefulWidget {
  const SubscribeByRss({super.key});

  @override
  ConsumerState<SubscribeByRss> createState() => _SubscribeByRssState();
}

class _SubscribeByRssState extends ConsumerState<SubscribeByRss> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '通过RSS订阅',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 12.0),
        Material(
          color: Colors.transparent,
          child: Localizations(
            locale: const Locale('en', 'US'),
            delegates: const <LocalizationsDelegate<dynamic>>[
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            child: RssInputMaterial(
              isSearchMode: true,
              onSearch: (url) {
                ref.read(podcastSearchProvider.notifier).searchPodcast(url);
              },
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Expanded(child: const SubscribeSearchResult()),
      ],
    );
  }
}
