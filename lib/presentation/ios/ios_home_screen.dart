import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_durations.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/note.dart';
import '../../data/models/note_query.dart';
import '../../data/models/notes_overview.dart';
import '../../logic/notes_provider.dart';
import '../../logic/editor_launch_action.dart';
import '../editor/note_editor_screen.dart';
import 'widgets/ios_note_card.dart';
import 'widgets/ios_settings_sheet.dart';

class IosHomeScreen extends StatelessWidget {
  const IosHomeScreen({super.key});

  static const double _contentWidth = 900;

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(
      middle: const Text(AppStrings.appShortName),
      leading: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => IosSettingsSheet.show(context),
        child: const Icon(CupertinoIcons.line_horizontal_3),
      ),
    ),
    child: SafeArea(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              const _SearchField(),
              const _Filters(),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _contentWidth),
                    child: const _NotesList(),
                  ),
                ),
              ),
              const _BottomBar(),
            ],
          ),
          const Positioned.fill(child: _AddButton()),
        ],
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: TapRegion(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoSearchTextField(
        placeholder: AppStrings.searchHint,
        onChanged: context.read<NotesProvider>().setSearch,
      ),
    ),
  );
}

class _Filters extends StatelessWidget {
  const _Filters();

  @override
  Widget build(BuildContext context) => Selector<NotesProvider, NoteQuery>(
    selector: (_, NotesProvider notes) => notes.query,
    builder: (BuildContext context, NoteQuery query, _) {
      if (query.section != NoteSection.notes) return const SizedBox.shrink();
      return SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: <Widget>[
            for (final (NoteCategory category, String title)
                in const <(NoteCategory, String)>[
                  (NoteCategory.all, AppStrings.filterAll),
                  (NoteCategory.audio, AppStrings.filterAudio),
                  (NoteCategory.checklists, AppStrings.filterChecklists),
                  (NoteCategory.attachments, AppStrings.filterAttachments),
                  (NoteCategory.drawings, AppStrings.filterDrawings),
                ])
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  borderRadius: BorderRadius.circular(18),
                  color: query.category == category
                      ? CupertinoTheme.of(context).primaryColor
                      : CupertinoColors.tertiarySystemFill.resolveFrom(context),
                  onPressed: () =>
                      context.read<NotesProvider>().setCategory(category),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: query.category == category
                          ? CupertinoColors.white
                          : CupertinoColors.label.resolveFrom(context),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _NotesList extends StatelessWidget {
  const _NotesList();

  @override
  Widget build(BuildContext context) => Selector<NotesProvider, NotesView>(
    selector: (_, NotesProvider notes) => notes.view,
    builder: (BuildContext context, NotesView view, _) {
      if (view.isEmpty) {
        final NotesProvider notes = context.read<NotesProvider>();
        final String message = switch (notes.query.section) {
          NoteSection.archive => AppStrings.emptyArchive,
          NoteSection.trash => AppStrings.emptyTrash,
          NoteSection.notes when notes.isSearching || !notes.query.isDefault =>
            AppStrings.emptySearch,
          NoteSection.notes => AppStrings.emptyNotes,
        };
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(message, textAlign: TextAlign.center),
          ),
        );
      }
      return CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: <Widget>[
          if (view.pinned.isNotEmpty) ...<Widget>[
            const SliverToBoxAdapter(child: _SectionLabel(AppStrings.pinned)),
            _NoteRows(view.pinned),
          ],
          if (view.others.isNotEmpty) ...<Widget>[
            if (view.pinned.isNotEmpty)
              const SliverToBoxAdapter(child: _SectionLabel(AppStrings.others)),
            _NoteRows(view.others),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      );
    },
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13,
        color: CupertinoColors.secondaryLabel.resolveFrom(context),
      ),
    ),
  );
}

class _NoteRows extends StatelessWidget {
  const _NoteRows(this.notes);
  final List<Note> notes;

  @override
  Widget build(BuildContext context) => SliverList.builder(
    itemCount: notes.length,
    itemBuilder: (BuildContext context, int index) =>
        IosNoteCard(key: ValueKey<String>(notes[index].id), note: notes[index]),
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) =>
      Selector<NotesProvider, (NoteSection, int)>(
        selector: (_, NotesProvider notes) =>
            (notes.query.section, notes.view.length),
        builder: (BuildContext context, (NoteSection, int) state, _) =>
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              height: 54,
              child: Row(
                children: <Widget>[
                  Text(
                    '${state.$2} ${AppStrings.notesCountSuffix}',
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (state.$1 == NoteSection.notes)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          NoteEditorScreen.open(context, checklist: true),
                      child: const Icon(CupertinoIcons.checkmark_square),
                    ),
                  if (state.$1 == NoteSection.notes)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => NoteEditorScreen.open(
                        context,
                        action: EditorLaunchAction.audio,
                      ),
                      child: const Icon(CupertinoIcons.mic),
                    ),
                  if (state.$1 == NoteSection.notes)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => NoteEditorScreen.open(
                        context,
                        action: EditorLaunchAction.image,
                      ),
                      child: const Icon(CupertinoIcons.photo),
                    ),
                ],
              ),
            ),
      );
}

