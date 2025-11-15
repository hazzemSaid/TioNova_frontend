import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/data/services/Tokenstorage.dart';
import 'package:tionova/features/folder/data/models/NoteModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/add_note_bottom_sheet.dart';
import 'package:tionova/features/folder/presentation/view/widgets/note_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/note_detail_dialog.dart';

class NotesScreen extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;
  final Color? accentColor;

  const NotesScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
    this.accentColor,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SafeContextMixin {
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  List<Notemodel> _filteredNotes = [];
  List<Notemodel> _allNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      _filteredNotes = notes.where((note) {
        // Filter by type
        bool matchesFilter =
            _selectedFilter == 'all' ||
            (note.rawData['type'] as String?) == _selectedFilter;

        // Filter by search
        bool matchesSearch =
            _searchController.text.isEmpty ||
            note.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _showAddNoteBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddNoteBottomSheet(
        chapterId: widget.chapterId,
        accentColor: widget.accentColor ?? const Color(0xFF00D9A0),
        onNoteAdded: () {
          _loadNotes();
        },
      ),
    );
  }

  void _showNoteDetail(Notemodel note) {
    showDialog(
      context: context,
      builder: (context) => NoteDetailDialog(
        note: note,
        accentColor: widget.accentColor ?? const Color(0xFF00D9A0),
        onDelete: () async {
          if (mounted) {
            context.read<ChapterCubit>().deleteNote(
              noteId: note.id,
              chapterId: widget.chapterId,
            );
          }
        },
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
                    _loadNotes();
                  } else if (state is DeleteNoteSuccess) {
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
                    Navigator.of(context).pop(); // Close dialog
                    _loadNotes();
                  } else if (state is GetNotesByChapterIdError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message.errMessage),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is GetNotesByChapterIdLoading) {
                    return Center(
                      child: CircularProgressIndicator(color: _accentColor),
                    );
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteBottomSheet,
        backgroundColor: _accentColor,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Add Note',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _accentColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _filterNotes(_allNotes),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search notes...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: _accentColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'All', Icons.grid_view),
                _buildFilterChip('text', 'Text', Icons.text_fields),
                _buildFilterChip('image', 'Images', Icons.image),
                _buildFilterChip('voice', 'Voice', Icons.mic),
              ],
            ),
          ),
        ],
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
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? _accentColor : Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
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
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.note_add_outlined, size: 60, color: _accentColor),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notes Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'all'
                ? 'Start by adding your first note'
                : 'No ${_selectedFilter} notes found',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddNoteBottomSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'Add Note',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
