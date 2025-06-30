import 'package:flutter/material.dart';
import 'dart:math';

// Helper class to hold controllers for each sample's inputs
class LossOfMassSampleControllers {
  final TextEditingController outerDiameterController;
  final TextEditingController avgThicknessController;
  final TextEditingController lengthController;
  final TextEditingController iniWeightController;
  final TextEditingController finWeightController;


  LossOfMassSampleControllers()
      : outerDiameterController = TextEditingController(),
        avgThicknessController = TextEditingController(),
        lengthController = TextEditingController(),
        iniWeightController = TextEditingController(),
        finWeightController = TextEditingController();

  void dispose() {
    outerDiameterController.dispose();
    avgThicknessController.dispose();
    lengthController.dispose();
    iniWeightController.dispose();
    finWeightController.dispose();
  }

  void clear() {
    outerDiameterController.clear();
    avgThicknessController.clear();
    lengthController.clear();
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

class LossOfMassTubularPage extends StatefulWidget {
  const LossOfMassTubularPage({super.key});

  @override
  LossOfMassTubularPageState createState() => LossOfMassTubularPageState();
}

class LossOfMassTubularPageState extends State<LossOfMassTubularPage> {
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
    List<double> allOuterDiameters = [];
    List<double> allAvgThicknesses = [];
    List<double> allLengths = [];
    String? firstErrorMsg;
    List<dynamic> tempPerSampleResults = List.filled(_sampleControllers.length, null, growable: true);


    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String outerDiameterText = controllers.outerDiameterController.text;
      final String avgThicknessText = controllers.avgThicknessController.text;
      final String lengthText = controllers.lengthController.text;
      final String initialWeightText = controllers.iniWeightController.text;
      final String finalWeightText = controllers.finWeightController.text;

      if (outerDiameterText.isEmpty && avgThicknessText.isEmpty && lengthText.isEmpty && initialWeightText.isEmpty && finalWeightText.isEmpty) {
         if (_sampleControllers.length > 1) {
            tempPerSampleResults[i] = "SKIPPED";
            continue;
        } else {
            firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
            break;
        }
      }

      double? outerDiameter = double.tryParse(outerDiameterText);
      double? avgThickness = double.tryParse(avgThicknessText);
      double? length = double.tryParse(lengthText);
      double? initialWeight = double.tryParse(initialWeightText);
      double? finalWeight = double.tryParse(finalWeightText);
      String? errorMsg;

      if (outerDiameter == null) {errorMsg = 'Invalid Outer Diameter (Sample ${i+1}).';}
      else if (avgThickness == null) {errorMsg = 'Invalid Avg. Thickness (Sample ${i+1}).';}
      else if (length == null) {errorMsg = 'Invalid Length (Sample ${i+1}).';}
      else if (initialWeight == null) {errorMsg = 'Invalid Initial Weight (Sample ${i+1}).';}
      else if (finalWeight == null) {errorMsg = 'Invalid Final Weight (Sample ${i+1}).';}
      else if (outerDiameter <= 0) {errorMsg = 'Outer Diameter must be positive (Sample ${i+1}).';}
      else if (avgThickness <= 0) {errorMsg = 'Avg. Thickness must be positive (Sample ${i+1}).';}
      else if (length <= 0) {errorMsg = 'Length must be positive (Sample ${i+1}).';}
      else if (initialWeight < 0) {errorMsg = 'Initial Weight cannot be negative (Sample ${i+1}).';}
      else if (finalWeight < 0) {errorMsg = 'Final Weight cannot be negative (Sample ${i+1}).';}
      else if (finalWeight > initialWeight) {errorMsg = 'Final Weight cannot be greater than Initial Weight (Sample ${i+1}).';}
      else if (avgThickness >= outerDiameter / 2) {errorMsg = 'Avg. Thickness too large for Outer Diameter (Sample ${i+1}).';}


      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        break;
      }

      double weightDiff = initialWeight! - finalWeight!;
      
      final sampleData = SampleCalculationData(
        weightDiff: weightDiff,
        weightDiffNearest: weightDiff.round(),
      );
      
      perSampleData.add(sampleData);
      tempPerSampleResults[i] = sampleData;
      allOuterDiameters.add(outerDiameter!);
      allAvgThicknesses.add(avgThickness!);
      allLengths.add(length!);
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

    // --- MODIFIED: Helper function to calculate median ---
    double calculateMedian(List<double> numbers) {
      if (numbers.isEmpty) return 0;
      numbers.sort();
      int middle = numbers.length ~/ 2;
      if (numbers.length % 2 == 1) {
        return numbers[middle];
      } else {
        return (numbers[middle - 1] + numbers[middle]) / 2.0;
      }
    }

    double medianOuterDiameter = calculateMedian(allOuterDiameters);
    double medianAvgThickness = calculateMedian(allAvgThicknesses);
    double medianLength = calculateMedian(allLengths);
    
    // --- MODIFIED: Use the rounded nearest whole number for median weight diff calculation ---
    List<int> sortedNearestWeightDiffs = perSampleData.map((d) => d.weightDiffNearest).toList();
    sortedNearestWeightDiffs.sort();
    double medianWeightDiff;
    int middle = sortedNearestWeightDiffs.length ~/ 2;
    if (sortedNearestWeightDiffs.length % 2 == 1) {
        medianWeightDiff = sortedNearestWeightDiffs[middle].toDouble();
    } else {
        medianWeightDiff = (sortedNearestWeightDiffs[middle - 1] + sortedNearestWeightDiffs[middle]) / 2.0;
    }

    // --- MODIFIED: Evaporation area now uses median values ---
    double evaporationArea = (2 * pi * (medianOuterDiameter - medianAvgThickness) * (medianLength + medianAvgThickness)) / medianLength;
    double lossOfMass = medianWeightDiff / evaporationArea;

    setState(() {
      _calculatedResults = tempPerSampleResults;
      _overallResults = {
        'Median Outer Diameter': '${medianOuterDiameter.toStringAsFixed(3)} mm',
        'Median Avg. Thickness': '${medianAvgThickness.toStringAsFixed(3)} mm',
        'Median Length': '${medianLength.toStringAsFixed(3)} mm',
        'Median Weight Difference': '${medianWeightDiff.toStringAsFixed(1)} mg',
        'Evaporation Area': '${evaporationArea.toStringAsFixed(3)} cm²',
        'Loss of Mass': '${lossOfMass.toStringAsFixed(3)} mg/cm²',
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
    final resultData = (_showResultTab && index < _calculatedResults.length && _calculatedResults[index] is SampleCalculationData)
        ? _calculatedResults[index] as SampleCalculationData
        : null;

return Center(
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.0,
      color: const Color(0xFFFFEBEB),
      child: Container( // Use a container to set a max width on the content
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
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
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Outer Diameter (mm)', controller: controllers.outerDiameterController)),
                const SizedBox(width: 20.0),
                Expanded(child: _buildTextField(label: 'Avg. Thickness (mm)', controller: controllers.avgThicknessController)),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Length (mm)', controller: controllers.lengthController)),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(child: _buildTextField(label: 'Initial Weight (mg)', controller: controllers.iniWeightController)),
                const SizedBox(width: 20.0),
                Expanded(child: _buildTextField(label: 'Final Weight (mg)', controller: controllers.finWeightController)),
              ],
            ),
            // --- MODIFIED: Display both weight difference results per sample ---
            if (resultData != null) ...[
              const Divider(height: 20, thickness: 1),
              Text(
                'Weight Difference: ${resultData.weightDiff.toStringAsFixed(3)} mg',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Weight Difference (to nearest mg): ${resultData.weightDiffNearest} mg',
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ]
          ],
        ),
      ),
      )
    )
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
      appBar: AppBar(title: const Text('Loss of Mass - Tubular')),
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
