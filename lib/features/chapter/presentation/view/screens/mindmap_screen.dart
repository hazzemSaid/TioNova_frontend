import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/chapter/data/models/mindmapmodel.dart';
import 'package:tionova/features/chapter/presentation/bloc/mindmap/mindmap_cubit.dart';
import 'package:tionova/features/chapter/presentation/view/widgets/mindmap/mindmap_viewer.dart';

/// Example screen showing how to use the Mindmap Viewer with BLoC
class MindmapScreen extends StatelessWidget {
  final Mindmapmodel? mindmap; // Made optional
  final String? folderId;
  final String? chapterId;

  const MindmapScreen({
    super.key, // Fixed super parameter
    this.mindmap, // Made optional
    this.folderId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MindmapCubit>(),
      child: _MindmapScreenContent(
        mindmap: mindmap,
        folderId: folderId,
        chapterId: chapterId,
      ),
    );
  }
}

/// Internal content widget that handles loading state
class _MindmapScreenContent extends StatefulWidget {
  final Mindmapmodel? mindmap;
  final String? folderId;
  final String? chapterId;

  const _MindmapScreenContent({this.mindmap, this.folderId, this.chapterId});

  @override
  State<_MindmapScreenContent> createState() => _MindmapScreenContentState();
}

class _MindmapScreenContentState extends State<_MindmapScreenContent> {
  @override
  void initState() {
    super.initState();

    // If no mindmap is provided, fetch from API
    if (widget.mindmap == null && widget.chapterId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MindmapCubit>().fetchMindmap(widget.chapterId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MindmapCubit, MindmapState>(
      builder: (context, state) {
        // Show loading while fetching mindmap
        if (state is MindmapLoading) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E27),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0A0E27),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Mind Map',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading Mind Map...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }

        // Show error if mindmap failed to load
        if (state is MindmapError) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E27),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0A0E27),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Mind Map',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load mind map',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.chapterId != null) {
                        context.read<MindmapCubit>().fetchMindmap(
                          widget.chapterId!,
                        );
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Use provided mindmap or the one from cubit state
        final mindmapToUse =
            widget.mindmap ?? (state is MindmapLoaded ? state.mindmap : null);

        if (mindmapToUse == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E27),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0A0E27),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Mind Map',
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hub_outlined, color: Colors.white, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No mind map available',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return MindmapViewer(
          mindmap: mindmapToUse,
          folderId: widget.folderId,
          chapterId: widget.chapterId,
        );
      },
    );
  }
}

/// Alternative: If you already have a MindmapCubit instance in your parent widget
class MindmapScreenWithExistingCubit extends StatelessWidget {
  final Mindmapmodel? mindmap; // Made optional
  final String? folderId;
  final String? chapterId;

  const MindmapScreenWithExistingCubit({
    super.key,
    this.mindmap, // Made optional
    this.folderId,
    this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null mindmap case
    if (mindmap == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0E27),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0E27),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Mind Map', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hub_outlined, color: Colors.white, size: 48),
              SizedBox(height: 16),
              Text(
                'No mind map available',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Create a mind map to get started',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Use the existing MindmapCubit from parent context
    return MindmapViewer(
      mindmap: mindmap!,
      folderId: folderId,
      chapterId: chapterId,
    );
  }
}
