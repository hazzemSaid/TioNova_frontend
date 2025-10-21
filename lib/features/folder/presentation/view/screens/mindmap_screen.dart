import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/presentation/bloc/mindmap/mindmap_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/mindmap_viewer.dart';

/// Example screen showing how to use the Mindmap Viewer with BLoC
class MindmapScreen extends StatelessWidget {
  final Mindmapmodel mindmap;

  const MindmapScreen({Key? key, required this.mindmap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MindmapCubit(),
      child: MindmapViewer(mindmap: mindmap),
    );
  }
}

/// Alternative: If you already have a MindmapCubit instance in your parent widget
class MindmapScreenWithExistingCubit extends StatelessWidget {
  final Mindmapmodel mindmap;

  const MindmapScreenWithExistingCubit({super.key, required this.mindmap});

  @override
  Widget build(BuildContext context) {
    // Use the existing MindmapCubit from parent context
    return MindmapViewer(mindmap: mindmap);
  }
}
