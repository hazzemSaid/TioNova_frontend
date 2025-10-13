part of 'mindmap_cubit.dart';

abstract class MindmapState extends Equatable {
  const MindmapState();

  @override
  List<Object?> get props => [];
}

class MindmapInitial extends MindmapState {}

class MindmapLoaded extends MindmapState {
  final Mindmapmodel mindmap;
  final NodeModel? selectedNode;
  final Map<String, Offset> nodePositions;
  final double zoomLevel;

  const MindmapLoaded({
    required this.mindmap,
    required this.selectedNode,
    required this.nodePositions,
    this.zoomLevel = 1.0,
  });

  @override
  List<Object?> get props => [mindmap, selectedNode, nodePositions, zoomLevel];

  MindmapLoaded copyWith({
    Mindmapmodel? mindmap,
    NodeModel? selectedNode,
    Map<String, Offset>? nodePositions,
    double? zoomLevel,
  }) {
    return MindmapLoaded(
      mindmap: mindmap ?? this.mindmap,
      selectedNode: selectedNode,
      nodePositions: nodePositions ?? this.nodePositions,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }
}
