import 'package:app/constants/colors.dart';
import 'package:app/constants/dimensions.dart';
import 'package:app/mixins/stream_subscriber.dart';
import 'package:app/providers/playlist_provider.dart';
import 'package:app/router.dart';
import 'package:app/ui/widgets/bottom_space.dart';
import 'package:app/ui/widgets/playlist_row.dart';
import 'package:app/ui/widgets/typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistsScreen extends StatefulWidget {
  static const routeName = '/playlists';
  final AppRouter router;

  const PlaylistsScreen({
    Key? key,
    this.router = const AppRouter(),
  }) : super(key: key);

  @override
  _PlaylistsScreenState createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
    with StreamSubscriber {
  late PlaylistProvider playlistProvider;

  @override
  void initState() {
    super.initState();

    playlistProvider = context.read();

    // Try to populate all playlists even before user interactions to update
    // the playlist's thumbnail and song count.
    playlistProvider.populateAllPlaylists();
  }

  @override
  void dispose() {
    unsubscribeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CupertinoTheme(
        data: CupertinoThemeData(primaryColor: Colors.white),
        child: Consumer<PlaylistProvider>(
          builder: (context, provider, navigationBar) {
            if (provider.playlists.length == 0) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.horizontalPadding,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.router.showCreatePlaylistSheet(context),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          CupertinoIcons.exclamationmark_square,
                          size: 56.0,
                          color: AppColors.red,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          'No playlists.',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        const SizedBox(height: 16.0),
                        const Text('Tap to create a playlist.'),
                      ],
                    ),
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: <Widget>[
                navigationBar!,
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, int index) => PlaylistRow(
                      playlist: provider.playlists[index],
                    ),
                    childCount: provider.playlists.length,
                  ),
                ),
                const SliverToBoxAdapter(child: const BottomSpace()),
              ],
            );
          },
          child: CupertinoSliverNavigationBar(
            backgroundColor: Colors.black,
            largeTitle: const LargeTitle(text: 'Playlists'),
            trailing: IconButton(
              onPressed: () => widget.router.showCreatePlaylistSheet(context),
              icon: const Icon(CupertinoIcons.add_circled),
            ),
          ),
        ),
      ),
    );
  }
}
