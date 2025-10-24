import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';

class CreateChallengeScreen extends StatefulWidget {
  final String? challengeName;
  final int questionsCount;
  final int durationMinutes;
  final String inviteCode;
  final String? chapterName;
  final String? chapterDescription;

  const CreateChallengeScreen({
    super.key,
    this.challengeName,
    this.questionsCount = 10,
    this.durationMinutes = 15,
    this.inviteCode = 'Q4DRE9',
    this.chapterName,
    this.chapterDescription,
  });

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  late TextEditingController _titleController;
  late int _questionsCount;
  late int _durationMinutes;
  Foldermodel? _selectedFolder;
  final Set<String> _selectedChapterIds = {};
  String? _selectedChapterTitle; // for UI header and preview

  @override
  void initState() {
    super.initState();
    _questionsCount = widget.questionsCount;
    _durationMinutes = widget.durationMinutes;
    _titleController = TextEditingController(text: widget.challengeName ?? '');
    _selectedChapterTitle = widget.challengeName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ScrollConfiguration(
                behavior: const NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildChapterCard(),
                      const SizedBox(height: 16),
                      _buildChallengeTitleField(),
                      const SizedBox(height: 16),
                      _buildChallengePreviewCard(),
                      const SizedBox(height: 16),
                      _buildQRCodeSection(),
                      const SizedBox(height: 16),
                      _buildShareButtons(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            _buildStartChallengeButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: _cardBg, shape: BoxShape.circle),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'Share Challenge',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildChapterCard() {
    return InkWell(
      onTap: () => _showFolderSelectionDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'CHAPTER',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.edit_outlined, color: _green, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: _green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if ((widget.chapterName ?? _selectedFolder?.title)
                              ?.isNotEmpty ==
                          true)
                        Text(
                          (widget.chapterName ?? _selectedFolder?.title)!,
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedChapterTitle ?? 'Tap to select chapter',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.chapterDescription?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.chapterDescription!,
                          style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeTitleField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHALLENGE TITLE',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter challenge title',
              hintStyle: TextStyle(
                color: _textPrimary.withOpacity(0.5),
                fontSize: 15,
              ),
              filled: true,
              fillColor: _panelBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengePreviewCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2DD881), Color(0xFF26B56A)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _titleController.text.isEmpty
                        ? (_selectedChapterTitle ?? 'Challenge')
                        : _titleController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_questionsCount questions • $_durationMinutes minutes',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Ready to Start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Opens the folder -> chapters dialog and updates selection
  void _showFolderSelectionDialog(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FolderCubit>()),
          BlocProvider.value(value: context.read<ChapterCubit>()),
          BlocProvider.value(value: authCubit),
        ],
        child: _FolderSelectionDialog(
          currentFolder: _selectedFolder,
          currentSelectedIds: _selectedChapterIds,
          onConfirm: (folder, chapterIds, firstChapterTitle) {
            setState(() {
              _selectedFolder = folder;
              _selectedChapterIds
                ..clear()
                ..addAll(chapterIds);
              // Use the first chapter title (or folder title fallback) to show in card
              _selectedChapterTitle = firstChapterTitle ?? folder.title;
              if (_titleController.text.isEmpty) {
                _titleController.text = _selectedChapterTitle ?? 'Challenge';
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_2_rounded, color: _textSecondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'SCAN TO JOIN',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: widget.inviteCode,
              version: QrVersions.auto,
              size: 160,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'OR USE CODE',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _panelBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.inviteCode,
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: widget.inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _green,
                        content: const Text(
                          'Code copied to clipboard',
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    color: _textSecondary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // TODO: Implement share functionality
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share, color: _textPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // TODO: Implement save QR functionality
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download_rounded, color: _textPrimary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Save QR',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartChallengeButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // TODO: Start challenge
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.play_arrow_rounded, size: 22),
              SizedBox(width: 8),
              Text(
                'Start Challenge',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom sheet to select folder then chapters
class _FolderSelectionDialog extends StatefulWidget {
  final Foldermodel? currentFolder;
  final Set<String> currentSelectedIds;
  // onConfirm returns folder, selected chapter ids and an optional chapter title for display
  final void Function(
    Foldermodel folder,
    Set<String> chapterIds,
    String? firstChapterTitle,
  )
  onConfirm;

  const _FolderSelectionDialog({
    required this.currentFolder,
    required this.currentSelectedIds,
    required this.onConfirm,
  });

  @override
  State<_FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends State<_FolderSelectionDialog> {
  Foldermodel? _selectedFolder;
  final Set<String> _selectedChapterIds = {};
  bool _showChapters = false;
  String? _firstChapterTitle;

  Color get _bg => const Color(0xFF000000);
  Color get _cardBg => const Color(0xFF1C1C1E);
  Color get _panelBg => const Color(0xFF0E0E10);
  Color get _textPrimary => const Color(0xFFFFFFFF);
  Color get _textSecondary => const Color(0xFF8E8E93);
  Color get _divider => const Color(0xFF2C2C2E);
  Color get _green => const Color(0xFF30D158);

  @override
  void initState() {
    super.initState();
    _selectedFolder = widget.currentFolder;
    _selectedChapterIds.addAll(widget.currentSelectedIds);
    _showChapters = _selectedFolder != null;

    // Fetch all folders on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess) {
        context.read<FolderCubit>().fetchAllFolders(authState.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Container(
      height: height * 0.85,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: _divider),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _showChapters ? _buildChaptersList() : _buildFoldersGrid(),
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          if (_showChapters)
            InkWell(
              onTap: () => setState(() => _showChapters = false),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _panelBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: _textSecondary,
                  size: 16,
                ),
              ),
            ),
          if (_showChapters) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showChapters ? 'Pick Chapters' : 'Pick a Folder',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_showChapters && _selectedFolder != null)
                  Text(
                    _selectedFolder!.title,
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
              ],
            ),
          ),
          if (_showChapters && _selectedChapterIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_selectedChapterIds.length}',
                style: TextStyle(color: _green, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoldersGrid() {
    return BlocBuilder<FolderCubit, FolderState>(
      builder: (context, state) {
        if (state is FolderLoading) {
          return Center(child: CircularProgressIndicator(color: _green));
        }
        if (state is FolderError) {
          return Center(
            child: Text(
              'Failed to load folders',
              style: TextStyle(color: _textSecondary),
            ),
          );
        }
        if (state is FolderLoaded) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: state.folders.length,
            itemBuilder: (context, index) {
              final folder = state.folders[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  setState(() {
                    _selectedFolder = folder;
                    _selectedChapterIds.clear();
                    _firstChapterTitle = null;
                    _showChapters = true;
                  });
                  final authState = context.read<AuthCubit>().state;
                  if (authState is AuthSuccess) {
                    context.read<ChapterCubit>().getChapters(
                      folderId: folder.id,
                      token: authState.token,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _divider),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _panelBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.folder_rounded,
                          color: _green,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        folder.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${folder.chapterCount ?? 0} chapters',
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChaptersList() {
    return BlocBuilder<ChapterCubit, ChapterState>(
      builder: (context, state) {
        if (state is ChapterLoading) {
          return Center(child: CircularProgressIndicator(color: _green));
        }
        if (state is ChapterError) {
          return Center(
            child: Text(
              'Failed to load chapters',
              style: TextStyle(color: _textSecondary),
            ),
          );
        }
        if (state is ChapterLoaded) {
          final chapters = state.chapters;
          if (chapters.isEmpty) {
            return Center(
              child: Text(
                'No chapters',
                style: TextStyle(color: _textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            itemCount: chapters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final chapterId = chapter.id;
              final selected =
                  chapterId != null && _selectedChapterIds.contains(chapterId);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (chapterId != null) {
                      if (selected) {
                        _selectedChapterIds.remove(chapterId);
                      } else {
                        _selectedChapterIds.add(chapterId);
                      }
                    }
                    _firstChapterTitle ??= chapter.title;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? _green : _divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.check_circle : Icons.circle_outlined,
                        color: selected ? _green : _textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          chapter.title ?? 'Untitled Chapter',
                          style: TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    final canConfirm =
        _selectedFolder != null && _selectedChapterIds.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: canConfirm
              ? () {
                  if (_selectedFolder == null) return;
                  widget.onConfirm(
                    _selectedFolder!,
                    _selectedChapterIds,
                    _firstChapterTitle,
                  );
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: canConfirm ? _green : _divider,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Confirm Selection',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
