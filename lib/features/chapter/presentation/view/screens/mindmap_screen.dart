import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/chapter/data/models/mindmapmodel.dart';
import 'package:tionova/features/chapter/presentation/bloc/mindmap/mindmap_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/mindmap/mindmap_viewer.dart';

/// Example screen showing how to use the Mindmap Viewer with BLoC
class MindmapScreen extends StatelessWidget {
  final Mindmapmodel mindmap;
  final String? folderId;
  final String? chapterId;

  const MindmapScreen({
    Key? key,
    required this.mindmap,
    this.folderId,
    this.chapterId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MindmapCubit>(),
      child: MindmapViewer(
        mindmap: mindmap,
        folderId: folderId,
        chapterId: chapterId,
      ),
    );
  }
}

/// Alternative: If you already have a MindmapCubit instance in your parent widget
class MindmapScreenWithExistingCubit extends StatelessWidget {
  final Mindmapmodel mindmap;
  final String? folderId;
  final String? chapterId;

  const MindmapScreenWithExistingCubit({
    super.key,
    required this.mindmap,
    this.folderId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    // Use the existing MindmapCubit from parent context
    return MindmapViewer(
      mindmap: mindmap,
      folderId: folderId,
      chapterId: chapterId,
    );
  }
}
