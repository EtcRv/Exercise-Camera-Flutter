import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {super.key, required this.updateImagePath, required this.changeScreen});

  final void Function(String image, ColorFilter color) updateImagePath;
  final void Function(String screen) changeScreen;

  @override
  State<CameraScreen> createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  ResolutionPreset resolutionPreset = ResolutionPreset.medium;
  FlashMode flashMode = FlashMode.off;
  double zoomLevel = 1.0;
  double maxZoomLevel = 0.0;
  FocusMode _currentFocusMode = FocusMode.auto;
  // ColorFilter _filterColor = ColorFilter.mode(Colors.white, BlendMode.color);
  String colorSelected = 'manual';
  ColorFilter _filterColor =
      ColorFilter.mode(Colors.transparent, BlendMode.color);

  void updateImage(String image, ColorFilter color) {
    widget.updateImagePath(image, color);
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> getMaxZoom() {
    return controller!.getMaxZoomLevel().then((value) => value);
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();

    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[0], resolutionPreset);
      await controller!.initialize();
      controller!.setFocusMode(_currentFocusMode);
      maxZoomLevel = (await getMaxZoom()) as double;

      setState(() {});
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _buildCameraPreview() {
    if (controller == null || !controller!.value.isInitialized) {
      return Container();
    }

    return AspectRatio(
      aspectRatio: controller!.value.aspectRatio,
      child: CameraPreview(controller!),
    );
  }

  void _updateCameraColor(String color) {
    if (color == "manual") {
      setState(() {
        colorSelected = "manual";
        _filterColor = ColorFilter.mode(Colors.transparent, BlendMode.color);
      });
    } else if (color == "blackWhite") {
      setState(() {
        colorSelected = "blackWhite";
        _filterColor = ColorFilter.mode(Colors.white, BlendMode.color);
      });
    }
  }

  void _toggleFlash() {
    if (flashMode == FlashMode.off) {
      flashMode = FlashMode.torch;
    } else {
      flashMode = FlashMode.off;
    }
    controller!.setFlashMode(flashMode);
    setState(() {});
  }

  void _zoomIn() {
    zoomLevel += 0.1;
    if (zoomLevel > maxZoomLevel) {
      zoomLevel = maxZoomLevel;
    }
    controller!.setZoomLevel(zoomLevel);
    setState(() {});
  }

  void _zoomOut() {
    zoomLevel -= 0.1;
    if (zoomLevel < 1.0) {
      zoomLevel = 1.0;
    }
    controller!.setZoomLevel(zoomLevel);
    setState(() {});
  }

  void _takePicture() async {
    try {
      final image = await controller!.takePicture();
      updateImage(image.path, _filterColor);
      widget.changeScreen("start-screen");
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ColorFiltered(
              colorFilter: _filterColor,
              child: _buildCameraPreview(),
            ),
          ),
          Container(
            color: Colors.black,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: flashMode == FlashMode.torch
                          ? const Icon(Icons.flash_on)
                          : const Icon(Icons.flash_off),
                      onPressed: _toggleFlash,
                      color: Colors.white,
                    ),
                    TextButton(
                      onPressed: () {
                        _updateCameraColor("manual");
                      },
                      child: Text(
                        'Mặc định',
                        style: TextStyle(
                          color: colorSelected == "manual"
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _updateCameraColor("blackWhite");
                      },
                      child: Text(
                        'Đen trắng',
                        style: TextStyle(
                          color: colorSelected == "blackWhite"
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                    // TextButton(
                    //   onPressed: () {
                    //     _updateCameraColor("grey");
                    //   },
                    //   child: Text('Nâu'),
                    // ),
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: _zoomOut,
                      color: Colors.white,
                    ),
                    Text(
                      '${zoomLevel.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: _zoomIn,
                      color: Colors.white,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _takePicture,
                          icon: const Icon(Icons.camera),
                          color: Colors.white,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  controller!.setFocusMode(FocusMode.auto);
                                },
                                child: Text("Focus"),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text("Manual"),
                              ),
                            ]),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
