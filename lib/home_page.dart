import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  CameraController? _controller;
  bool _isCameraInitialized = false;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission
    final status = await Permission.camera.request();
    if (status.isDenied) {
      return;
    }

    // Get available cameras
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      return;
    }

    // Initialize the camera with the back camera
    await _initializeCameraAtIndex(0);
  }

  Future<void> _initializeCameraAtIndex(int index) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(_cameras[index], ResolutionPreset.high);

    try {
      await _controller!.initialize();
      setState(() {
        _isCameraInitialized = true;
        _currentCameraIndex = index;
      });
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    int newIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initializeCameraAtIndex(newIndex);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedEye')),
      body:
          _selectedIndex == 0
              ? Stack(
                children: [
                  if (_isCameraInitialized)
                    CameraPreview(_controller!)
                  else
                    const Center(child: CircularProgressIndicator()),
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.cameraswitch, color: Colors.white),
                      onPressed: _switchCamera,
                    ),
                  ),
                ],
              )
              : const Center(child: Text('Home Page')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        ],
      ),
    );
  }
}
