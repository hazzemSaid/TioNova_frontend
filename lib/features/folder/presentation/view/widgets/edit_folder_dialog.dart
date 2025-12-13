import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/auth/presentation/bloc/Authcubit.dart';
import 'package:tionova/features/folder/data/models/foldermodel.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/EditFolderDialog.dart';

void showEditFolderDialog(
  BuildContext context,
  Foldermodel folder,
  List<Color> defaultColors,
  List<IconData> defaultIcons,
  FolderCubit folderCubit,
) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: folderCubit),
        BlocProvider.value(value: context.read<AuthCubit>()),
      ],
      child: EditFolderDialog(
        folder: folder,
        defaultcolors: defaultColors,
        icons: defaultIcons,
      ),
    ),
  );
}