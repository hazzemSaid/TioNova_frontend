import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/folder/domain/usecases/CreateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/DeleteFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetAllFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/GetPublicFoldersUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/UpdateFolderUseCase.dart';
import 'package:tionova/features/folder/domain/usecases/getAvailableUsersForShareUseCase.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen_widgets.dart'; // For LongPressHint
import 'package:tionova/features/folder/presentation/view/widgets/create_folder_card.dart';
import 'package:tionova/features/folder/presentation/view/widgets/create_folder_dialog.dart';

class FolderActionsSection extends StatelessWidget {
  final bool showCreateCard;
  final double verticalSpacing;

  const FolderActionsSection({
    super.key,
    required this.showCreateCard,
    required this.verticalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    if (!showCreateCard)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        children: [
          CreateFolderCard(
            onTap: () async {
              final result = await showDialog<dynamic>(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.5),
                builder: (dialogContext) => BlocProvider(
                  create: (dialogContext) => FolderCubit(
                    getAllFolderUseCase: getIt<GetAllFolderUseCase>(),
                    createFolderUseCase: getIt<CreateFolderUseCase>(),
                    updateFolderUseCase: getIt<UpdateFolderUseCase>(),
                    deleteFolderUseCase: getIt<DeleteFolderUseCase>(),
                    getAvailableUsersForShareUseCase:
                        getIt<GetAvailableUsersForShareUseCase>(),
                    getPublicFoldersUseCase: getIt<GetPublicFoldersUseCase>(),
                  ),
                  child: const CreateFolderDialog(),
                ),
              );
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Folder created'),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          SizedBox(height: verticalSpacing * 1.5),
          const LongPressHint(),
          SizedBox(height: verticalSpacing * 1.5),
        ],
      ),
    );
  }
}
