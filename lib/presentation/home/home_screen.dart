import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/constants.dart';
import '../../data/models/note_query.dart';
import '../../logic/notes_provider.dart';
import '../drawer/app_drawer.dart';
import 'widgets/home_bottom_bar.dart';
import 'widgets/home_context_bar.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/notes_slivers.dart';
import 'widgets/selection_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Back first clears a selection, then returns from archive/trash/tag/
    // filter to the main notes, and only then leaves the app.
    return Selector<NotesProvider, bool>(
      selector: (_, NotesProvider p) => p.query.isDefault && !p.isSelecting,
      builder: (BuildContext context, bool canPop, Widget? scaffold) =>
          PopScope(
            canPop: canPop,
            onPopInvokedWithResult: (bool didPop, Object? result) {
              if (didPop) return;
              final NotesProvider notes = context.read<NotesProvider>();
              notes.isSelecting
                  ? notes.clearSelection()
                  : notes.setQuery(const NoteQuery());
            },
            child: scaffold!,
          ),
      child: const Scaffold(
        drawer: AppDrawer(),
        body: _HomeBody(),
        bottomNavigationBar: HomeBottomBar(),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            toolbarHeight: AppSizes.searchBarHeight + AppSpacing.lg,
            titleSpacing: 0,
            title: _HeaderSwitcher(),
          ),
          SliverToBoxAdapter(child: HomeContextBar()),
          NotesSlivers(),
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

/// Cross-fades between the search bar and the selection bar. Both stay
/// mounted (AnimatedCrossFade), so the search text survives selection mode.
class _HeaderSwitcher extends StatelessWidget {
  const _HeaderSwitcher();

  @override
  Widget build(BuildContext context) {
    return Selector<NotesProvider, bool>(
      selector: (_, NotesProvider p) => p.isSelecting,
      builder: (BuildContext context, bool isSelecting, _) => AnimatedCrossFade(
        duration: AppDurations.medium,
        sizeCurve: Curves.easeOutCubic,
        crossFadeState: isSelecting
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const HomeSearchBar(),
        secondChild: const SelectionBar(),
      ),
    );
  }
}
