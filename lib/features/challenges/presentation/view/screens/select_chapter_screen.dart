import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tionova/core/utils/safe_context_mixin.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/challenges/presentation/bloc/challenge_cubit.dart';
import 'package:tionova/features/chapter/data/models/ChapterModel.dart';
import 'package:tionova/features/chapter/presentation/bloc/chapter/chapter_cubit.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
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
  String? _selectedChapterId; // Only allow single chapter selection
  ChapterModel? _selectedChapter; // Store complete chapter context
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
      context.read<FolderCubit>().fetchAllFolders();
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
                  _showChapters ? 'Select Chapter' : 'Select a Folder',
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
          if (_showChapters && _selectedChapterId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '1',
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
                      _selectedChapterId = null;
                      _selectedChapter = null; // Reset chapter context
                      _firstChapterTitle = null;
                      _showChapters = true;
                    });
                    if (!mounted) {
                      return;
                    }

                    // Use ChapterCubit properly to fetch chapters
                    context.read<ChapterCubit>().getChapters(
                      folderId: folder.id,
                    );
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: _textSecondary, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Failed to load chapters',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message.errMessage,
                  style: TextStyle(color: _textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedFolder != null) {
                      context.read<ChapterCubit>().getChapters(
                        folderId: _selectedFolder!.id,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (state is ChapterLoaded) {
          final chapters = state.chapters;
          if (chapters.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, color: _textSecondary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No chapters found',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This folder doesn\'t contain any chapters yet.',
                    style: TextStyle(color: _textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                final selected = _selectedChapterId == chapterId;
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedChapterId = null;
                        _selectedChapter = null;
                      } else {
                        _selectedChapterId = chapterId;
                        _selectedChapter =
                            chapter; // Store complete chapter context
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
        _selectedFolder != null &&
        _selectedChapterId != null &&
        _selectedChapter != null;

    return BlocConsumer<ChallengeCubit, ChallengeState>(
      listener: (context, state) {
        if (state is ChallengeCreated) {
          // Navigate to Share Challenge screen with the generated code
          if (!contextIsValid) return;

          // Validate inviteCode before navigation
          if (state.inviteCode.isEmpty) {
            safeContext((ctx) {
              CustomDialogs.showErrorDialog(
                ctx,
                title: 'Challenge Creation Failed',
                message: 'Failed to generate challenge code. Please try again.',
              );
            });
            return;
          }

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
                'chapterName':
                    _selectedChapter?.title ?? _selectedFolder!.title,
                'challengeName': state.challengeName,
                'questionsCount': state.questionsCount,
                'durationMinutes': state.durationMinutes,
                'chapterContext':
                    state.chapterContext, // Pass complete chapter context
                'selectedFolder': _selectedFolder, // Pass folder context
              },
            );
          });
        } else if (state is ChallengeError) {
          // Show enhanced error dialog
          safeContext((ctx) {
            CustomDialogs.showErrorDialog(
              ctx,
              title: 'Challenge Creation Failed',
              message: _getErrorMessage(state.message),
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
                  ? () => _createChallengeWithChapter()
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

  /// Create challenge with proper chapter context integration
  Future<void> _createChallengeWithChapter() async {
    // Validate all required data is present
    if (_selectedFolder == null ||
        _selectedChapterId == null ||
        _selectedChapter == null ||
        !contextIsValid) {
      _showValidationError();
      return;
    }

    try {
      // Validate chapter has sufficient content for quiz generation
      if (!_validateChapterContent(_selectedChapter!)) {
        _showInsufficientContentError();
        return;
      }

      // Create challenge with complete chapter context
      await context.read<ChallengeCubit>().createChallenge(
        chapterId: _selectedChapterId!,
        title: _selectedChapter!.title ?? 'Challenge',
        chapterContext: _selectedChapter!, // Pass complete chapter context
      );
    } catch (e) {
      // Handle unexpected errors
      if (contextIsValid) {
        safeContext((ctx) {
          CustomDialogs.showErrorDialog(
            ctx,
            title: 'Unexpected Error',
            message:
                'An unexpected error occurred while creating the challenge. Please try again.',
          );
        });
      }
    }
  }

  /// Validate chapter has sufficient content for quiz generation
  bool _validateChapterContent(ChapterModel chapter) {
    // Basic validation - chapter should have title and description
    if (chapter.title == null || chapter.title!.trim().isEmpty) {
      return false;
    }

    // Additional validation can be added here based on business requirements
    // For example, checking if chapter has summary, minimum content length, etc.

    return true;
  }

  /// Show validation error when required data is missing
  void _showValidationError() {
    if (contextIsValid) {
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Selection Required',
          message:
              'Please select both a folder and a chapter before creating a challenge.',
        );
      });
    }
  }

  /// Show error when chapter doesn't have sufficient content
  void _showInsufficientContentError() {
    if (contextIsValid) {
      safeContext((ctx) {
        CustomDialogs.showErrorDialog(
          ctx,
          title: 'Insufficient Content',
          message:
              'The selected chapter doesn\'t have enough content to generate a quiz. Please select a different chapter.',
        );
      });
    }
  }

  /// Get user-friendly error message from API error
  String _getErrorMessage(String originalMessage) {
    // Map common API errors to user-friendly messages
    if (originalMessage.toLowerCase().contains('network')) {
      return 'Network connection failed. Please check your internet connection and try again.';
    } else if (originalMessage.toLowerCase().contains('timeout')) {
      return 'The request timed out. Please try again.';
    } else if (originalMessage.toLowerCase().contains('unauthorized')) {
      return 'You don\'t have permission to create challenges. Please log in again.';
    } else if (originalMessage.toLowerCase().contains('chapter not found')) {
      return 'The selected chapter could not be found. Please try selecting a different chapter.';
    } else if (originalMessage.toLowerCase().contains('insufficient content')) {
      return 'The selected chapter doesn\'t have enough content to generate quiz questions.';
    } else {
      return originalMessage.isNotEmpty
          ? originalMessage
          : 'Failed to create challenge. Please try again.';
    }
  }
}
