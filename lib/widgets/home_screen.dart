import 'dart:io';
import 'package:exercise/widgets/camera_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  var activeScreen = 'start-screen';
  String? imagePath;
  ColorFilter filterColor =
      ColorFilter.mode(Colors.transparent, BlendMode.color);

  void changeScreen(String screen) {
    setState(() {
      activeScreen = screen;
    });
  }

  void updateImagePath(String image, ColorFilter color) {
    setState(() {
      imagePath = image;
      filterColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = HomeScreenUI(
      filterColor: filterColor,
      imagePath: imagePath,
      changeScreen: changeScreen,
    );

    if (activeScreen == "start-screen") {
      screenWidget = HomeScreenUI(
        filterColor: filterColor,
        imagePath: imagePath,
        changeScreen: changeScreen,
      );
    }

    if (activeScreen == "camera-screen") {
      screenWidget = CameraScreen(
          updateImagePath: updateImagePath, changeScreen: changeScreen);
    }

    return Scaffold(
      body: screenWidget,
    );
  }
}

class HomeScreenUI extends StatelessWidget {
  HomeScreenUI(
      {super.key,
      required this.imagePath,
      required this.filterColor,
      required this.changeScreen});

  final String? imagePath;
  final void Function(String screen) changeScreen;
  ColorFilter filterColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              child: imagePath != null
                  ? ColorFiltered(
                      colorFilter: filterColor,
                      child: Image.file(
                        File(imagePath!),
                        height: 300,
                      ),
                    )
                  : Text("No image choosen")),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () {
              changeScreen("camera-screen");
            },
            child: Text("Take the picture"),
          ),
          ElevatedButton(
            onPressed: () {
              changeScreen("crop-screen");
            },
            child: Text("Crop the picture"),
          ),
        ],
      ),
    );
  }
}
