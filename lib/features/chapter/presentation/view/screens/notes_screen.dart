import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/core/utils/safe_navigation.dart';
import 'package:tionova/features/chapter/data/models/NoteModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/note/add_note_bottom_sheet.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/note/note_card.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/note/note_detail_dialog.dart';
import 'package:tionova/utils/widgets/dot_painter.dart';

class NotesScreen extends StatefulWidget {
  final String chapterId;
  final String? folderId;
  final String chapterTitle;
  final Color? accentColor;
  final String? folderOwnerId;

  const NotesScreen({
    super.key,
    required this.chapterId,
    this.folderId,
    required this.chapterTitle,
    this.accentColor,
    this.folderOwnerId,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SafeContextMixin {
  String _selectedFilter = 'all';
  String _sortOption = 'time'; // 'time' or 'alpha'
  bool _showFilterSort = false;
  List<Notemodel> _filteredNotes = [];
  List<Notemodel> _allNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (mounted) {
      context.read<ChapterCubit>().getNotesByChapterId(
        chapterId: widget.chapterId,
      );
    }
  }

  void _filterNotes(List<Notemodel> notes) {
    setState(() {
      _allNotes = notes;
      var filtered = notes.where((note) {
        return _selectedFilter == 'all' ||
            (note.rawData['type'] as String?) == _selectedFilter;
      }).toList();

      if (_sortOption == 'time') {
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      }

      _filteredNotes = filtered;
    });
  }

  void _showAddNoteBottomSheet() {
    final chapterCubit = context.read<ChapterCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: chapterCubit,
        child: AddNoteBottomSheet(
          chapterId: widget.chapterId,
          accentColor:
              widget.accentColor ?? Theme.of(context).colorScheme.primary,
          onNoteAdded: () {
            _loadNotes();
          },
        ),
      ),
    );
  }

  void _showNoteDetail(Notemodel note) {
    final chapterCubit = context.read<ChapterCubit>();
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: chapterCubit,
        child: NoteDetailDialog(
          note: note,
          accentColor:
              widget.accentColor ?? Theme.of(context).colorScheme.primary,
          onDelete: () async {
            chapterCubit.deleteNote(
              noteId: note.id,
              chapterId: widget.chapterId,
            );
          },
        ),
      ),
    );
  }

  Color get _accentColor =>
      widget.accentColor ?? Theme.of(context).colorScheme.primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 900;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          // Background Pattern
          Positioned.fill(
            child: CustomPaint(
              painter: DotPainter(
                colorScheme.primary.withOpacity(
                  theme.brightness == Brightness.dark ? 0.05 : 0.03,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, colorScheme, isWeb),
                _buildSearchAndFilter(colorScheme),
                Expanded(
                  child: BlocConsumer<ChapterCubit, ChapterState>(
                    listener: _handleCubitState,
                    builder: (context, state) {
                      if (state is GetNotesByChapterIdLoading) {
                        return _buildShimmerLoading(colorScheme, isWeb);
                      }
                      if (_filteredNotes.isEmpty) {
                        return _buildEmptyState(colorScheme);
                      }
                      return _buildNotesContent(isWeb);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(colorScheme),
    );
  }

  void _handleCubitState(BuildContext context, ChapterState state) {
    if (state is GetNotesByChapterIdSuccess) {
      _filterNotes(state.notes);
    } else if (state is AddNoteSuccess) {
      if (mounted) {
        _showSnackBar('Note added successfully', _accentColor);
      }
      _loadNotes();
    } else if (state is DeleteNoteSuccess) {
      if (mounted) {
        _showSnackBar('Note deleted successfully', Colors.red);
        GoRouter.of(context).pop();
      }
      _loadNotes();
    } else if (state is GetNotesByChapterIdError) {
      if (mounted) {
        _showSnackBar(state.message.errMessage, Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isWeb,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWeb ? 48 : 16, vertical: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.safePop(
              folderId: widget.folderId,
              chapterId: widget.chapterId,
              fallback: '/',
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: colorScheme.onSurface,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: isWeb ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  widget.chapterTitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildActionButtons(colorScheme),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _showFilterSort = !_showFilterSort),
          icon: Icon(
            _showFilterSort ? Icons.close_rounded : Icons.tune_rounded,
            color: _showFilterSort ? _accentColor : colorScheme.onSurface,
          ),
          style: IconButton.styleFrom(
            backgroundColor: _showFilterSort
                ? _accentColor.withOpacity(0.1)
                : colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accentColor.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              '${_filteredNotes.length}',
              style: TextStyle(
                color: _accentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(ColorScheme colorScheme) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: _showFilterSort
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
              ),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildFilterGroup('Filter', [
                    _buildFilterChip('all', 'All', Icons.grid_view_rounded),
                    _buildFilterChip('text', 'Text', Icons.text_fields_rounded),
                    _buildFilterChip('image', 'Images', Icons.image_rounded),
                    _buildFilterChip('voice', 'Voice', Icons.mic_rounded),
                  ], colorScheme),
                  _buildFilterGroup('Sort', [
                    _buildSortChip('time', 'Newest', Icons.access_time_rounded),
                    _buildSortChip('alpha', 'A-Z', Icons.sort_by_alpha_rounded),
                  ], colorScheme),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildFilterGroup(
    String title,
    List<Widget> children,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisSize: MainAxisSize.min, children: children),
      ],
    );
  }

  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
        onSelected: (_) => setState(() {
          _selectedFilter = filter;
          _filterNotes(_allNotes);
        }),
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: _accentColor,
        checkmarkColor: colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSortChip(String sort, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _sortOption == sort;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: Icon(
          icon,
          size: 16,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
        onSelected: (_) => setState(() {
          _sortOption = sort;
          _filterNotes(_allNotes);
        }),
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: _accentColor,
        checkmarkColor: colorScheme.onPrimary,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNotesContent(bool isWeb) {
    if (isWeb) {
      return GridView.builder(
        padding: const EdgeInsets.all(48),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 220,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
        ),
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
    );
  }

  Widget _buildNoteCard(Notemodel note) {
    return NoteCard(
      note: note,
      accentColor: _accentColor,
      onTap: () => _showNoteDetail(note),
      folderOwnerId: widget.folderOwnerId,
    );
  }

  Widget _buildFAB(ColorScheme colorScheme) {
    return FloatingActionButton.extended(
      onPressed: _showAddNoteBottomSheet,
      backgroundColor: _accentColor,
      foregroundColor: colorScheme.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Add Note',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Empty box by partho.json',
            width: 250,
            height: 250,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ColorScheme colorScheme, bool isWeb) {
    return GridView.builder(
      padding: EdgeInsets.all(isWeb ? 48 : 16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 220,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
