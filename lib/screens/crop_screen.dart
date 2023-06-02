import 'dart:io';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:gallery_saver/gallery_saver.dart';

class CropScreen extends StatefulWidget {
  CropScreen({
    super.key,
    required this.imageData,
    required this.objDetect,
    required this.finishCrop,
    required this.savingFileName,
  });
  var imageData;
  List<ResultObjectDetection?> objDetect;
  void Function() finishCrop;
  String savingFileName;

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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.cut),
            onPressed: () {
              setState(() {
                _isProcessing = true;
              });
              _controller_crop.crop();
            },
          ),
          IconButton(
              onPressed: () async {
                if (_croppedData != null) {
                  File picture = await File(widget.savingFileName).create();
                  picture.writeAsBytesSync(List.from(_croppedData!));
                  GallerySaver.saveImage(picture.path);
                  widget.finishCrop();
                }
              },
              icon: Icon(Icons.check))
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
                  initialArea: Rect.fromLTWH(
                    widget.objDetect[0]!.rect.left * factorX,
                    widget.objDetect[0]!.rect.top * factorY,
                    widget.objDetect[0]!.rect.width * factorX,
                    widget.objDetect[0]!.rect.height * factorY,
                  ),
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
