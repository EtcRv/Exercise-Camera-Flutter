import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class CropScreen extends StatefulWidget {
  CropScreen({
    super.key,
    required this.imageData,
    required this.objDetect,
    required this.finishCrop,
    required this.savingFileName,
  });
  var imageData;
  void Function() finishCrop;
  String savingFileName;
  List<DetectedObject> objDetect;

  @override
  State<CropScreen> createState() {
    return _CropScreenState();
  }
}

class _CropScreenState extends State<CropScreen> {
  final _controller_crop = CropController();
  Uint8List? _croppedData;
  var _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    print("widget.objects: ${widget.objDetect}");
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.cut),
            onPressed: () async {
              setState(() {
                _isProcessing = true;
              });
              _controller_crop.crop();
              // File picture = await File(widget.savingFileName).create();
              // picture.writeAsBytesSync(List.from(_croppedData!));
              // GallerySaver.saveImage(picture.path);
              // widget.finishCrop();
            },
          ),
        ],
        title: Text(
          'Screen Crop',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double factorX = constraints.maxWidth;
          double factorY = constraints.maxHeight;

          return Visibility(
            visible: !_isProcessing,
            child: Visibility(
                visible: _croppedData == null,
                child: Crop(
                  controller: _controller_crop,
                  image: widget.imageData,
                  onCropped: (image) {
                    setState(
                      () {
                        _croppedData = image;
                        _isProcessing = false;
                      },
                    );
                  },
                  initialArea: widget.objDetect.length != 0
                      ? widget.objDetect[0].boundingBox
                      : Rect.fromLTWH(20, 212, 600, 600),
                ),
                replacement: _croppedData != null
                    ? SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Image.memory(
                          _croppedData!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const SizedBox.shrink()),
            replacement: const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
