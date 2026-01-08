import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tionova/core/utils/safe_emit.dart';
import 'package:tionova/features/chapter/data/models/mindmapmodel.dart';
import 'package:tionova/features/chapter/data/models/new_node_model.dart';
import 'package:tionova/features/chapter/data/models/nodeModel.dart';
import 'package:tionova/features/chapter/domain/usecases/GenerateSmartNodeUseCase.dart';
import 'package:tionova/features/chapter/domain/usecases/SaveMindmapUseCase.dart';

part 'mindmap_state.dart';

class MindmapCubit extends Cubit<MindmapState> {
  final GenerateSmartNodeUseCase? generateSmartNodeUseCase;
  final SaveMindmapUseCase? saveMindmapUseCase;

  // Store current mindmap for reference during operations
  Mindmapmodel? _currentMindmap;
  String? _currentChapterId;
  Map<String, Offset> _nodePositions = {};

  MindmapCubit({this.generateSmartNodeUseCase, this.saveMindmapUseCase})
    : super(MindmapInitial());

  /// Getter for current mindmap
  Mindmapmodel? get currentMindmap => _currentMindmap;

  /// Getter for current chapter ID
  String? get currentChapterId => _currentChapterId;

  void loadMindmap(Mindmapmodel mindmap, {String? chapterId}) {
    _currentMindmap = mindmap;
    _currentChapterId = chapterId ?? mindmap.chapterId;
    safeEmit(
      MindmapLoaded(
        mindmap: mindmap,
        selectedNode: null,
        nodePositions: _nodePositions,
      ),
    );
  }

  void selectNode(NodeModel? node) {
    if (state is MindmapLoaded) {
      final currentState = state as MindmapLoaded;
      safeEmit(currentState.copyWith(selectedNode: node));
    }
  }

  void updateNodePosition(String nodeId, Offset position) {
    if (state is MindmapLoaded) {
      final currentState = state as MindmapLoaded;
      _nodePositions = Map<String, Offset>.from(currentState.nodePositions);
      _nodePositions[nodeId] = position;
      safeEmit(currentState.copyWith(nodePositions: _nodePositions));
    }
  }

  /// Add a new node to the mindmap using saveMindmap endpoint
  /// Preserves MindmapLoaded state during the operation
  Future<void> addNode({
    required String title,
    required String content,
    required String color,
    required String icon,
    String? parentNodeId,
  }) async {
    print('➕ [MindmapCubit] addNode() called');
    print('📝 Title: "$title", Content: "$content"');
    print('🆔 ParentNodeId: $parentNodeId');
    print(
      '🆔 MindmapId: ${_currentMindmap?.id}, ChapterId: $_currentChapterId',
    );
    print('🔧 Use case available: ${saveMindmapUseCase != null}');

    if (saveMindmapUseCase == null) {
      _showError('Save mindmap functionality not available');
      return;
    }

    if (_currentMindmap == null || _currentMindmap!.id == null) {
      _showError('No mindmap loaded');
      return;
    }

    if (_currentChapterId == null) {
      _showError('No chapter selected');
      return;
    }

    // Validate parentNodeId is provided (required by backend)
    if (parentNodeId == null || parentNodeId.isEmpty) {
      _showError('Parent node is required for new nodes');
      return;
    }

    // Set saving state while preserving mindmap display
    if (state is MindmapLoaded) {
      safeEmit(
        (state as MindmapLoaded).copyWith(isSaving: true, clearErrors: true),
      );
    }

    // Create a NewNodeModel for the backend (without _id, with parentId)
    final newNode = NewNodeModel(
      parentId: parentNodeId,
      title: title,
      content: content,
      color: color,
      icon: icon,
    );

    print('🆕 Creating new node with parentId: $parentNodeId');
    print('📤 Sending new node to server in newNodes array');

    // Call saveMindmap with current nodes and the new node
    final result = await saveMindmapUseCase!(
      mindmapId: _currentMindmap!.id!,
      chapterId: _currentChapterId!,
      nodes: _currentMindmap!.nodes, // Send existing nodes
      newNodes: [newNode], // Send new node to be added
    );

    result.fold(
      (failure) {
        print('❌ [MindmapCubit] addNode failed: ${failure.errMessage}');
        if (state is MindmapLoaded) {
          safeEmit(
            (state as MindmapLoaded).copyWith(
              isSaving: false,
              saveError: failure.errMessage,
            ),
          );
        }
      },
      (updatedMindmap) {
        print('✅ [MindmapCubit] addNode success');
        print(
          '📥 Updated mindmap has ${updatedMindmap.nodes?.length ?? 0} nodes',
        );
        print(
          '🔍 Old mindmap had: ${_currentMindmap?.nodes?.length ?? 0} nodes',
        );
        print('🆔 New mindmap ID: ${updatedMindmap.id}');
        print(
          '🆔 First 3 node IDs: ${updatedMindmap.nodes?.take(3).map((n) => n.id).toList()}',
        );

        _currentMindmap = updatedMindmap;

        // Emit new state with updated mindmap and trigger position recalculation
        safeEmit(
          MindmapLoaded(
            mindmap: updatedMindmap,
            selectedNode: null,
            nodePositions: Map<String, Offset>.from(_nodePositions),
            saveSuccess: true,
            isSaving: false,
          ),
        );
        print(
          '✅ [MindmapCubit] State emitted with ${updatedMindmap.nodes?.length} nodes',
        );
      },
    );
  }

