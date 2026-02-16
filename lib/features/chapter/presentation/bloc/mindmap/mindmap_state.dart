part of 'mindmap_cubit.dart';

abstract class MindmapState extends Equatable {
  const MindmapState();

  @override
  List<Object?> get props => [];
}

class MindmapInitial extends MindmapState {}

class MindmapLoading extends MindmapState {}

class MindmapError extends MindmapState {
  final String message;

  const MindmapError(this.message);

  @override
  List<Object?> get props => [message];
}

class MindmapLoaded extends MindmapState {
  final Mindmapmodel mindmap;
  final NodeModel? selectedNode;
  final Map<String, Offset> nodePositions;
  final double zoomLevel;

  // AI Generation status (keeps mindmap visible during generation)
  final bool isGeneratingAI;
  final String? generatedContent;
  final String? generatedUserInput;
  final String? aiError;

  // Save status (keeps mindmap visible during save)
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  const MindmapLoaded({
    required this.mindmap,
    required this.selectedNode,
    required this.nodePositions,
    this.zoomLevel = 1.0,
    this.isGeneratingAI = false,
    this.generatedContent,
    this.generatedUserInput,
    this.aiError,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });

  @override
  List<Object?> get props => [
    mindmap,
    selectedNode,
    nodePositions,
    zoomLevel,
    isGeneratingAI,
    generatedContent,
    generatedUserInput,
    aiError,
    isSaving,
    saveError,
    saveSuccess,
  ];

  MindmapLoaded copyWith({
    Mindmapmodel? mindmap,
    NodeModel? selectedNode,
    Map<String, Offset>? nodePositions,
    double? zoomLevel,
    bool? isGeneratingAI,
    String? generatedContent,
    String? generatedUserInput,
    String? aiError,
    bool? isSaving,
    String? saveError,
    bool? saveSuccess,
    bool clearGenerated = false,
    bool clearErrors = false,
  }) {
    return MindmapLoaded(
      mindmap: mindmap ?? this.mindmap,
      selectedNode: selectedNode,
      nodePositions: nodePositions ?? this.nodePositions,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isGeneratingAI: isGeneratingAI ?? this.isGeneratingAI,
      generatedContent: clearGenerated
          ? null
          : (generatedContent ?? this.generatedContent),
      generatedUserInput: clearGenerated
          ? null
          : (generatedUserInput ?? this.generatedUserInput),
      aiError: clearErrors ? null : (aiError ?? this.aiError),
      isSaving: isSaving ?? this.isSaving,
      saveError: clearErrors ? null : (saveError ?? this.saveError),
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

// Keep these for backwards compatibility but they're less commonly used now
class GeneratingSmartNode extends MindmapState {}

class SmartNodeGenerated extends MindmapState {
  final String generatedContent;
  final String userInput;

  const SmartNodeGenerated({
    required this.generatedContent,
    required this.userInput,
  });

  @override
  List<Object?> get props => [generatedContent, userInput];
}

class SmartNodeError extends MindmapState {
  final String message;

  const SmartNodeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Add Node States
class AddingNode extends MindmapState {}

class NodeAdded extends MindmapState {
  final NodeModel node;
  final Mindmapmodel updatedMindmap;

  const NodeAdded({required this.node, required this.updatedMindmap});

  @override
  List<Object?> get props => [node, updatedMindmap];
}

class AddNodeError extends MindmapState {
  final String message;

  const AddNodeError(this.message);

  @override
  List<Object?> get props => [message];
}

// Save Mindmap States
class SavingMindmap extends MindmapState {}

class MindmapSaved extends MindmapState {
  final Mindmapmodel updatedMindmap;

  const MindmapSaved(this.updatedMindmap);

  @override
  List<Object?> get props => [updatedMindmap];
}

class SaveMindmapError extends MindmapState {
  final String message;

  const SaveMindmapError(this.message);

  @override
  List<Object?> get props => [message];
}
