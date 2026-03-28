import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../../../core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArScreen extends ConsumerStatefulWidget {
  final String? productId;
  const ArScreen({super.key, this.productId});

  @override
  ConsumerState<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends ConsumerState<ArScreen> {
  // ------- Platform Specific Controllers -------
  ArCoreController? arCoreController;
  ARKitController? arKitController;

  // Track nodes abstractly
  int _nodeCount = 0;
  final List<String> _nodeNames = [];

  String activeCategory = 'Паркет';
  final List<String> categories = ['Паркет', 'Стеновые Панели', 'Потолок', 'Плинтус', 'Подогрев'];

  String activeTextureId = 'oak';
  final List<Map<String, dynamic>> texturesList = [
    {'id': 'oak', 'name': 'Дуб Нордик', 'colorHex': '0xFFD6B48A', 'pricePerM2': 85.0},
    {'id': 'walnut', 'name': 'Орех Премиум', 'colorHex': '0xFF8B5E3C', 'pricePerM2': 120.0},
    {'id': 'sand', 'name': 'Песок Минимал', 'colorHex': '0xFFF4EBDD', 'pricePerM2': 75.0},
    {'id': 'graphite', 'name': 'Графит', 'colorHex': '0xFF3C3C3C', 'pricePerM2': 90.0},
    {'id': 'moss', 'name': 'Мох Эко', 'colorHex': '0xFF6C7A5A', 'pricePerM2': 95.0},
  ];

  @override
  void dispose() {
    arCoreController?.dispose();
    arKitController?.dispose();
    super.dispose();
  }

  // ------- Android (ARCore) Setup -------
  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController?.onPlaneTap = _handleArCorePlaneTap;
  }

  void _handleArCorePlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isNotEmpty) {
      _placeSurfaceNode(hits.first.pose.translation, hits.first.pose.rotation);
    }
  }

  // ------- iOS (ARKit) Setup -------
  void _onARKitViewCreated(ARKitController controller) {
    arKitController = controller;
    arKitController?.onNodeTap = (nodes) => _handleARKitNodeTap(nodes);
    arKitController?.onPlaneTap = (anchors) => _handleARKitPlaneTap(anchors);
  }

  void _handleARKitNodeTap(List<String> nodes) {}

  void _handleARKitPlaneTap(List<ARKitTestResult> hits) {
    if (hits.isNotEmpty) {
      final transform = hits.first.worldTransform;
      final position = vector.Vector3(transform.getColumn(3).x, transform.getColumn(3).y, transform.getColumn(3).z);
      // Simplify rotation for MVP parity
      final rotation = vector.Vector4(0, 0, 0, 1);
      _placeSurfaceNode(position, rotation);
    }
  }

  // ------- Unified Node Placement -------
  void _placeSurfaceNode(vector.Vector3 position, vector.Vector4 rotation) {
    final textureData = texturesList.firstWhere((t) => t['id'] == activeTextureId);
    final color = Color(int.parse(textureData['colorHex'] as String)).withOpacity(0.85);

    double width = 1.5, height = 0.05, depth = 1.5;
    if (activeCategory == 'Стеновые Панели') { width = 2.0; height = 2.0; depth = 0.1; }
    else if (activeCategory == 'Плинтус') { width = 2.0; height = 0.1; depth = 0.05; }
    else if (activeCategory == 'Потолок') { width = 2.0; height = 0.05; depth = 2.0; }

    final nodeName = 'Node_${DateTime.now().millisecondsSinceEpoch}';

    if (Platform.isAndroid) {
      final material = ArCoreMaterial(color: color, roughness: 0.8);
      final shape = ArCoreCube(materials: [material], size: vector.Vector3(width, height, depth));
      final node = ArCoreNode(name: nodeName, shape: shape, position: position, rotation: rotation);
      arCoreController?.addArCoreNodeWithAnchor(node);
    } else if (Platform.isIOS) {
      final material = ARKitMaterial(diffuse: ARKitMaterialProperty.color(color));
      final shape = ARKitBox(width: width, height: height, length: depth, materials: [material]);
      final node = ARKitNode(name: nodeName, geometry: shape, position: position);
      arKitController?.add(node);
    }

    setState(() {
      _nodeCount++;
      _nodeNames.add(nodeName);
    });
  }

  void _clearAllNodes() {
    if (Platform.isAndroid) {
      for (var name in _nodeNames) {
         arCoreController?.removeNode(nodeName: name);
      }
    } else if (Platform.isIOS) {
      for (var name in _nodeNames) {
         arKitController?.remove(name);
      }
    }
    
    setState(() {
      _nodeCount = 0;
      _nodeNames.clear();
    });
  }

  void _changeCategory(String category) {
    setState(() => activeCategory = category);
  }

  void _changeTexture(String textureId) {
    // Note: To dynamically swap textures of placed nodes, we need 
    // to map their original positions. For MVP ease, we simply alter active ID
    // and subsequent taps will deploy the new texture.
    setState(() => activeTextureId = textureId);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isLocReady = loc != null;
    
    final textureData = texturesList.firstWhere((tex) => tex['id'] == activeTextureId);
    final price = textureData['pricePerM2'] as double;
    final totalAreaM2 = _nodeCount * 2.25; 
    final totalCost = totalAreaM2 * price;
    
    final currencyType = ref.watch(currencyProvider);
    final currencyFormatter = ref.read(currencyProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Platform Dependent AR Core Engine
          if (Platform.isAndroid)
            ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
            )
          else if (Platform.isIOS)
             ARKitSceneView(
              enableTapRecognizer: true,
              planeDetection: ARPlaneDetection.horizontal,
              onARKitViewCreated: _onARKitViewCreated,
            )
          else
             const Center(child: Text('Платформа не поддерживает AR', style: TextStyle(color: Colors.white))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.of(context).pop(), 
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.walnut, width: 1.5),
                      boxShadow: [BoxShadow(color: AppColors.walnut.withOpacity(0.3), blurRadius: 8)]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                           onTap: () => ref.read(currencyProvider.notifier).toggle(),
                           child: Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               Icon(Icons.currency_exchange, color: AppColors.oakLight, size: 14),
                               const SizedBox(width: 4),
                               Text(currencyType == AppCurrency.ils ? '₪ ILS' : '\$ USD', 
                                   style: const TextStyle(color: AppColors.oakLight, fontSize: 11, fontWeight: FontWeight.bold)),
                             ]
                           ),
                        ),
                        const SizedBox(height: 6),
                        Text('${totalAreaM2.toStringAsFixed(1)} м²', 
                           style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${currencyFormatter.format(price)} / м²', 
                           style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(isLocReady ? '${loc.totalLbl}: ${currencyFormatter.format(totalCost)}' : 'ИТОГО: ${currencyFormatter.format(totalCost)}', 
                           style: const TextStyle(color: AppColors.oak, fontSize: 16, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_nodeCount > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 16,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text('Очистить'),
                onPressed: _clearAllNodes,
              ),
            ),

          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
               decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black87, Colors.transparent]),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) {
                        final cat = categories[i];
                        final isActive = cat == activeCategory;
                        return GestureDetector(
                          onTap: () => _changeCategory(cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.walnut : Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isActive ? AppColors.walnut : Colors.white38),
                            ),
                            child: Center(
                              child: Text(cat, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: texturesList.length,
                      itemBuilder: (ctx, i) {
                        final tex = texturesList[i];
                        final isActive = tex['id'] == activeTextureId;
                        return GestureDetector(
                          onTap: () => _changeTexture(tex['id'] as String),
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50, height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(tex['colorHex'] as String)),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: isActive ? Colors.white : Colors.transparent, width: isActive ? 3 : 0),
                                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(tex['name'] as String, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
