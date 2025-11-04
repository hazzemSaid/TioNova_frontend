import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/auth/presentation/bloc/Authstate.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/folder/data/models/FolderModel.dart';
import 'package:tionova/features/folder/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/utils/no_glow_scroll_behavior.dart';
import 'package:tionova/utils/widgets/custom_dialogs.dart';

class SelectChapterScreen extends StatefulWidget {
  const SelectChapterScreen({super.key});

  @override
  State<SelectChapterScreen> createState() => _SelectChapterScreenState();
}

class _SelectChapterScreenState extends State<SelectChapterScreen>
    with SafeContextMixin {
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
  Color get _green => const Color.fromRGBO(0, 153, 102, 1);

  @override
  void initState() {
    super.initState();
    // Fetch all folders on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!contextIsValid) return;
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthSuccess) {
        context.read<FolderCubit>().fetchAllFolders(authState.token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _showChapters ? _buildChaptersList() : _buildFoldersGrid(),
            ),
            _buildContinueButton(),
          ],
        ),
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
            )
          else
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _panelBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.close, color: _textSecondary, size: 20),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showChapters ? 'Select Chapters' : 'Select a Folder',
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
          return ScrollConfiguration(
            behavior: const NoGlowScrollBehavior(),
            child: GridView.builder(
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
                    if (!mounted) return;
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
            ),
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
          return ScrollConfiguration(
            behavior: const NoGlowScrollBehavior(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: chapters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final chapter = chapters[index];
                final chapterId = chapter.id;
                final selected =
                    chapterId != null &&
                    _selectedChapterIds.contains(chapterId);
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
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildContinueButton() {
    final canContinue =
        _selectedFolder != null && _selectedChapterIds.isNotEmpty;
    return BlocConsumer<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengeCreated) {
          // Navigate to Share Challenge screen with the generated code
          if (!contextIsValid) return;

          // Store cubit references before navigation
          safeContext((ctx) {
            final folderCubit = ctx.read<FolderCubit>();
            final chapterCubit = ctx.read<ChapterCubit>();
            final authCubit = ctx.read<AuthCubit>();
            final challengeCubit = ctx.read<ChallengeCubit>();

            GoRouter.of(ctx).pushNamed(
              'challenge-create',
              extra: {
                'folderCubit': folderCubit,
                'chapterCubit': chapterCubit,
                'authCubit': authCubit,
                'challengeCubit': challengeCubit,
                'inviteCode': state.inviteCode,
                'chapterName': _selectedFolder!.title,
                'challengeName': state.challengeName,
                'questionsCount': state.questionsCount,
                'durationMinutes': state.durationMinutes,
              },
            );
          });
        } else if (state is ChallengeError) {
          // Show error dialog
          safeContext((ctx) {
            CustomDialogs.showErrorDialog(
              ctx,
              title: 'Error!',
              message: state.message,
            );
          });
        }
      },
      builder: (context, state) {
        final isLoading = state is ChallengeLoading;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: (canContinue && !isLoading)
                  ? () async {
                      if (_selectedFolder == null || !contextIsValid) return;

                      final authState = context.read<AuthCubit>().state;
                      if (authState is! AuthSuccess) {
                        safeContext((ctx) {
                          CustomDialogs.showErrorDialog(
                            ctx,
                            title: 'Authentication Required',
                            message: 'Please login first',
                          );
                        });
                        return;
                      }

                      // Get the first selected chapter ID as string
                      final firstChapterId = _selectedChapterIds.first;

                      // Create challenge via API (Step 1)
                      await context.read<ChallengeCubit>().createChallenge(
                        token: authState.token,
                        chapterId: firstChapterId,
                        title: _firstChapterTitle ?? 'Challenge',
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canContinue ? _green : _divider,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Create Challenge',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
