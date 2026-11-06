import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    openCamera();
  }

  Future<void> openCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (!mounted) return;

    Navigator.pop(context, image);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}