  /// Save the entire mindmap with optional title and nodes update
  /// Preserves MindmapLoaded state during the operation
  Future<void> saveMindmap({String? title, List<NodeModel>? nodes}) async {
    if (saveMindmapUseCase == null) {
      _showError('Save mindmap functionality not available');
      return;
    }

    if (_currentMindmap == null || _currentMindmap!.id == null) {
      _showError('No mindmap loaded');
      return;
    }

    if (_currentChapterId == null) {
      _showError('No chapter selected');
      return;
    }

    // Set saving state while preserving mindmap display
    if (state is MindmapLoaded) {
      safeEmit(
        (state as MindmapLoaded).copyWith(isSaving: true, clearErrors: true),
      );
    }

    final result = await saveMindmapUseCase!(
      mindmapId: _currentMindmap!.id!,
      chapterId: _currentChapterId!,
      title: title,
      nodes: nodes ?? _currentMindmap!.nodes,
    );

    result.fold(
      (failure) {
        if (state is MindmapLoaded) {
          safeEmit(
            (state as MindmapLoaded).copyWith(
              isSaving: false,
              saveError: failure.errMessage,
            ),
          );
        }
      },
      (updatedMindmap) {
        _currentMindmap = updatedMindmap;
        safeEmit(
          MindmapLoaded(
            mindmap: updatedMindmap,
            selectedNode: null,
            nodePositions: _nodePositions,
            saveSuccess: true,
          ),
        );
      },
    );
  }

  /// Generate AI-powered content for a new mindmap node
  /// Preserves MindmapLoaded state during generation
  Future<void> generateSmartNodeContent({
    required String text,
    required String chapterId,
  }) async {
    print('🤖 [MindmapCubit] generateSmartNodeContent() called');
    print('📝 Text: "$text"');
    print('🆔 ChapterId: $chapterId');
    print('🔧 Use case available: ${generateSmartNodeUseCase != null}');

    if (generateSmartNodeUseCase == null) {
      _showAiError('AI generation not available');
      return;
    }

    if (text.length < 10) {
      _showAiError('Text must be at least 10 characters long');
      return;
    }

    // Set generating state while preserving mindmap display
    if (state is MindmapLoaded) {
      safeEmit(
        (state as MindmapLoaded).copyWith(
          isGeneratingAI: true,
          clearGenerated: true,
          clearErrors: true,
        ),
      );
    }

    final result = await generateSmartNodeUseCase!(
      text: text,
      chapterId: chapterId,
    );

    result.fold(
      (failure) {
        if (state is MindmapLoaded) {
          safeEmit(
            (state as MindmapLoaded).copyWith(
              isGeneratingAI: false,
              aiError: failure.errMessage,
            ),
          );
        } else {
          // Fallback for non-MindmapLoaded state
          safeEmit(SmartNodeError(failure.errMessage));
        }
      },
      (response) {
        if (state is MindmapLoaded) {
          safeEmit(
            (state as MindmapLoaded).copyWith(
              isGeneratingAI: false,
              generatedContent: response.generatedContent,
              generatedUserInput: response.userInput,
            ),
          );
        } else {
          // Fallback for non-MindmapLoaded state
          safeEmit(
            SmartNodeGenerated(
              generatedContent: response.generatedContent,
              userInput: response.userInput,
            ),
          );
        }
      },
    );
  }

  /// Clear generated content after it's been used
  void clearGeneratedContent() {
    if (state is MindmapLoaded) {
      safeEmit((state as MindmapLoaded).copyWith(clearGenerated: true));
    }
  }

  /// Clear any errors
  void clearErrors() {
    if (state is MindmapLoaded) {
      safeEmit((state as MindmapLoaded).copyWith(clearErrors: true));
    }
  }

  void _showError(String message) {
    if (state is MindmapLoaded) {
      safeEmit((state as MindmapLoaded).copyWith(saveError: message));
    }
  }

  void _showAiError(String message) {
    if (state is MindmapLoaded) {
      safeEmit((state as MindmapLoaded).copyWith(aiError: message));
    }
  }

  /// Edit an existing node by updating the mindmap
  Future<void> editNode({
    required String nodeId,
    required String title,
    required String content,
    required String color,
    required String icon,
  }) async {
    if (_currentMindmap == null || _currentMindmap!.nodes == null) {
      _showError('No mindmap loaded');
      return;
    }

    // Update the node in the local list
    final updatedNodes = _currentMindmap!.nodes!.map((node) {
      if (node.id == nodeId) {
        return node.copyWith(
          title: title,
          content: content,
          color: color,
          icon: icon,
        );
      }
      return node;
    }).toList();

    // Save the updated mindmap
    await saveMindmap(nodes: updatedNodes);
  }

  /// Delete a node by removing it from the mindmap and saving
  Future<void> deleteNode(String nodeId) async {
    if (_currentMindmap == null || _currentMindmap!.nodes == null) {
      _showError('No mindmap loaded');
      return;
    }

    // Remove the node and update parent references
    final updatedNodes = _currentMindmap!.nodes!
        .where((node) => node.id != nodeId)
        .map((node) {
          // Remove the deleted node from children lists
          if (node.children?.contains(nodeId) ?? false) {
            return node.copyWith(
              children: node.children!.where((id) => id != nodeId).toList(),
            );
          }
          return node;
        })
        .toList();

    // Save the updated mindmap
    await saveMindmap(nodes: updatedNodes);
  }

  void updateZoom(double zoom) {
    if (state is MindmapLoaded) {
      final currentState = state as MindmapLoaded;
      safeEmit(currentState.copyWith(zoomLevel: zoom));
    }
  }

  void reset() {
    _currentMindmap = null;
    _currentChapterId = null;
    _nodePositions = {};
    safeEmit(MindmapInitial());
  }
}