/// Floating "new note" button above the bottom bar, like Google Keep.
///
/// With a category filter selected it creates that kind of note directly;
/// under "All" it expands into a menu of note types.
class _AddButton extends StatefulWidget {
  const _AddButton();

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.medium,
  );
  late final Animation<double> _expand = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
    reverseCurve: Curves.easeOutQuad,
  );

  bool get _open => _controller.isForwardOrCompleted;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The AnimatedBuilders listen to the controller, so no rebuild is needed.
  void _toggle() {
    _open ? _controller.reverse() : _controller.forward();
  }

  void _create({
    bool checklist = false,
    EditorLaunchAction action = EditorLaunchAction.none,
  }) {
    if (_open) _toggle();
    NoteEditorScreen.open(context, checklist: checklist, action: action);
  }

  void _onPressed(NoteCategory category) => switch (category) {
    NoteCategory.all => _toggle(),
    NoteCategory.audio => _create(action: EditorLaunchAction.audio),
    NoteCategory.checklists => _create(checklist: true),
    NoteCategory.attachments => _create(action: EditorLaunchAction.image),
    NoteCategory.drawings => _create(action: EditorLaunchAction.drawing),
  };

  @override
  Widget build(BuildContext context) => Selector<NotesProvider, NoteQuery>(
    selector: (_, NotesProvider notes) => notes.query,
    builder: (BuildContext context, NoteQuery query, _) {
      if (query.section != NoteSection.notes) return const SizedBox.shrink();
      final List<(IconData, String, VoidCallback)> actions =
          <(IconData, String, VoidCallback)>[
            (
              CupertinoIcons.photo,
              AppStrings.newImage,
              () => _create(action: EditorLaunchAction.image),
            ),
            (
              CupertinoIcons.scribble,
              AppStrings.newDrawing,
              () => _create(action: EditorLaunchAction.drawing),
            ),
            (
              CupertinoIcons.mic,
              AppStrings.newVoice,
              () => _create(action: EditorLaunchAction.audio),
            ),
            (
              CupertinoIcons.checkmark_square,
              AppStrings.newChecklist,
              () => _create(checklist: true),
            ),
            (CupertinoIcons.textformat, AppStrings.newNote, _create),
          ];
      return Stack(
        children: <Widget>[
          // Dims the screen and closes the menu on an outside tap.
          AnimatedBuilder(
            animation: _expand,
            builder: (BuildContext context, _) => _expand.value == 0
                ? const SizedBox.shrink()
                : Positioned.fill(
                    child: GestureDetector(
                      onTap: _toggle,
                      child: ColoredBox(
                        color: CupertinoColors.black.withValues(
                          alpha: 0.3 * _expand.value,
                        ),
                      ),
                    ),
                  ),
          ),
          PositionedDirectional(
            end: 16,
            bottom: 54 + 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final (int i, (IconData, String, VoidCallback) action)
                    in actions.indexed)
                  _ExpandingAction(
                    // Staggered so the item nearest the button appears first.
                    progress: CurvedAnimation(
                      parent: _expand,
                      curve: Interval((actions.length - 1 - i) * 0.1, 1),
                    ),
                    icon: action.$1,
                    label: action.$2,
                    onPressed: action.$3,
                  ),
                _MainButton(
                  expand: _expand,
                  onPressed: () => _onPressed(query.category),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class _MainButton extends StatelessWidget {
  const _MainButton({required this.expand, required this.onPressed});

  final Animation<double> expand;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x40000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: const Size.square(60),
      color: CupertinoTheme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(18),
      onPressed: onPressed,
      // Turns the "+" into an "×" while the menu is open.
      child: RotationTransition(
        turns: Tween<double>(begin: 0, end: 0.125).animate(expand),
        child: const Icon(
          CupertinoIcons.add,
          size: 30,
          color: CupertinoColors.white,
        ),
      ),
    ),
  );
}

class _ExpandingAction extends StatelessWidget {
  const _ExpandingAction({
    required this.progress,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Animation<double> progress;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: progress,
    builder: (BuildContext context, Widget? child) => progress.value == 0
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FadeTransition(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - progress.value)),
                child: child,
              ),
            ),
          ),
    child: CupertinoButton(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 12, 0),
      minimumSize: const Size(0, 48),
      color: CupertinoColors.secondarySystemGroupedBackground.resolveFrom(
        context,
      ),
      borderRadius: BorderRadius.circular(24),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 22, color: CupertinoTheme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
        ],
      ),
    ),
  );
}
