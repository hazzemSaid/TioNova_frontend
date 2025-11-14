import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/data/models/nodeModel.dart';
import 'package:tionova/core/utils/safe_emit.dart';

part 'mindmap_state.dart';

class MindmapCubit extends Cubit<MindmapState> {
  MindmapCubit() : super(MindmapInitial());

  void loadMindmap(Mindmapmodel mindmap) {
    safeEmit(
      MindmapLoaded(mindmap: mindmap, selectedNode: null, nodePositions: {}),
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
      final updatedPositions = Map<String, Offset>.from(
        currentState.nodePositions,
      );
      updatedPositions[nodeId] = position;
      safeEmit(currentState.copyWith(nodePositions: updatedPositions));
    }
  }

  void addNode({
    required String title,
    required String content,
    required String color,
    required String icon,
    String? parentNodeId,
  }) {
    // TODO: Implement add node logic
    // This will be implemented later with backend integration
  }

  void editNode({
    required String nodeId,
    required String title,
    required String content,
    required String color,
    required String icon,
  }) {
    // TODO: Implement edit node logic
    // This will be implemented later with backend integration
  }

  void deleteNode(String nodeId) {
    // TODO: Implement delete node logic
    // This will be implemented later with backend integration
  }

  void updateZoom(double zoom) {
    if (state is MindmapLoaded) {
      final currentState = state as MindmapLoaded;
      safeEmit(currentState.copyWith(zoomLevel: zoom));
    }
  }

  void reset() {
    safeEmit(MindmapInitial());
  }
}
