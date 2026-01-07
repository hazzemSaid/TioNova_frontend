import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/add_note_bottom_sheet.dart';
import 'package:tionova/features/folder/presentation/view/widgets/note_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/note_detail_dialog.dart';

class NotesScreen extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;
  final Color? accentColor;
  final String? folderOwnerId;

  const NotesScreen({
    super.key,
    required this.chapterId,
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
  bool _showFilterSort = false; // Toggle for filter/sort visibility
  List<Notemodel> _filteredNotes = [];
  List<Notemodel> _allNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    super.dispose();
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
      // Filter by type
      var filtered = notes.where((note) {
        return _selectedFilter == 'all' ||
            (note.rawData['type'] as String?) == _selectedFilter;
      }).toList();

      // Sort notes
      if (_sortOption == 'time') {
        filtered.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        ); // Newest first
      } else {
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        ); // A-Z
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
          accentColor: widget.accentColor ?? const Color(0xFF00D9A0),
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
          accentColor: widget.accentColor ?? const Color(0xFF00D9A0),
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

  Color get _accentColor => widget.accentColor ?? const Color(0xFF00D9A0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Search and Filter Section
            _buildSearchAndFilter(),

            // Notes List
            Expanded(
              child: BlocConsumer<ChapterCubit, ChapterState>(
                listener: (context, state) {
                  if (state is GetNotesByChapterIdSuccess) {
                    _filterNotes(state.notes);
                  } else if (state is AddNoteSuccess) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Note added successfully'),
                          backgroundColor: _accentColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                    _loadNotes();
                  } else if (state is DeleteNoteSuccess) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Note deleted successfully'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      GoRouter.of(context).pop();
                    }
                    _loadNotes();
                  } else if (state is GetNotesByChapterIdError) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message.errMessage),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                builder: (context, state) {
                  if (state is GetNotesByChapterIdLoading) {
                    return _buildShimmerLoading();
                  }

                  if (_filteredNotes.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildNotesList();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_accentColor, _accentColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _accentColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddNoteBottomSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          label: const Icon(Icons.add_rounded, color: Colors.black, size: 24),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E10),
        border: Border(
          bottom: BorderSide(color: _accentColor.withOpacity(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.chapterTitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                _showFilterSort = !_showFilterSort;
              });
            },
            icon: Icon(
              _showFilterSort ? Icons.close : Icons.filter_list,
              color: _showFilterSort ? _accentColor : Colors.white,
            ),
            style: IconButton.styleFrom(
              backgroundColor: _showFilterSort
                  ? _accentColor.withOpacity(0.15)
                  : Colors.transparent,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
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
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showFilterSort ? null : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _showFilterSort ? 1.0 : 0.0,
        child: _showFilterSort
            ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E10),
                  border: Border(
                    bottom: BorderSide(
                      color: _accentColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Section
                    Row(
                      children: [
                        Text(
                          'Filter:',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('all', 'All', Icons.grid_view),
                                _buildFilterChip(
                                  'text',
                                  'Text',
                                  Icons.text_fields,
                                ),
                                _buildFilterChip(
                                  'image',
                                  'Images',
                                  Icons.image,
                                ),
                                _buildFilterChip('voice', 'Voice', Icons.mic),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Sort Section
                    Row(
                      children: [
                        Text(
                          'Sort:',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildSortChip('time', 'Newest', Icons.access_time),
                        const SizedBox(width: 8),
                        _buildSortChip('alpha', 'A-Z', Icons.sort_by_alpha),
                      ],
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
            _filterNotes(_allNotes);
          });
        },
        backgroundColor: const Color(0xFF1C1C1E),
        selectedColor: _accentColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? _accentColor : Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildSortChip(String sort, String label, IconData icon) {
    final isSelected = _sortOption == sort;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _sortOption = sort;
          _filterNotes(_allNotes);
        });
      },
      backgroundColor: const Color(0xFF1C1C1E),
      selectedColor: _accentColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? _accentColor : Colors.grey[700]!,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildNotesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        return NoteCard(
          note: note,
          accentColor: _accentColor,
          onTap: () => _showNoteDetail(note),
          folderOwnerId: widget.folderOwnerId,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Empty box by partho.json',
            width: 250,
            height: 250,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: const Color(0xFF1C1C1E),
          highlightColor: const Color(0xFF2C2C2E),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
