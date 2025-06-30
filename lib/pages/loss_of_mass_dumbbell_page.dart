import 'package:flutter/material.dart';

// Helper class to hold controllers for each sample's inputs
class LossOfMassSampleControllers {
  final TextEditingController thicknessController;
  final TextEditingController iniWeightController;
  final TextEditingController finWeightController;

  LossOfMassSampleControllers()
      : thicknessController = TextEditingController(),
        iniWeightController = TextEditingController(),
        finWeightController = TextEditingController();

  void dispose() {
    thicknessController.dispose();
    iniWeightController.dispose();
    finWeightController.dispose();
  }

  void clear() {
    thicknessController.clear();
    iniWeightController.clear();
    finWeightController.clear();
  }
}

// Helper class for per-sample calculation data
class SampleCalculationData {
  final double weightDiff;
  final int weightDiffNearest;

  SampleCalculationData({
    required this.weightDiff,
    required this.weightDiffNearest,
  });
}

class LossOfMassDumbbellPage extends StatefulWidget {
  const LossOfMassDumbbellPage({super.key});

  @override
  LossOfMassDumbbellPageState createState() => LossOfMassDumbbellPageState();
}

class LossOfMassDumbbellPageState extends State<LossOfMassDumbbellPage> {
  List<LossOfMassSampleControllers> _sampleControllers = [LossOfMassSampleControllers()];
  List<dynamic> _calculatedResults = [];
  Map<String, String> _overallResults = {};
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 6;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _sampleControllers = [LossOfMassSampleControllers()];
    _calculatedResults = [];
    _overallResults = {};
  }

  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

 void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
            _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            );
        }
      });
    }
  }

  void _addSample() {
    if (_sampleControllers.length < _maxSamples) {
      setState(() {
        _sampleControllers.add(LossOfMassSampleControllers());
        _showResultTab = false;
        _calculationError = null;
        _overallResults = {};
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      });
      Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of $_maxSamples samples reached.')),
      );
    }
  }

  void _removeSample(int index) {
    if (_sampleControllers.length > 1) {
      setState(() {
        _sampleControllers[index].dispose();
        _sampleControllers.removeAt(index);
        _showResultTab = false;
        _calculationError = null;
        _overallResults = {};
        _calculatedResults.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one sample is required.')),
      );
    }
  }

  void _performCalculations() {
    FocusScope.of(context).unfocus();
    setState(() {
      _calculationError = null;
      _overallResults = {};
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _showResultTab = false;
    });
    
    List<SampleCalculationData> perSampleData = [];
    List<double> allThicknesses = [];
    String? firstErrorMsg;
    List<dynamic> tempPerSampleResults = List.filled(_sampleControllers.length, null, growable: true);

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String thicknessText = controllers.thicknessController.text;
      final String initialWeightText = controllers.iniWeightController.text;
      final String finalWeightText = controllers.finWeightController.text;

      if (thicknessText.isEmpty && initialWeightText.isEmpty && finalWeightText.isEmpty) {
         if (_sampleControllers.length > 1) {
            tempPerSampleResults[i] = "SKIPPED";
            continue;
        } else {
            firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
            break;
        }
      }

      double? thickness = double.tryParse(thicknessText);
      double? initialWeight = double.tryParse(initialWeightText);
      double? finalWeight = double.tryParse(finalWeightText);
      String? errorMsg;

      if (thickness == null) {errorMsg = 'Invalid Min. Thickness (Sample ${i+1}).';}
      else if (initialWeight == null) {errorMsg = 'Invalid Initial Weight (Sample ${i+1}).';}
      else if (finalWeight == null) {errorMsg = 'Invalid Final Weight (Sample ${i+1}).';}
      else if (thickness <= 0) {errorMsg = 'Min. Thickness must be positive (Sample ${i+1}).';}
      else if (initialWeight < 0) {errorMsg = 'Initial Weight cannot be negative (Sample ${i+1}).';}
      else if (finalWeight < 0) {errorMsg = 'Final Weight cannot be negative (Sample ${i+1}).';}
      else if (finalWeight > initialWeight) {errorMsg = 'Final Weight cannot be greater than Initial Weight (Sample ${i+1}).';}

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        break;
      }

      double weightDiff = initialWeight! - finalWeight!;
      int weightDiffNearest = weightDiff.round();

      final sampleData = SampleCalculationData(
        weightDiff: weightDiff,
        weightDiffNearest: weightDiffNearest,
      );
      
      perSampleData.add(sampleData);
      tempPerSampleResults[i] = sampleData;
      allThicknesses.add(thickness!);
    }

    if (firstErrorMsg != null) {
        setState(() {
            _calculationError = firstErrorMsg;
            _showResultTab = true;
        });
        return;
    }

    if (perSampleData.isEmpty) {
        setState(() {
            _calculationError = "No valid data entered for calculation.";
            _showResultTab = true;
        });
        return;
    }

    double meanThickness = allThicknesses.reduce((a, b) => a + b) / allThicknesses.length;
    List<int> sortedWeightDiffs = perSampleData.map((d) => d.weightDiffNearest).toList();
    sortedWeightDiffs.sort();
    double medianWeightDiff;
    int middle = sortedWeightDiffs.length ~/ 2;
    if (sortedWeightDiffs.length % 2 == 1) {
        medianWeightDiff = sortedWeightDiffs[middle].toDouble();
    } else {
        medianWeightDiff = (sortedWeightDiffs[middle - 1] + sortedWeightDiffs[middle]) / 2.0;
    }
    double evaporationArea = (1256 + (180 * meanThickness)) / 100;
    double finalResult = medianWeightDiff / evaporationArea;

    setState(() {
      _calculatedResults = tempPerSampleResults;
      _overallResults = {
        'Mean Thickness': '${meanThickness.toStringAsFixed(3)} mm',
        'Median Weight Difference': '${medianWeightDiff.toStringAsFixed(1)} mg',
        'Evaporation Area': '${evaporationArea.toStringAsFixed(3)} cm²',
        'Final Result': '${finalResult.toStringAsFixed(3)} mg/cm²',
      };
      _showResultTab = true;
    });
  }

  void _resetFields() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      _sampleControllers = [LossOfMassSampleControllers()];
      _overallResults = {};
      _calculatedResults = [];
      _calculationError = null;
      _showResultTab = false;
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 14.0),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14.0),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onChanged: (value) => setState(() {
          _showResultTab = false;
          _calculationError = null;
      }),
    );
  }

  Widget _buildSampleInputCard(int index) {
    final controllers = _sampleControllers[index];
    const String firstFieldLabel = 'Min. Thickness (mm)';
    final resultData = (_showResultTab && index < _calculatedResults.length && _calculatedResults[index] is SampleCalculationData)
        ? _calculatedResults[index] as SampleCalculationData
        : null;

    // --- MODIFIED: The Card is now wrapped in Center and its content is constrained ---
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        elevation: 1.0,
        color: const Color(0xFFFFEBEB),
        child: Container( // Use a container to set a max width on the content
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sample ${index + 1}', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                  if (_sampleControllers.length > 1)
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade700),
                      tooltip: 'Remove Sample ${index + 1}',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _removeSample(index),
                    ),
                ],
              ),
              const SizedBox(height: 12.0),
              // This Row now contains a single Expanded TextField, making it centered
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: firstFieldLabel, 
                      controller: controllers.thicknessController
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              // This Row uses Expanded to make the fields share space equally
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: 'Initial Weight (g)', 
                      controller: controllers.iniWeightController
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: _buildTextField(
                      label: 'Final Weight (g)', 
                      controller: controllers.finWeightController
                    ),
                  ),
                ],
              ),
              if (resultData != null) ...[
                const Divider(height: 20, thickness: 1),
                Text(
                  'Weight Difference: ${resultData.weightDiff.toStringAsFixed(3)} g',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nearest Whole Number: ${resultData.weightDiffNearest} g',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    const normalStyle = TextStyle(fontSize: 15, color: Colors.black87);
    final errorStyle = boldStyle.copyWith(color: Colors.red.shade700, fontSize: 16);
    final resultLabelStyle = normalStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
    final resultValueStyle = normalStyle.copyWith(fontSize: 14);

    return Scaffold(
      appBar: AppBar(title: const Text('Loss of Mass - Dumbbell')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sampleControllers.length,
                  itemBuilder: (context, index) {
                    return _buildSampleInputCard(index);
                  },
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                        onPressed: _performCalculations,
                        icon: const Icon(Icons.calculate),
                        label: const Text('Calculate'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            minimumSize: const Size(110, 45))),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                        onPressed: _resetFields,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            minimumSize: const Size(90, 45))),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80),
                     ElevatedButton.icon(
                        onPressed: _addSample,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade300,
                            minimumSize: const Size(90, 45))),
                  ],
                ),
                const SizedBox(height: 30),

                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _calculationError != null ? Colors.red[50] : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _calculationError != null
                                    ? Colors.red.shade300
                                    : Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_calculationError != null)
                                Text(_calculationError!, style: errorStyle)
                              else ...[
                                const Text(
                                  'Overall Test Results',
                                  style: boldStyle
                                ),
                                const SizedBox(height: 8),
                                ..._overallResults.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${entry.key}:', style: resultLabelStyle),
                                        Text(entry.value, style: resultValueStyle),
                                      ],
                                    ),
                                  );
                                })
                              ]
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}