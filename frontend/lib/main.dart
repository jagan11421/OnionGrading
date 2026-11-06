
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'camera_page.dart';

void main() {
  runApp(const OnionIQApp());
}

class OnionIQApp extends StatelessWidget {
  const OnionIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onion IQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const InspectionPage(),
    );
  }
}

class InspectionPage extends StatefulWidget {
  const InspectionPage({super.key});

  @override
  State<InspectionPage> createState() => _InspectionPageState();
}

class _InspectionPageState extends State<InspectionPage> {
  // FastAPI backend running on your Ubuntu computer.
  static const String apiUrl = 'http://127.0.0.1:8000';

  final ImagePicker _picker = ImagePicker();

  XFile? selectedImage;
  Uint8List? imageBytes;

  bool isLoading = false;
  String? errorMessage;

  /// Select an image from the gallery or file picker.
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 95,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not select image: $e';
      });
    }
  }

  /// Open the live camera screen and receive its captured image.
  Future<void> captureFromCamera() async {
    try {
      final XFile? image = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
          builder: (_) => const CameraPage(),
        ),
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = image;
        imageBytes = bytes;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not capture image: $e';
      });
    }
  }

  /// Upload the chosen or captured image to the YOLOv8 backend.
  Future<void> inspectImage() async {
    if (selectedImage == null || imageBytes == null) {
      setState(() {
        errorMessage = 'Please select or capture an onion image first.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse('$apiUrl/inspect');

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes!,
          filename: selectedImage!.name,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);

        if (decoded is! Map<String, dynamic>) {
          throw Exception('Unexpected response format from the server.');
        }

        if (!mounted) return;

        final Uint8List capturedBytes = imageBytes!;

        setState(() {
          isLoading = false;
        });

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultsPage(
              imageBytes: capturedBytes,
              result: decoded,
            ),
          ),
        );
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Inspection failed: $e\n\n'
            'Check that your FastAPI backend is running '
            'and accessible at $apiUrl.';
      });
    }
  }

  void clearImage() {
    setState(() {
      selectedImage = null;
      imageBytes = null;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Onion IQ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.eco,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                Text(
                  'Onion Quality Assessment',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select an onion image or capture one with your camera '
                  'to run AI detection.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),

                // Image preview.
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageBytes != null
                      ? Image.memory(
                          imageBytes!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 72,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Your onion image will appear here',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 20),

                // Gallery and camera actions.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : pickImage,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose from Gallery'),
                    ),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : captureFromCamera,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Capture Live Image'),
                    ),
                  ],
                ),

                if (selectedImage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Selected: ${selectedImage!.name}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton.icon(
                    onPressed: isLoading ? null : clearImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove image'),
                  ),
                ],

                const SizedBox(height: 20),

                // Run model inference.
                FilledButton.icon(
                  onPressed: isLoading || imageBytes == null
                      ? null
                      : inspectImage,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.search),
                  label: Text(
                    isLoading ? 'Inspecting Onion...' : 'Inspect Image',
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                if (errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Results screen
// ------------------------------------------------------------

class ResultsPage extends StatelessWidget {
  final Uint8List imageBytes;
  final Map<String, dynamic> result;

  const ResultsPage({
    super.key,
    required this.imageBytes,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final detections = result['detections'] is List
        ? result['detections'] as List
        : <dynamic>[];

    final totalDetections =
        result['total_detections'] ?? detections.length;

    final imageWidth = result['image_width'];
    final imageHeight = result['image_height'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection Results'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  imageBytes,
                  height: 280,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total detections'),
                      const SizedBox(height: 8),
                      Text(
                        '$totalDetections',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                      ),
                      if (imageWidth != null && imageHeight != null) ...[
                        const SizedBox(height: 8),
                        Text('Image size: $imageWidth × $imageHeight'),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Detected onions / objects',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              if (detections.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'No objects were detected in this image.',
                    ),
                  ),
                )
              else
                ...detections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  if (item is! Map) {
                    return const SizedBox.shrink();
                  }

                  final className =
                      item['class_name']?.toString() ?? 'Unknown';

                  final classId = item['class_id']?.toString() ?? '?';

                  final confidence = item['confidence'];

                  final confidenceValue = confidence is num
                      ? confidence.toDouble()
                      : double.tryParse('$confidence') ?? 0.0;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text('Class $className'),
                      subtitle: Text('Class ID: $classId'),
                      trailing: Text(
                        '${(confidenceValue * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 16),
              const Text(
                'Note: A, B, C and D are the labels used by your current '
                'training dataset. Their commercial quality meanings '
                'should be verified before using them as official grades.',
              ),

              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Inspect Another Onion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
