import 'dart:convert';
import 'dart:io';
import 'api_config.dart';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FarmCrop {
  String crop;
  double area;

  FarmCrop({
    required this.crop,
    required this.area,
  });
}

class FarmProfileData {
  static double totalArea = 0;

  static List<FarmCrop> crops = [];
}
void main() {
  runApp(const SmartFarmingApp());
}

class SmartFarmingApp extends StatelessWidget {
  const SmartFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Farming Assistant',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F8A4C),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning 👋',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Smart Farming',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF28552B),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFDDEDD7),
                    child: Icon(
                      Icons.person,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF75A86B),
                      Color(0xFF4F8A4C),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.wb_sunny,
                      color: Colors.white,
                      size: 48,
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            '25°C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Good conditions for farming',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Farm Tools',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF28552B),
                ),
              ),

              const SizedBox(height: 15),

              // Crop Recommendation and Disease Detection
              Row(
                children: [
                  Expanded(
                    child: _featureCard(
                      context,
                      Icons.eco,
                      'Crop\nRecommendation',
                      const Color(0xFFE5F1DF),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CropRecommendationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _featureCard(
                      context,
                      Icons.local_florist,
                      'Disease\nDetection',
                      const Color(0xFFF2EBDC),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DiseaseDetectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Soil Detection and Fertilizer Recommendation
              Row(
                children: [
                  Expanded(
                    child: _featureCard(
                      context,
                      Icons.landscape,
                      'Soil\nDetection',
                      const Color(0xFFE1EDF5),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SoilDetectionScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _featureCard(
                      context,
                      Icons.science,
                      'Fertilizer\nRecommendation',
                      const Color(0xFFE5F1DF),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const FertilizerRecommendationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Smart Irrigation and Weather Forecast
              Row(
                children: [
                  Expanded(
                    child: _featureCard(
                      context,
                      Icons.water_drop,
                      'Smart\nIrrigation',
                      const Color(0xFFE1EFF4),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const SmartIrrigationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _featureCard(
                      context,
                      Icons.cloud,
                      'Weather\nForecast',
                      const Color(0xFFE8E8F3),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const WeatherForecastScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AIFarmingAssistantScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5DD),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFE9D99D),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        color: Color(0xFF806000),
                        size: 35,
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ask AI Farming Assistant',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Get personalized farming guidance.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 17,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Color(0xFFE0A72D),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Monitor your crops regularly for early signs of disease.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AIFarmingAssistantScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FarmProfileScreen(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Assistant',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF3D713D),
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// CROP RECOMMENDATION SCREEN
// ============================================================

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState
    extends State<CropRecommendationScreen> {

  final nController = TextEditingController();
  final pController = TextEditingController();
  final kController = TextEditingController();
  final temperatureController = TextEditingController();
  final humidityController = TextEditingController();
  final phController = TextEditingController();
  final rainfallController = TextEditingController();

  bool loading = false;
  String? recommendedCrop;
  double? confidence;
  String? errorMessage;

  Future<void> getRecommendation() async {
    setState(() {
      loading = true;
      recommendedCrop = null;
      confidence = null;
      errorMessage = null;
    });

    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/predict/crop'
        '?n=${nController.text}'
        '&p=${pController.text}'
        '&k=${kController.text}'
        '&temperature=${temperatureController.text}'
        '&humidity=${humidityController.text}'
        '&ph=${phController.text}'
        '&rainfall=${rainfallController.text}',
      );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          recommendedCrop = data['recommended_crop'];
          confidence = data['confidence'];
          loading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Unable to get crop recommendation.';
          loading = false;
        });
      }
   
    } catch (e) {
      debugPrint('Crop recommendation error: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Crop recommendation failed: $e';
        loading = false;
      });
    }
  }


  Widget inputField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crop Recommendation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7FAF4),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              'Enter Soil & Weather Details',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28552B),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Provide the conditions of your field to find the most suitable crop.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 22),

            inputField('Nitrogen (N)', nController),
            inputField('Phosphorus (P)', pController),
            inputField('Potassium (K)', kController),
            inputField('Temperature (°C)', temperatureController),
            inputField('Humidity (%)', humidityController),
            inputField('Soil pH', phController),
            inputField('Rainfall (mm)', rainfallController),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : getRecommendation,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.eco),
                label: Text(
                  loading
                      ? 'Analyzing...'
                      : 'Recommend Crop',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8A4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (recommendedCrop != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1DF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 45,
                      color: Color(0xFF3D713D),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Recommended Crop',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      recommendedCrop!.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28552B),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Confidence: ${(confidence! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

            if (errorMessage != null)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nController.dispose();
    pController.dispose();
    kController.dispose();
    temperatureController.dispose();
    humidityController.dispose();
    phController.dispose();
    rainfallController.dispose();
    super.dispose();
  }
}


// ============================================================
// DISEASE DETECTION SCREEN
// ============================================================


class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() =>
      _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState
    extends State<DiseaseDetectionScreen> {
  final ImagePicker picker = ImagePicker();

  // Store image bytes for both Web and Android.
  Uint8List? selectedImageBytes;
  String? selectedFileName;

  bool loading = false;

  String? disease;
  String? crop;
  double? confidence;
  String? errorMessage;

  Future<void> selectImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImageBytes = bytes;
        selectedFileName = image.name;
        disease = null;
        crop = null;
        confidence = null;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Unable to select image: $e';
      });
    }
  }

  Future<void> detectDisease() async {
    if (selectedImageBytes == null) {
      setState(() {
        errorMessage = 'Please select a plant image first.';
      });
      return;
    }

    setState(() {
      loading = true;
      disease = null;
      crop = null;
      confidence = null;
      errorMessage = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/predict/disease'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          selectedImageBytes!,
          filename: selectedFileName ?? 'plant_image.jpg',
        ),
      );

      final response = await request.send();
      final responseBody =
          await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);

        setState(() {
          disease = data['disease']?.toString();
          crop = data['crop']?.toString();
          confidence =
              (data['confidence'] as num).toDouble();
          loading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Disease detection failed '
              '(${response.statusCode}).\n$responseBody';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Could not connect to the farming server.\n'
            'Check that FastAPI is running.\n$e';
        loading = false;
      });
    }
  }

  String formatDisease(String value) {
    return value
        .replaceAll('___', ' - ')
        .replaceAll('_', ' ');
  }

  String getRecommendation() {
    if (disease == null) return '';

    final lowerDisease = disease!.toLowerCase();

    if (lowerDisease.contains('healthy')) {
      return 'The plant appears healthy. Continue regular '
          'monitoring, proper watering and balanced nutrition.';
    }

    if (lowerDisease.contains('early blight')) {
      return 'Remove affected leaves, avoid overhead watering, '
          'improve air circulation and monitor the plant regularly.';
    }

    if (lowerDisease.contains('late blight')) {
      return 'Remove infected plant material, keep foliage dry '
          'and consult a local agricultural expert for treatment.';
    }

    if (lowerDisease.contains('common rust')) {
      return 'Remove severely affected leaves and maintain good '
          'air circulation. Monitor nearby plants for symptoms.';
    }

    if (lowerDisease.contains('northern leaf blight')) {
      return 'Remove heavily affected plant material and maintain '
          'good field sanitation. Consider crop rotation.';
    }

    return 'Monitor the plant closely and consult a local '
        'agricultural expert for confirmation and treatment advice.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      appBar: AppBar(
        title: const Text(
          'Disease Detection',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7FAF4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check Your Plant',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28552B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a clear image of a plant leaf to identify '
              'possible diseases.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 25),

            // Image preview: works on Web and Android.
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFDCE7D8),
                ),
              ),
              child: selectedImageBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 65,
                          color: Color(0xFF8BA88A),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No image selected',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.memory(
                        selectedImageBytes!,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Unable to display this image.',
                            ),
                          );
                        },
                      ),
                    ),
            ),

            if (selectedFileName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Selected: $selectedFileName',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Image selection buttons.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : () => selectImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: loading
                        ? null
                        : () => selectImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Detect button.
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: loading ? null : detectDisease,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  loading ? 'Analyzing Image...' : 'Detect Disease',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8A4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            if (errorMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],

            if (disease != null) ...[
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4E5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF3D713D),
                          size: 28,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Detection Result',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Crop',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      crop ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Detected Condition',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDisease(disease!),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28552B),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      confidence == null
                          ? 'Confidence unavailable'
                          : 'Confidence: '
                              '${(confidence! * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      'Recommended Action',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      getRecommendation(),
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currently Supported',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '🌽 Corn\n🥔 Potato\n🍅 Tomato',
                    style: TextStyle(
                      height: 1.7,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'For best results, use a clear image of the '
                    'affected leaf.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// WEATHER FORECAST SCREEN
// ============================================================

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() =>
      _WeatherForecastScreenState();
}

class _WeatherForecastScreenState
    extends State<WeatherForecastScreen> {
  bool loading = true;
  String? errorMessage;

  double? temperature;
  double? humidity;
  double? apparentTemperature;
  double? precipitation;
  double? windSpeed;

  List<String> dates = [];
  List<dynamic> maxTemperature = [];
  List<dynamic> minTemperature = [];
  List<dynamic> rainfall = [];
  List<dynamic> et0 = [];

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // Pune coordinates for testing.
      // Later we can replace these with the farmer's GPS location.
      const latitude = 18.52;
      const longitude = 73.85;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/weather'
        '?latitude=$latitude'
        '&longitude=$longitude',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          temperature =
              (data['current']['temperature'] as num).toDouble();

          humidity =
              (data['current']['humidity'] as num).toDouble();

          apparentTemperature =
              (data['current']['apparent_temperature'] as num)
                  .toDouble();

          precipitation =
              (data['current']['precipitation'] as num).toDouble();

          windSpeed =
              (data['current']['wind_speed'] as num).toDouble();

          dates = List<String>.from(
            data['forecast']['dates'],
          );

          maxTemperature =
              List<dynamic>.from(
            data['forecast']['max_temperature'],
          );

          minTemperature =
              List<dynamic>.from(
            data['forecast']['min_temperature'],
          );

          rainfall =
              List<dynamic>.from(
            data['forecast']['precipitation'],
          );

          et0 =
              List<dynamic>.from(
            data['forecast']['reference_et0'],
          );

          loading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Unable to get weather information.';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Could not connect to the farming server.\n'
            'Make sure FastAPI is running.';
        loading = false;
      });
    }
  }

  Widget weatherInfoCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF4F8A4C),
            size: 30,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather Forecast',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF7FAF4),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F8A4C),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: getWeather,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: getWeather,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Weather',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28552B),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient:
                                const LinearGradient(
                              colors: [
                                Color(0xFF75A86B),
                                Color(0xFF4F8A4C),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.wb_sunny,
                                color: Colors.white,
                                size: 55,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${temperature!.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Feels like ${apparentTemperature!.toStringAsFixed(1)}°C',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: weatherInfoCard(
                                Icons.water_drop,
                                'Humidity',
                                '${humidity!.toStringAsFixed(0)}%',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: weatherInfoCard(
                                Icons.air,
                                'Wind',
                                '${windSpeed!.toStringAsFixed(1)} km/h',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: weatherInfoCard(
                                Icons.water,
                                'Rainfall',
                                '${precipitation!.toStringAsFixed(1)} mm',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: weatherInfoCard(
                                Icons.opacity,
                                'ET₀',
                                '${et0[0]} mm/day',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          '7-Day Forecast',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF28552B),
                          ),
                        ),

                        const SizedBox(height: 15),

                        ...List.generate(
                          dates.length,
                          (index) {
                            return Container(
                              margin:
                                  const EdgeInsets.only(
                                      bottom: 10),
                              padding:
                                  const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dates[index],
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${maxTemperature[index]}° / ${minTemperature[index]}°C',
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    '${rainfall[index]} mm rain',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'ET₀ is the reference evapotranspiration used by Smart Irrigation to estimate crop water requirements.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// ============================================================
// SMART IRRIGATION SCREEN
// ============================================================


class SmartIrrigationScreen extends StatefulWidget {
  const SmartIrrigationScreen({super.key});

  @override
  State<SmartIrrigationScreen> createState() =>
      _SmartIrrigationScreenState();
}

class _SmartIrrigationScreenState
    extends State<SmartIrrigationScreen> {
  final areaController = TextEditingController();

  String? selectedCrop;

  bool loading = false;

  double? waterLiters;
  double? cropWaterRequirement;
  double? rainfall;
  double? et0;
  double? netIrrigation;
  double? grossIrrigation;

  String? message;
  String? date;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Automatically select the first crop
    // from the farmer's farm profile.
    if (FarmProfileData.crops.isNotEmpty) {
      selectedCrop = FarmProfileData.crops.first.crop;

      areaController.text =
          FarmProfileData.crops.first.area.toString();
    }
  }

  void selectCrop(String? crop) {
    if (crop == null) return;

    final selectedFarmCrop =
        FarmProfileData.crops.firstWhere(
      (farmCrop) => farmCrop.crop == crop,
    );

    setState(() {
      selectedCrop = crop;

      // Automatically fill the area
      // stored for that crop.
      areaController.text =
          selectedFarmCrop.area.toString();

      // Clear previous result.
      waterLiters = null;
      cropWaterRequirement = null;
      rainfall = null;
      et0 = null;
      netIrrigation = null;
      grossIrrigation = null;
      message = null;
      date = null;
      errorMessage = null;
    });
  }

  Future<void> calculateIrrigation() async {
    if (FarmProfileData.crops.isEmpty) {
      setState(() {
        errorMessage =
            'Please add at least one crop in My Farm first.';
      });
      return;
    }

    if (selectedCrop == null) {
      setState(() {
        errorMessage = 'Please select a crop first.';
      });
      return;
    }

    if (areaController.text.trim().isEmpty) {
      setState(() {
        errorMessage = 'Please enter your farm area.';
      });
      return;
    }

    final area = double.tryParse(
      areaController.text.trim(),
    );

    if (area == null || area <= 0) {
      setState(() {
        errorMessage =
            'Please enter a valid farm area greater than 0.';
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;

      waterLiters = null;
      cropWaterRequirement = null;
      rainfall = null;
      et0 = null;
      netIrrigation = null;
      grossIrrigation = null;
      message = null;
      date = null;
    });

    try {
      // Pune coordinates for testing.
      // Later we can replace these with GPS coordinates.
      const latitude = 18.52;
      const longitude = 73.85;

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/irrigation/auto'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&crop=$selectedCrop'
        '&area=$area',
      );

      final response = await http.post(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          waterLiters =
              (data['recommended_water_liters'] as num?)
                  ?.toDouble();

          cropWaterRequirement =
              (data['crop_water_requirement_mm'] as num?)
                  ?.toDouble();

          rainfall =
              (data['rainfall_mm'] as num?)?.toDouble();

          et0 =
              (data['et0_mm_per_day'] as num?)?.toDouble();

          netIrrigation =
              (data['net_irrigation_requirement_mm'] as num?)
                  ?.toDouble();

          grossIrrigation =
              (data['gross_irrigation_requirement_mm'] as num?)
                  ?.toDouble();

          message = data['message'];
          date = data['date'];

          loading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Unable to calculate irrigation.\n'
              'Server returned status ${response.statusCode}.';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Could not connect to the farming server.\n'
            'Make sure FastAPI is running.';
        loading = false;
      });
    }
  }

  Widget resultCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4F8A4C),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCrops =
        FarmProfileData.crops.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),

      appBar: AppBar(
        title: const Text(
          'Smart Irrigation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF7FAF4),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'Optimize Water Usage 💧',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF28552B),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Get a daily irrigation recommendation using '
              'weather conditions and your crop.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 25),

            // ------------------------------------------------
            // NO CROPS MESSAGE
            // ------------------------------------------------

            if (!hasCrops)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5DD),
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE9D99D),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.agriculture,
                      size: 42,
                      color: Color(0xFF806000),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'No crops added',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Please add your crops and their areas '
                      'in My Farm before using Smart Irrigation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

            // ------------------------------------------------
            // CROP SELECTION
            // ------------------------------------------------

            if (hasCrops) ...[
              const Text(
                'Select Crop',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 15,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child:
                    DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCrop,
                    isExpanded: true,

                    items:
                        FarmProfileData.crops.map(
                      (farmCrop) {
                        return DropdownMenuItem<
                            String>(
                          value: farmCrop.crop,
                          child: Text(
                            '${farmCrop.crop[0].toUpperCase()}'
                            '${farmCrop.crop.substring(1)} '
                            '(${farmCrop.area.toStringAsFixed(0)} m²)',
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: selectCrop,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ------------------------------------------------
              // FARM AREA
              // ------------------------------------------------

              const Text(
                'Farm Area (m²)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: areaController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),

                decoration: InputDecoration(
                  hintText: 'Area',
                  filled: true,
                  fillColor: Colors.white,

                  suffixText: 'm²',

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------
              // CALCULATE BUTTON
              // ------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed:
                      loading
                          ? null
                          : calculateIrrigation,

                  icon: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.water_drop,
                        ),

                  label: Text(
                    loading
                        ? 'Calculating...'
                        : 'Calculate Irrigation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF4F8A4C),
                    foregroundColor:
                        Colors.white,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // ERROR
              // ------------------------------------------------

              if (errorMessage != null) ...[
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFFFE8E8),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),

                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ],

              // ------------------------------------------------
              // RESULTS
              // ------------------------------------------------

              if (waterLiters != null) ...[
                const SizedBox(height: 28),

                const Text(
                  'Irrigation Recommendation',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Main water recommendation
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFE8F1E5),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [
                      const Icon(
                        Icons.water_drop,
                        size: 45,
                        color:
                            Color(0xFF4F8A4C),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Recommended Water',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        '${waterLiters!.toStringAsFixed(0)} L/day',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF28552B),
                        ),
                      ),

                      if (date != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          date!,
                          style:
                              const TextStyle(
                            color:
                                Colors.black54,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                resultCard(
                  'ET₀',
                  '${et0?.toStringAsFixed(2) ?? '-'} mm/day',
                  Icons.wb_sunny_outlined,
                ),

                const SizedBox(height: 10),

                resultCard(
                  'Crop Water Requirement',
                  '${cropWaterRequirement?.toStringAsFixed(2) ?? '-'} mm/day',
                  Icons.grass,
                ),

                const SizedBox(height: 10),

                resultCard(
                  'Rainfall',
                  '${rainfall?.toStringAsFixed(2) ?? '-'} mm',
                  Icons.cloud_outlined,
                ),

                const SizedBox(height: 10),

                resultCard(
                  'Net Irrigation Requirement',
                  '${netIrrigation?.toStringAsFixed(2) ?? '-'} mm',
                  Icons.water_drop_outlined,
                ),

                const SizedBox(height: 10),

                resultCard(
                  'Gross Irrigation Requirement',
                  '${grossIrrigation?.toStringAsFixed(2) ?? '-'} mm',
                  Icons.opacity,
                ),

                if (message != null) ...[
                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color:
                          const Color(0xFFFFF5DD),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Icon(
                          Icons.info_outline,
                          color:
                              Color(0xFF806000),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            message!,
                            style:
                                const TextStyle(
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    areaController.dispose();
    super.dispose();
  }
}

// ============================================================
// AI FARMING ASSISTANT SCREEN
// ============================================================

class AIFarmingAssistantScreen extends StatefulWidget {
  const AIFarmingAssistantScreen({super.key});

  @override
  State<AIFarmingAssistantScreen> createState() =>
      _AIFarmingAssistantScreenState();
}

class _AIFarmingAssistantScreenState
    extends State<AIFarmingAssistantScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final List<Map<String, String>> messages = [];

  bool loading = false;
  String? selectedCrop;

  
static String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://127.0.0.1:8000';
  }

  return 'http://10.0.2.2:8000';
}


  // Load the farmer's saved crops when the screen opens.
  @override
  void initState() {
    super.initState();

    if (FarmProfileData.crops.isNotEmpty) {
      selectedCrop = FarmProfileData.crops.first.crop;
    }
  }

  // Find the selected crop in the farm profile.
  FarmCrop? get selectedFarmCrop {
    for (final farmCrop in FarmProfileData.crops) {
      if (farmCrop.crop == selectedCrop) {
        return farmCrop;
      }
    }
    return null;
  }

  // Change the crop used for AI advice.
  void changeCrop(String? crop) {
    if (crop == null) return;

    setState(() {
      selectedCrop = crop;
    });
  }

  // Send the question and selected farm details to FastAPI.
  Future<void> sendMessage() async {
    final message = messageController.text.trim();

    if (message.isEmpty || loading) return;

    if (FarmProfileData.crops.isEmpty) {
      setState(() {
        messages.add({
          'sender': 'assistant',
          'message':
              'No crops found in your farm profile. '
              'Please open Profile > My Farm and add a crop first.',
        });
      });
      return;
    }

    // If the saved crops changed, select an available crop.
    FarmCrop? farmCrop = selectedFarmCrop;

    if (farmCrop == null) {
      farmCrop = FarmProfileData.crops.first;
      selectedCrop = farmCrop.crop;
    }

    final cropName = farmCrop.crop;
    final cropArea = farmCrop.area;

    setState(() {
      messages.add({
        'sender': 'user',
        'message': message,
      });
      loading = true;
    });

    messageController.clear();
    _scrollToBottom();

    try {
      // Pune coordinates for now. Farm location can be added later.
      const latitude = 18.52;
      const longitude = 73.85;

      final uri = Uri.parse(
        '$apiBaseUrl/assistant/context-chat',
      ).replace(
        queryParameters: {
          'message': message,
          'crop': cropName,
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'area': cropArea.toString(),
        },
      );

      final response = await http.post(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final assistantResponse =
            data['response']?.toString() ??
                'No response received from the assistant.';

        setState(() {
          messages.add({
            'sender': 'assistant',
            'message': assistantResponse,
          });
        });
      } else {
        setState(() {
          messages.add({
            'sender': 'assistant',
            'message':
                'Sorry, the farming assistant could not '
                'process your question (HTTP '
                '${response.statusCode}). Please try again.',
          });
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        messages.add({
          'sender': 'assistant',
          'message':
              'Could not connect to the farming server.\n'
              'Please make sure FastAPI is running.',
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
        _scrollToBottom();
      }
    }
  }

  // Keep the latest chat message visible.
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget messageBubble(
    String message,
    bool isUser,
  ) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.80,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF4F8A4C)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isUser
              ? null
              : Border.all(color: Colors.black12),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser
                ? Colors.white
                : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmCrops = FarmProfileData.crops;
    final currentFarmCrop = selectedFarmCrop;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        title: const Text(
          'AI Farming Assistant',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF4F8A4C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Crop selector and saved area.
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.agriculture,
                        color: Color(0xFF4F8A4C),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Your farm context',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (farmCrops.isEmpty) ...[
                    const Text(
                      'No crops added yet. Add crops in '
                      'Profile > My Farm to get personalized advice.',
                      style: TextStyle(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'Choose a crop',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),

                    DropdownButtonFormField<String>(
                      value: farmCrops.any(
                        (crop) => crop.crop == selectedCrop,
                      )
                          ? selectedCrop
                          : farmCrops.first.crop,
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.grass,
                          color: Color(0xFF4F8A4C),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: farmCrops.map((crop) {
                        return DropdownMenuItem<String>(
                          value: crop.crop,
                          child: Text(
                            crop.crop[0].toUpperCase() +
                                crop.crop.substring(1),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: loading ? null : changeCrop,
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3E7),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.landscape,
                            color: Color(0xFF4F8A4C),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Selected crop area: '
                              '${currentFarmCrop?.area.toStringAsFixed(1) ?? farmCrops.first.area.toStringAsFixed(1)} m²',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF315C30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Advice will use this crop, its saved area, '
                      'and current weather information.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Chat history.
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.smart_toy_outlined,
                              size: 60,
                              color: Color(0xFF4F8A4C),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'How can I help your farm?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ask about crop care, irrigation, '
                              'weather, pests, or farming practices.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                'How often should I water my crop?',
                                'How can I improve crop growth?',
                                'How can I prevent pests?',
                              ].map((suggestion) {
                                return ActionChip(
                                  label: Text(suggestion),
                                  onPressed: loading
                                      ? null
                                      : () {
                                          messageController.text =
                                              suggestion;
                                          sendMessage();
                                        },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: messages.length +
                          (loading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= messages.length) {
                          return const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4F8A4C),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Thinking...'),
                                ],
                              ),
                            ),
                          );
                        }

                        final item = messages[index];
                        final isUser =
                            item['sender'] == 'user';

                        return messageBubble(
                          item['message'] ?? '',
                          isUser,
                        );
                      },
                    ),
            ),

            // Message input.
            Container(
              padding: const EdgeInsets.fromLTRB(
                12, 10, 12, 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.black12,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      enabled: !loading,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization:
                          TextCapitalization.sentences,
                      onSubmitted: (_) => sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Ask a farming question...',
                        filled: true,
                        fillColor:
                            const Color(0xFFF5F7F1),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4F8A4C),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: loading
                          ? null
                          : sendMessage,
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      tooltip: 'Send message',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

class FarmProfileScreen extends StatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  State<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends State<FarmProfileScreen> {
  final TextEditingController totalAreaController =
      TextEditingController();

  final TextEditingController cropAreaController =
      TextEditingController();

  String selectedCrop = 'tomato';

  final List<String> crops = [
    'tomato',
    'potato',
    'maize',
    'rice',
    'wheat',
    'cotton',
    'sugarcane',
    'banana',
    'apple',
    'blackgram',
    'chickpea',
    'coconut',
    'coffee',
    'grapes',
    'jute',
    'kidneybeans',
    'lentil',
    'mango',
    'mothbeans',
    'mungbean',
    'muskmelon',
    'orange',
    'papaya',
    'pigeonpeas',
    'pomegranate',
    'watermelon',
  ];

  @override
  void initState() {
    super.initState();

    if (FarmProfileData.totalArea > 0) {
      totalAreaController.text =
          FarmProfileData.totalArea.toString();
    }
  }

  void addCrop() {
    final area = double.tryParse(cropAreaController.text);

    if (area == null || area <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid crop area.'),
        ),
      );
      return;
    }

    final totalArea =
        double.tryParse(totalAreaController.text);

    if (totalArea == null || totalArea <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your total farm area first.'),
        ),
      );
      return;
    }

    final alreadyUsed = FarmProfileData.crops.fold<double>(
      0,
      (sum, crop) => sum + crop.area,
    );

    if (alreadyUsed + area > totalArea) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Crop area exceeds your available farm area. '
            'Remaining: ${(totalArea - alreadyUsed).toStringAsFixed(1)} m²',
          ),
        ),
      );
      return;
    }

    final existingIndex = FarmProfileData.crops.indexWhere(
      (crop) => crop.crop == selectedCrop,
    );

    setState(() {
      if (existingIndex >= 0) {
        FarmProfileData.crops[existingIndex].area = area;
      } else {
        FarmProfileData.crops.add(
          FarmCrop(
            crop: selectedCrop,
            area: area,
          ),
        );
      }

      FarmProfileData.totalArea = totalArea;
      cropAreaController.clear();
    });
  }

  void deleteCrop(int index) {
    setState(() {
      FarmProfileData.crops.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final usedArea = FarmProfileData.crops.fold<double>(
      0,
      (sum, crop) => sum + crop.area,
    );

    final totalArea =
        double.tryParse(totalAreaController.text) ?? 0;

    final remainingArea = totalArea - usedArea;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6EF),
      appBar: AppBar(
        title: const Text(
          'My Farm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF8F6EF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Farm information card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1E5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.agriculture,
                        color: Color(0xFF4F8A4C),
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Farm Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Total Farm Area (m²)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: totalAreaController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Example: 2000',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (_) {
                      setState(() {});
                    },
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Used: ${usedArea.toStringAsFixed(1)} m²',
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        'Remaining: ${remainingArea < 0 ? 0 : remainingArea.toStringAsFixed(1)} m²',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Add Crop',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Crop dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedCrop,
              decoration: InputDecoration(
                labelText: 'Select Crop',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: crops.map((crop) {
                return DropdownMenuItem(
                  value: crop,
                  child: Text(
                    crop[0].toUpperCase() +
                        crop.substring(1),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCrop = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            // Crop area
            TextField(
              controller: cropAreaController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Crop Area (m²)',
                hintText: 'Example: 800',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: addCrop,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Crop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8A4C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'My Crops',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            if (FarmProfileData.crops.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 45,
                      color: Color(0xFF8AA986),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No crops added yet.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Add the crops you are currently growing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

            ...FarmProfileData.crops.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final farmCrop = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1E5),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.grass,
                          color: Color(0xFF4F8A4C),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmCrop.crop[0].toUpperCase() +
                                  farmCrop.crop.substring(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${farmCrop.area.toStringAsFixed(1)} m²',
                              style: const TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => deleteCrop(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    totalAreaController.dispose();
    cropAreaController.dispose();
    super.dispose();
  }
}


class FertilizerRecommendationScreen extends StatefulWidget {
  const FertilizerRecommendationScreen({super.key});

  @override
  State<FertilizerRecommendationScreen> createState() =>
      _FertilizerRecommendationScreenState();
}

class _FertilizerRecommendationScreenState
    extends State<FertilizerRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();

  final temperatureController = TextEditingController();
  final humidityController = TextEditingController();
  final moistureController = TextEditingController();
  final nitrogenController = TextEditingController();
  final potassiumController = TextEditingController();
  final phosphorusController = TextEditingController();

  String? selectedCrop;
  bool loading = false;
  String? fertilizerName;
  String? errorMessage;

  String? get soilType => SoilDetectionData.soilType;

  @override
  void initState() {
    super.initState();

    if (FarmProfileData.crops.isNotEmpty) {
      selectedCrop = FarmProfileData.crops.first.crop;
    }
  }

  @override
  void dispose() {
    temperatureController.dispose();
    humidityController.dispose();
    moistureController.dispose();
    nitrogenController.dispose();
    potassiumController.dispose();
    phosphorusController.dispose();
    super.dispose();
  }

  Widget numberField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          final number = double.tryParse(value?.trim() ?? '');

          if (number == null || !number.isFinite) {
            return 'Enter a valid number';
          }

          return null;
        },
      ),
    );
  }

  Future<void> recommendFertilizer() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCrop == null ||
        !FarmProfileData.crops.any(
          (crop) => crop.crop == selectedCrop,
        )) {
      setState(() {
        errorMessage = 'Please add and select a crop in My Farm.';
      });
      return;
    }

    if (soilType == null || soilType!.trim().isEmpty) {
      setState(() {
        errorMessage =
            'Please detect your soil type before continuing.';
      });
      return;
    }

    setState(() {
      loading = true;
      fertilizerName = null;
      errorMessage = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/recommend/fertilizer'
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'temperature':
                  double.parse(temperatureController.text),
              'humidity': double.parse(humidityController.text),
              'moisture': double.parse(moistureController.text),
              'soil_type': soilType,
              'crop_type': selectedCrop,
              'nitrogen': double.parse(nitrogenController.text),
              'potassium': double.parse(potassiumController.text),
              'phosphorus':
                  double.parse(phosphorusController.text),
            }),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(
          data is Map
              ? data['detail']?.toString() ?? 'Request failed'
              : 'Request failed',
        );
      }

      if (!mounted) return;

      setState(() {
        fertilizerName = data['fertilizer_name']?.toString();
        if (fertilizerName == null) {
          errorMessage = 'No fertilizer prediction was returned.';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not get recommendation: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmCrops = FarmProfileData.crops;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F2),
      appBar: AppBar(
        title: const Text('Fertilizer Recommendation'),
        backgroundColor: const Color(0xFFE1EDF5),
        foregroundColor: const Color(0xFF263B32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Farm and Soil Details',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              if (farmCrops.isEmpty)
                const Text(
                  'No crops found. Add a crop in My Farm first.',
                  style: TextStyle(color: Colors.red),
                )
              else
                DropdownButtonFormField<String>(
                  value: farmCrops.any(
                    (crop) => crop.crop == selectedCrop,
                  )
                      ? selectedCrop
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Select crop from My Farm',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: farmCrops.map((crop) {
                    return DropdownMenuItem<String>(
                      value: crop.crop,
                      child: Text(
                        '${crop.crop[0].toUpperCase()}'
                        '${crop.crop.substring(1)} '
                        '(${crop.area.toStringAsFixed(0)} m²)',
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCrop = value;
                    });
                  },
                ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.landscape,
                      color: Color(0xFF376B50),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        soilType == null
                            ? 'Soil not detected yet'
                            : 'Detected soil: $soilType',
                      ),
                    ),
                    if (soilType == null)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SoilDetectionScreen(),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: const Text('Detect'),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Environmental Conditions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              numberField('Temperature (°C)', temperatureController),
              numberField('Humidity (%)', humidityController),
              numberField('Soil moisture (%)', moistureController),

              const Text(
                'Soil Nutrients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Enter values in the same units and scale used by '
                'your training dataset. Prefer measured soil-test '
                'values over guesses.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),

              numberField('Nitrogen (N)', nitrogenController),
              numberField('Potassium (K)', potassiumController),
              numberField('Phosphorus (P)', phosphorusController),

              const SizedBox(height: 8),

              
ElevatedButton.icon(
  onPressed: loading
      ? null
      : () {
          debugPrint('Recommend Fertilizer button tapped');

          if (!_formKey.currentState!.validate()) {
            setState(() {
              errorMessage = 'Please correct the highlighted fields.';
            });
            return;
          }

          if (FarmProfileData.crops.isEmpty) {
            setState(() {
              errorMessage = 'Please add a crop in My Farm first.';
            });
            return;
          }

          if (selectedCrop == null) {
            setState(() {
              errorMessage = 'Please select a crop.';
            });
            return;
          }

          if (soilType == null || soilType!.trim().isEmpty) {
            setState(() {
              errorMessage = 'Please detect your soil type first.';
            });
            return;
          }

          recommendFertilizer();
        },
  icon: loading
      ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : const Icon(Icons.eco),
  label: Text(
    loading ? 'Generating recommendation...' : 'Recommend Fertilizer',
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF376B50),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 15),
  ),
),

              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],

              if (fertilizerName != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F1DF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 34,
                        color: Color(0xFF376B50),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Predicted Fertilizer',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fertilizerName!,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF28543B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This is a prediction from a small training '
                        'dataset, not a verified fertilizer dose. '
                        'Confirm suitability and application rate '
                        'with a soil test and local agricultural '
                        'guidance. No quantity has been calculated.',
                        style: TextStyle(height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


class SoilDetectionData {
  static String? soilType;
}

class SoilDetectionScreen extends StatefulWidget {
  const SoilDetectionScreen({super.key});

  @override
  State<SoilDetectionScreen> createState() =>
      _SoilDetectionScreenState();
}

class _SoilDetectionScreenState
    extends State<SoilDetectionScreen> {
  final ImagePicker _picker = ImagePicker();

  // Store image bytes for compatibility with Web and Android.
  Uint8List? _imageBytes;
  String? _imageName;

  bool _loading = false;
  String? _soilType;
  double? _confidence;
  String? _error;

  // Select an image using the camera or gallery.
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
        _soilType = null;
        _confidence = null;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not select the image: $e';
      });
    }
  }

  // Upload the image to the FastAPI soil prediction endpoint.
  Future<void> _detectSoil() async {
    if (_imageBytes == null) {
      setState(() {
        _error = 'Please select a soil photo first.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _soilType = null;
      _confidence = null;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/predict/soil'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          _imageBytes!,
          filename: _imageName ?? 'soil_image.jpg',
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      debugPrint('Soil API status: ${response.statusCode}');
      debugPrint('Soil API response: ${response.body}');

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = null;
      }

      if (response.statusCode != 200) {
        final detail = data is Map
            ? data['detail']?.toString()
            : null;

        throw Exception(
          'HTTP ${response.statusCode}: '
          '${detail ?? response.body}',
        );
      }

      if (!mounted) return;

      setState(() {
        _soilType = data is Map
            ? data['soil_type']?.toString()
            : null;

        final confidenceValue = data is Map
            ? data['confidence']
            : null;

        _confidence = confidenceValue is num
            ? confidenceValue.toDouble()
            : null;

        SoilDetectionData.soilType = _soilType;

        if (_soilType == null) {
          _error =
              'The API response did not contain a soil type.';
        }
      });
    } catch (e) {
      debugPrint('Soil detection error: $e');

      if (!mounted) return;

      setState(() {
        _error =
            'Soil detection failed: $e\n'
            'Check that the farming server is running.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // Prepare general guidance for the predicted soil category.
  Map<String, dynamic> _soilReportFor(String soilType) {
    final type = soilType.toLowerCase();

    if (type.contains('alluvial')) {
      return {
        'characteristics':
            'Alluvial soil is formed from deposited sediments. '
            'It is often productive, but its nutrient content and '
            'drainage vary by location.',
        'crops': [
          'Wheat',
          'Rice (where water is suitable)',
          'Maize',
          'Sugarcane',
          'Pulses',
        ],
        'tips': [
          'Use a soil test to check nutrient availability.',
          'Add compost or well-decomposed organic matter when needed.',
          'Maintain suitable drainage and avoid excessive irrigation.',
        ],
      };
    } else if (type.contains('black')) {
      return {
        'characteristics':
            'Black soil is generally clay-rich and can retain '
            'moisture well. It may become sticky when wet and '
            'develop cracks during dry periods.',
        'crops': [
          'Cotton',
          'Soybean',
          'Sorghum (jowar)',
          'Pulses',
        ],
        'tips': [
          'Avoid working the soil when it is excessively wet.',
          'Prevent waterlogging through suitable drainage.',
          'Use soil-test results to guide fertilizer application.',
        ],
      };
    } else if (type.contains('clay')) {
      return {
        'characteristics':
            'Clay soil contains fine particles and usually retains '
            'water and nutrients well. Poor drainage and compaction '
            'can restrict root growth.',
        'crops': [
          'Rice (where water and climate are suitable)',
          'Wheat, where drainage permits',
          'Selected pulses suited to local conditions',
        ],
        'tips': [
          'Improve drainage where water remains standing.',
          'Avoid compacting wet soil with heavy machinery.',
          'Add organic matter to support soil structure.',
        ],
      };
    } else if (type.contains('red')) {
      return {
        'characteristics':
            'Red soil gets its colour mainly from iron oxides. '
            'Its fertility and water-holding capacity vary, and '
            'some red soils are low in organic matter.',
        'crops': [
          'Groundnut',
          'Millets',
          'Pulses',
          'Selected varieties of cotton',
        ],
        'tips': [
          'Add compost or other suitable organic matter.',
          'Use mulch to reduce moisture loss and erosion.',
          'Check soil pH and nutrients before applying fertilizers.',
        ],
      };
    }

    return {
      'characteristics':
          'The image model identified a soil category, but its '
          'properties should be confirmed with a soil test.',
      'crops': [
        'Choose crops based on local climate and soil test results.',
      ],
      'tips': [
        'Test soil pH and nutrient levels.',
        'Maintain organic matter and suitable drainage.',
      ],
    };
  }

  // Build a section of the soil health report.
  Widget _reportSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28543B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Build a bulleted list in the soil health report.
  Widget _reportListSection(
    String title,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF28543B),
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Display the soil health report.
  Widget _buildSoilHealthReport() {
    final report = _soilReportFor(_soilType!);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCE5DA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco,
                color: Color(0xFF376B50),
                size: 28,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Soil Health Report',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28543B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Report for $_soilType',
            style: const TextStyle(fontSize: 14),
          ),
          _reportSection(
            'Soil characteristics',
            report['characteristics'] as String,
          ),
          _reportListSection(
            'Potentially suitable crops',
            List<String>.from(report['crops'] as List),
          ),
          _reportListSection(
            'Soil improvement tips',
            List<String>.from(report['tips'] as List),
          ),
          _reportSection(
            'Recommended next step',
            'Get a laboratory soil test for pH, nitrogen, '
            'phosphorus, potassium and other relevant nutrients '
            'before deciding fertilizer doses or making precise '
            'crop suitability decisions.',
          ),
          const SizedBox(height: 12),
          const Text(
            'Note: This report uses visual soil classification '
            'and general agricultural guidance. It does not '
            'measure actual soil fertility or nutrient levels.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F2),
      appBar: AppBar(
        title: const Text('Soil Detection'),
        backgroundColor: const Color(0xFFE1EDF5),
        foregroundColor: const Color(0xFF263B32),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Understand Your Soil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF263B32),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a clear photo of your soil to estimate '
              'its visual category.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 20),

            // Cross-platform image preview.
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFDCE5DA),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _imageBytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.landscape,
                          size: 70,
                          color: Color(0xFF789080),
                        ),
                        SizedBox(height: 12),
                        Text('Your soil photo will appear here'),
                      ],
                    )
                  : Image.memory(
                      _imageBytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 240,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Center(
                          child: Text(
                            'Unable to display this image.',
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Camera and gallery controls.
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Run soil classification.
            ElevatedButton.icon(
              onPressed: _loading ? null : _detectSoil,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(
                _loading ? 'Analyzing soil...' : 'Detect Soil',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF376B50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                  height: 1.4,
                ),
              ),
            ],

            // Prediction result.
            if (_soilType != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F1DF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted Soil Category',
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _soilType!,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF28543B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_confidence != null)
                      Text(
                        'Model confidence: '
                        '${_confidence!.toStringAsFixed(2)}%',
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 14),
                    const Text(
                      'This is a visual estimate. Soil testing '
                      'is needed to determine pH, NPK nutrients, '
                      'and fertilizer dosage.',
                    ),
                  ],
                ),
              ),
            ],

            if (_soilType != null) ...[
              const SizedBox(height: 18),
              _buildSoilHealthReport(),
            ],
          ],
        ),
      ),
    );
  }
}
