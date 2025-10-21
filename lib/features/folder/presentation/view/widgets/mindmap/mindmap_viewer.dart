import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/features/folder/data/models/mindmapmodel.dart';
import 'package:tionova/features/folder/data/models/nodeModel.dart';
import 'package:tionova/features/folder/presentation/bloc/mindmap/mindmap_cubit.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/add_node_dialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/edit_node_dialog.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/mindmap_controls.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/mindmap_node_widget.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/mindmap_painter.dart';
import 'package:tionova/features/folder/presentation/view/widgets/mindmap/node_content_dialog.dart';

class MindmapViewer extends StatefulWidget {
  final Mindmapmodel mindmap;

  const MindmapViewer({Key? key, required this.mindmap}) : super(key: key);

  @override
  State<MindmapViewer> createState() => _MindmapViewerState();
}

class _MindmapViewerState extends State<MindmapViewer> {
  final TransformationController _transformationController =
      TransformationController();
  double _currentZoom = 1.0;
  Size _canvasSize = const Size(1000, 1000);

  @override
  void initState() {
    super.initState();
    // Initialize mindmap in cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MindmapCubit>().loadMindmap(widget.mindmap);
      _calculateNodePositions();
    });
  }

  Size _calculateCanvasSize(Map<String, Offset> positions) {
    if (positions.isEmpty) {
      return Size(
        MediaQuery.of(context).size.width * 3,
        MediaQuery.of(context).size.height * 3,
      );
    }

    // Find min and max positions
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (var position in positions.values) {
      if (position.dx < minX) minX = position.dx;
      if (position.dx > maxX) maxX = position.dx;
      if (position.dy < minY) minY = position.dy;
      if (position.dy > maxY) maxY = position.dy;
    }

    // Add padding around nodes (400px on each side for comfort)
    const padding = 400.0;
    final width = (maxX - minX) + (padding * 2) + 170; // 170 = node width
    final height = (maxY - minY) + (padding * 2) + 130; // 130 = node height

    // Ensure minimum canvas size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final minWidth = screenWidth * 2;
    final minHeight = screenHeight * 2;

    return Size(math.max(width, minWidth), math.max(height, minHeight));
  }

  Offset _adjustPositionForCanvas(
    Offset position,
    Map<String, Offset> allPositions,
  ) {
    if (allPositions.isEmpty) return position;

    // Find min positions to adjust offset
    double minX = double.infinity;
    double minY = double.infinity;

    for (var pos in allPositions.values) {
      if (pos.dx < minX) minX = pos.dx;
      if (pos.dy < minY) minY = pos.dy;
    }

    // Add padding
    const padding = 400.0;
    return Offset(position.dx - minX + padding, position.dy - minY + padding);
  }

  // Avoid collision with other nodes
  Offset _avoidCollision(
    Offset proposedPosition,
    Map<String, Offset> existingPositions,
    String currentNodeId,
  ) {
    const minDistance =
        220.0; // Minimum distance between node centers (170 node width + 50 margin)
    var adjustedPosition = proposedPosition;

    // Check collision with all existing nodes
    for (var entry in existingPositions.entries) {
      if (entry.key == currentNodeId) continue;

      final distance = _calculateDistance(adjustedPosition, entry.value);

      if (distance < minDistance) {
        // Move the node away from collision
        final angle = math.atan2(
          adjustedPosition.dy - entry.value.dy,
          adjustedPosition.dx - entry.value.dx,
        );

        adjustedPosition = Offset(
          entry.value.dx + minDistance * math.cos(angle),
          entry.value.dy + minDistance * math.sin(angle),
        );
      }
    }

    return adjustedPosition;
  }

  // Calculate distance between two points
  double _calculateDistance(Offset point1, Offset point2) {
    final dx = point1.dx - point2.dx;
    final dy = point1.dy - point2.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  // Center the view on the root node
  void _centerViewOnRoot() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<MindmapCubit>().state;
      if (state is! MindmapLoaded) return;

      // Find root node position
      final nodes = state.mindmap.nodes ?? [];
      try {
        final rootNode = nodes.firstWhere((node) => node.isRoot == true);
        final rootPosition = state.nodePositions[rootNode.id];

        if (rootPosition != null) {
          final screenWidth = MediaQuery.of(context).size.width;
          final screenHeight = MediaQuery.of(context).size.height;

          // Calculate the transformation needed to center the root node
          // Account for AppBar height
          final appBarHeight = AppBar().preferredSize.height;
          final statusBarHeight = MediaQuery.of(context).padding.top;
          final topOffset = appBarHeight + statusBarHeight;

          // Center point on screen (accounting for top offset)
          final screenCenterX = screenWidth / 2;
          final screenCenterY = (screenHeight - topOffset) / 2;

          // Calculate translation to center the root node
          final translationX = screenCenterX - rootPosition.dx;
          final translationY = screenCenterY - rootPosition.dy;

          // Apply transformation
          final matrix = Matrix4.identity()
            ..translate(translationX, translationY);

          _transformationController.value = matrix;
        }
      } catch (e) {
        debugPrint('Error centering view on root: $e');
      }
    });
  }

  void _calculateNodePositions() {
    // Calculate positions for all nodes in a tree layout
    final nodes = widget.mindmap.nodes ?? [];
    if (nodes.isEmpty) return;

    final Map<String, Offset> positions = {};

    try {
      final rootNode = nodes.firstWhere((node) => node.isRoot == true);

      // Center position for root (center of canvas, not screen)
      // Start with a large initial canvas
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final centerX = screenWidth * 2; // Initial center
      final centerY = screenHeight * 2; // Initial center

      positions[rootNode.id!] = Offset(centerX, centerY);

      // Calculate positions for child nodes
      _calculateChildPositions(
        nodes,
        rootNode,
        positions,
        Offset(centerX, centerY),
        0,
      );

      // Calculate dynamic canvas size based on actual node positions
      final canvasSize = _calculateCanvasSize(positions);

      // Adjust all positions to fit within the new canvas with padding
      final adjustedPositions = <String, Offset>{};
      for (var entry in positions.entries) {
        adjustedPositions[entry.key] = _adjustPositionForCanvas(
          entry.value,
          positions,
        );
      }

      // Update canvas size
      setState(() {
        _canvasSize = canvasSize;
      });

      // Update positions in cubit with adjusted positions
      for (var entry in adjustedPositions.entries) {
        context.read<MindmapCubit>().updateNodePosition(entry.key, entry.value);
      }

      // Center the view on root node after positions are calculated
      _centerViewOnRoot();
    } catch (e) {
      debugPrint('Error calculating node positions: $e');
    }
  }

  void _calculateChildPositions(
    List<NodeModel> allNodes,
    NodeModel parentNode,
    Map<String, Offset> positions,
    Offset parentPosition,
    int level,
  ) {
    final children = parentNode.children ?? [];
    if (children.isEmpty) return;

    // Increase radius to prevent overlapping
    // Base radius: 300px, increased by 120px per level
    final radius = 300.0 + (level * 120);
    final angleStep = (2 * math.pi) / children.length;

    for (int i = 0; i < children.length; i++) {
      final childId = children[i];
      try {
        final childNode = allNodes.firstWhere((node) => node.id == childId);

        final angle = angleStep * i;
        var x = parentPosition.dx + radius * math.cos(angle);
        var y = parentPosition.dy + radius * math.sin(angle);

        // Check for collisions with existing nodes and adjust if needed
        var adjustedPosition = _avoidCollision(
          Offset(x, y),
          positions,
          childId,
        );

        positions[childId] = adjustedPosition;

        // Recursively calculate positions for grandchildren
        _calculateChildPositions(
          allNodes,
          childNode,
          positions,
          adjustedPosition,
          level + 1,
        );
      } catch (e) {
        debugPrint('Error finding child node: $childId');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return BlocBuilder<MindmapCubit, MindmapState>(
      builder: (context, state) {
        if (state is! MindmapLoaded) {
          return Scaffold(
            backgroundColor: const Color(0xFF0A0E27),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        final nodes = state.mindmap.nodes ?? [];
        final nodePositions = state.nodePositions;

        return Scaffold(
          backgroundColor: const Color(0xFF0A0E27),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0A0E27),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F3A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hub, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Mind Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isSmallScreen)
                        Text(
                          state.mindmap.title ?? 'Untitled',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              if (!isSmallScreen) ...[
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement AI regenerate
                    },
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('AI Regenerate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2D3250)),
                      backgroundColor: const Color(0xFF1A1F3A),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement save
                    },
                    icon: const Icon(Icons.save, size: 16),
                    label: const Text('Save'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2D3250)),
                      backgroundColor: const Color(0xFF1A1F3A),
                    ),
                  ),
                ),
              ] else ...[
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: const Color(0xFF1A1F3A),
                  onSelected: (value) {
                    if (value == 'regenerate') {
                      // TODO: Implement AI regenerate
                    } else if (value == 'save') {
                      // TODO: Implement save
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'regenerate',
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'AI Regenerate',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.save, color: Colors.white, size: 20),
                          SizedBox(width: 12),
                          Text('Save', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          body: Stack(
            children: [
              // Canvas with nodes and connections
              InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: EdgeInsets.all(screenWidth),
                minScale: 0.3,
                maxScale: 3.0,
                constrained: false,
                onInteractionUpdate: (details) {
                  setState(() {
                    _currentZoom = _transformationController.value
                        .getMaxScaleOnAxis();
                  });
                },
                child: SizedBox(
                  width: _canvasSize.width,
                  height: _canvasSize.height,
                  child: Stack(
                    children: [
                      // Draw connections
                      CustomPaint(
                        size: _canvasSize,
                        painter: MindmapConnectionsPainter(
                          nodes: nodes,
                          nodePositions: nodePositions,
                        ),
                      ),
                      // Draw nodes
                      ...nodes.map((node) {
                        final position = nodePositions[node.id];
                        if (position == null) return const SizedBox.shrink();

                        return Positioned(
                          left: position.dx - 85,
                          top: position.dy - 65,
                          child: Draggable(
                            data: node,
                            feedback: Transform.scale(
                              scale: _currentZoom,
                              child: Opacity(
                                opacity: 0.8,
                                child: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: 170,
                                    height: 130,
                                    child: MindmapNodeWidget(
                                      node: node,
                                      isSelected: true,
                                      onTap: () {},
                                      onEdit: () {},
                                      onAddChild: () {},
                                      onDelete: () {},
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: MindmapNodeWidget(
                                node: node,
                                isSelected: state.selectedNode?.id == node.id,
                                onTap: () {},
                                onEdit: () {},
                                onAddChild: () {},
                                onDelete: () {},
                              ),
                            ),
                            onDragEnd: (details) {
                              // Get the transformation matrix
                              final Matrix4 transform =
                                  _transformationController.value;

                              // Calculate the inverse scale
                              final scale = transform.getMaxScaleOnAxis();

                              // Get the translation from the matrix
                              final translation = transform.getTranslation();

                              // Get AppBar height to adjust for screen coordinates
                              final appBarHeight =
                                  AppBar().preferredSize.height;
                              final statusBarHeight = MediaQuery.of(
                                context,
                              ).padding.top;
                              final topOffset = appBarHeight + statusBarHeight;

                              // Calculate position in canvas space
                              // The formula accounts for: screen position, app bar offset, pan offset, and zoom
                              // Then converts to canvas coordinates
                              final canvasX =
                                  (details.offset.dx - translation.x) / scale;
                              final canvasY =
                                  ((details.offset.dy - topOffset) -
                                      translation.y) /
                                  scale;

                              // Store the center position of the node
                              var newPosition = Offset(
                                canvasX + 85,
                                canvasY + 65,
                              );

                              // Constrain node position within canvas boundaries
                              // Node dimensions: 170x130 (width x height)
                              const nodeWidth = 170.0;
                              const nodeHeight = 130.0;
                              const minPadding =
                                  10.0; // Minimum distance from edge

                              // Clamp X position (left to right boundaries)
                              final minX = minPadding + nodeWidth / 2;
                              final maxX =
                                  _canvasSize.width -
                                  minPadding -
                                  nodeWidth / 2;
                              final clampedX = newPosition.dx.clamp(minX, maxX);

                              // Clamp Y position (top to bottom boundaries)
                              final minY = minPadding + nodeHeight / 2;
                              final maxY =
                                  _canvasSize.height -
                                  minPadding -
                                  nodeHeight / 2;
                              final clampedY = newPosition.dy.clamp(minY, maxY);

                              // Update with clamped position
                              newPosition = Offset(clampedX, clampedY);

                              context.read<MindmapCubit>().updateNodePosition(
                                node.id!,
                                newPosition,
                              );
                            },
                            child: MindmapNodeWidget(
                              node: node,
                              isSelected: state.selectedNode?.id == node.id,
                              onTap: () {
                                _showNodeContentDialog(context, node);
                              },
                              onEdit: () {
                                _showEditNodeDialog(context, node);
                              },
                              onAddChild: () {
                                _showAddNodeDialog(context, node.id);
                              },
                              onDelete: () {
                                // TODO: Implement delete
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              // Controls overlay
              Positioned(
                left: 16,
                top: 16,
                child: MindmapControls(
                  zoomLevel: _currentZoom,
                  onZoomIn: () {
                    setState(() {
                      final newZoom = (_currentZoom * 1.2).clamp(0.5, 2.0);
                      _transformationController.value = Matrix4.identity()
                        ..scale(newZoom);
                      _currentZoom = newZoom;
                    });
                  },
                  onZoomOut: () {
                    setState(() {
                      final newZoom = (_currentZoom / 1.2).clamp(0.5, 2.0);
                      _transformationController.value = Matrix4.identity()
                        ..scale(newZoom);
                      _currentZoom = newZoom;
                    });
                  },
                  onFitToScreen: () {
                    // Reset zoom to 1.0 and center on root node
                    setState(() {
                      _currentZoom = 1.0;
                      _transformationController.value = Matrix4.identity();
                    });
                    // Center view on root node
                    _centerViewOnRoot();
                  },
                ),
              ),

              // Node info overlay - Desktop version
              if (state.selectedNode != null && !isSmallScreen)
                Positioned(
                  right: 16,
                  top: 16,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.3,
                      maxHeight: screenHeight * 0.7,
                    ),
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2D3250)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  state.selectedNode!.icon ?? '📝',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    state.selectedNode!.title ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    context.read<MindmapCubit>().selectNode(
                                      null,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.selectedNode!.content ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Stats overlay
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F3A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2D3250)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Generated',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${nodes.length} Nodes',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: isSmallScreen && state.selectedNode != null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1F3A),
                    border: Border(
                      top: BorderSide(color: const Color(0xFF2D3250)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            state.selectedNode!.icon ?? '📝',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.selectedNode!.title ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              context.read<MindmapCubit>().selectNode(null);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: screenHeight * 0.2,
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            state.selectedNode!.content ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  color: const Color(0xFF0A0E27),
                  child: Text(
                    isSmallScreen
                        ? 'Pinch to zoom • Drag nodes • Tap to view'
                        : 'Scroll to zoom • Drag nodes to move • Click nodes to view • Drag canvas to pan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _showAddNodeDialog(BuildContext context, String? parentNodeId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddNodeDialog(
        parentNodeId: parentNodeId,
        onAdd: (title, content, color, icon) {
          context.read<MindmapCubit>().addNode(
            title: title,
            content: content,
            color: color,
            icon: icon,
            parentNodeId: parentNodeId,
          );
        },
      ),
    );
  }

  void _showEditNodeDialog(BuildContext context, NodeModel node) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditNodeDialog(
        node: node,
        onSave: (title, content, color, icon) {
          context.read<MindmapCubit>().editNode(
            nodeId: node.id!,
            title: title,
            content: content,
            color: color,
            icon: icon,
          );
        },
      ),
    );
  }

  void _showNodeContentDialog(BuildContext context, NodeModel node) {
    showDialog(
      context: context,
      builder: (dialogContext) => NodeContentDialog(
        node: node,
        onEdit: () {
          _showEditNodeDialog(context, node);
        },
        onDelete: () {
          // TODO: Implement delete via API
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Delete functionality coming soon'),
              backgroundColor: Colors.red,
            ),
          );
        },
        onAddSubNode: () {
          _showAddNodeDialog(context, node.id);
        },
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}
