import 'package:flutter/material.dart';
import 'dart:math'; // Import for pi

// Enum for Ageing Test Types
enum AgeingTestType { tubular, dumbbell }

// Helper class to hold controllers for each sample's inputs
class AgeingSampleControllers {
  // For Dumbbell, diameterController will represent 'Width'
  final TextEditingController diameterController; // mm (or Width for Dumbbell)
  final TextEditingController avgThicknessController; // mm
  final TextEditingController forceController;      // N
  final TextEditingController elongatedController;      // Mm

  AgeingSampleControllers()
      : diameterController = TextEditingController(),
        avgThicknessController = TextEditingController(),
        forceController = TextEditingController(),
        elongatedController = TextEditingController();

  void dispose() {
    diameterController.dispose();
    avgThicknessController.dispose();
    forceController.dispose();
    elongatedController.dispose();
  }

  void clear() {
    diameterController.clear();
    avgThicknessController.clear();
    forceController.clear();
    elongatedController.clear();
  }
}

// --- REVERTED: Using original result classes to hold formatted strings ---
class TubularSampleResults {
  final String area;
  final String tensileStrength;
  final String elongation;

  TubularSampleResults(
      {required this.area,
      required this.tensileStrength,
      required this.elongation});
}

class DumbbellSampleResults {
  final String area;
  final String tensileStrength;
  final String elongation;

  DumbbellSampleResults(
      {required this.area,
      required this.tensileStrength,
      required this.elongation});
}


class AgeingPage extends StatefulWidget {
  const AgeingPage({super.key});

  @override
  AgeingPageState createState() => AgeingPageState();
}

class AgeingPageState extends State<AgeingPage> {
  AgeingTestType _selectedAgeingType = AgeingTestType.tubular;
  List<AgeingSampleControllers> _sampleControllers = [AgeingSampleControllers()];
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 6;
  final ScrollController _scrollController = ScrollController();

  double _selectedOriginalLength = 20.0;
  final List<double> _originalLengthOptions = [10.0, 20.0];


  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _sampleControllers = [AgeingSampleControllers()];
    _calculatedResults = [];
    _selectedOriginalLength = 20.0;
  }

  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onTestTypeChanged(AgeingTestType? newType) {
    if (newType != null && newType != _selectedAgeingType) {
      setState(() {
        _selectedAgeingType = newType;
        _resetFields(resetType: false);
      });
    }
  }

  void _onOriginalLengthChanged(double? newLength) {
    if (newLength != null && newLength != _selectedOriginalLength) {
      setState(() {
        _selectedOriginalLength = newLength;
        _showResultTab = false;
        _calculationError = null;
      });
    }
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
        _sampleControllers.add(AgeingSampleControllers());
        _showResultTab = false;
        _calculationError = null;
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
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _showResultTab = false;
    });
    
    String? firstErrorMsg;
    List<dynamic> tempPerSampleResults = List.filled(_sampleControllers.length, null, growable: true);

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String primaryDimText = controllers.diameterController.text; // Diameter or Width
      final String thicknessText = controllers.avgThicknessController.text;
      final String forceText = controllers.forceController.text;
      final String elongatedText = controllers.elongatedController.text;

      if (primaryDimText.isEmpty && thicknessText.isEmpty && forceText.isEmpty && elongatedText.isEmpty) {
        if (_sampleControllers.length > 1) {
          tempPerSampleResults[i] = "SKIPPED";
          continue;
        } else {
          firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
          break;
        }
      }

      double? primaryDim = double.tryParse(primaryDimText);
      double? thickness = double.tryParse(thicknessText);
      double? force = double.tryParse(forceText);
      double? elongatedMm = double.tryParse(elongatedText);
      String? errorMsg;

      final isTubular = _selectedAgeingType == AgeingTestType.tubular;
      final primaryDimName = isTubular ? 'Diameter' : 'Width';

      if (primaryDim == null) { errorMsg = 'Invalid $primaryDimName (Sample ${i+1}).'; }
      else if (thickness == null) { errorMsg = 'Invalid Avg. Thickness (Sample ${i+1}).'; }
      else if (force == null) { errorMsg = 'Invalid Force (Sample ${i+1}).'; }
      else if (elongatedMm == null) { errorMsg = 'Invalid Elongated (Sample ${i+1}).'; }
      else if (primaryDim <= 0) { errorMsg = '$primaryDimName must be positive (Sample ${i+1}).'; }
      else if (thickness <= 0) { errorMsg = 'Thickness must be positive (Sample ${i+1}).'; }
      else if (force <= 0) { errorMsg = 'Force must be positive (Sample ${i+1}).'; }
      else if (elongatedMm <= 0) { errorMsg = 'Elongated length must be positive (Sample ${i+1}).'; }
      else if (isTubular && thickness >= primaryDim / 2) { errorMsg = 'Avg. Thickness too large for Sample ${i+1}.'; }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        break;
      }

      double area;
      if (isTubular) {
        area = (primaryDim! - thickness!) * thickness * pi;
      } else {
        area = primaryDim! * thickness!;
      }

      if (area <= 0) {
        firstErrorMsg ??= 'Calculated area is invalid for Sample ${i+1}. Check inputs.';
        break;
      }
      
      double tensileStrength = force! / area;
      double elongationPercentage = ((elongatedMm! - _selectedOriginalLength) / _selectedOriginalLength) * 100.0;
      
      if (isTubular) {
        tempPerSampleResults[i] = TubularSampleResults(
          area: '${area.toStringAsFixed(2)} mm²',
          tensileStrength: '${tensileStrength.toStringAsFixed(2)} N/mm²',
          elongation: '${elongationPercentage.toStringAsFixed(0)}%',
        );
      } else {
        tempPerSampleResults[i] = DumbbellSampleResults(
          area: '${area.toStringAsFixed(2)} mm²',
          tensileStrength: '${tensileStrength.toStringAsFixed(2)} N/mm²',
          elongation: '${elongationPercentage.toStringAsFixed(0)}%',
        );
      }
    }

    setState(() {
      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
      } else if (!tempPerSampleResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults)) {
         _calculationError = "No valid data entered for calculation.";
      }
      _calculatedResults = tempPerSampleResults;
      _showResultTab = true;
    });
  }

  void _resetFields({bool resetType = true}) { 
    FocusScope.of(context).unfocus();
    setState(() {
      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      _sampleControllers = [AgeingSampleControllers()];
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _calculationError = null;
      _showResultTab = false;
      _selectedOriginalLength = 20.0;
      if (resetType) {
        _selectedAgeingType = AgeingTestType.tubular;
      }
    });
  }


  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    double? fieldWidth,
  }) {
    return SizedBox(
      width: fieldWidth ?? MediaQuery.of(context).size.width * 0.35,
      child: TextField(
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
      ),
    );
  }

  Widget _buildSampleInputCard(int index) {
    final controllers = _sampleControllers[index];
    String firstFieldLabel = _selectedAgeingType == AgeingTestType.tubular
        ? 'D, Diameter (mm)'
        : 'W, Width (mm)';
    
    String secondFieldLabel = _selectedAgeingType == AgeingTestType.tubular
    ? 'T, Avg. Thick (mm)'
    : 'T, Min. Thick (mm)';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.0,
      color: const Color(0xFFFFEBEB),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildTextField(label: firstFieldLabel, controller: controllers.diameterController)),
                const SizedBox(width: 20.0),
                Expanded(child: _buildTextField(label: secondFieldLabel, controller: controllers.avgThicknessController)),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildTextField(label: 'F, Force (N)', controller: controllers.forceController)),
                const SizedBox(width: 20.0),
                Expanded(child: _buildTextField(label: 'E, Elongated (mm)', controller: controllers.elongatedController)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    const normalStyle = TextStyle(fontSize: 15, color: Colors.black87);
    final errorStyle = boldStyle.copyWith(color: Colors.red.shade700, fontSize: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Tensile Strength & Elongation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: DropdownButtonFormField<AgeingTestType>(
                      decoration: const InputDecoration(
                        labelText: 'Select Ageing Test Type',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      value: _selectedAgeingType,
                      items: AgeingTestType.values.map((AgeingTestType type) {
                        return DropdownMenuItem<AgeingTestType>(
                          value: type,
                          child: Text(type.toString().split('.').last[0].toUpperCase() + type.toString().split('.').last.substring(1)),
                        );
                      }).toList(),
                      onChanged: _onTestTypeChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: DropdownButtonFormField<double>(
                      decoration: const InputDecoration(
                        labelText: 'Select Original Length for Elongation',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      value: _selectedOriginalLength,
                      items: _originalLengthOptions.map((double length) {
                        return DropdownMenuItem<double>(
                          value: length,
                          child: Text('${length.toInt()} mm'),
                        );
                      }).toList(),
                      onChanged: _onOriginalLengthChanged,
                    ),
                  ),
                  
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
                          onPressed: () => _resetFields(resetType: true), 
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
                                  Text(
                                    _selectedAgeingType == AgeingTestType.tubular
                                      ? 'Tubular Test Results:'
                                      : 'Dumbbell Test Results:',
                                    style: boldStyle
                                  ),
                                  const SizedBox(height: 8),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _calculatedResults.length,
                                    itemBuilder: (context, index) {
                                      final result = _calculatedResults[index];
                                      if (result == "SKIPPED") {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                                          child: Text('Sample ${index + 1}: Skipped', style: normalStyle.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                        );
                                      }
                                      if (result is TubularSampleResults) {
                                        return _buildResultRow(
                                          index: index,
                                          area: result.area,
                                          tensile: result.tensileStrength,
                                          elongation: result.elongation,
                                          isTubular: true
                                        );
                                      }
                                      if (result is DumbbellSampleResults) {
                                        return _buildResultRow(
                                          index: index,
                                          area: result.area,
                                          tensile: result.tensileStrength,
                                          elongation: result.elongation,
                                          isTubular: false
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
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
      ),
    );
  }

  // --- NEW: Helper to show formula in a dialog ---
  void _showFormulaDialog(BuildContext context, String title, String formula) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(formula),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // --- NEW: Helper for a single result row with an info icon ---
  Widget _buildFormulaRow({
    required String label,
    required String value,
    required String formula,
  }) {
    final resultLabelStyle = TextStyle(fontSize: 14, color: Colors.black87);
    final resultValueStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                onPressed: () => _showFormulaDialog(context, '$label Formula', formula),
                padding: const EdgeInsets.only(right: 6),
                constraints: const BoxConstraints(),
                splashRadius: 20,
              ),
              Flexible(child: Text('$label:', style: resultLabelStyle, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
        Text(value, style: resultValueStyle),
      ],
    );
  }

  // --- MODIFIED: Uses the new _buildFormulaRow helper ---
  Widget _buildResultRow({
    required int index,
    required String area,
    required String tensile,
    required String elongation,
    required bool isTubular,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sample ${index + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 6),
          _buildFormulaRow(
            label: 'Area',
            value: area,
            formula: isTubular ? 'Area = (Diameter - Thickness) * Thickness * π' : 'Area = Width * Thickness',
          ),
          const SizedBox(height: 4),
          _buildFormulaRow(
            label: 'Tensile Strength',
            value: tensile,
            formula: 'Tensile Strength = Force / Area',
          ),
          const SizedBox(height: 4),
          _buildFormulaRow(
            label: 'Elongation',
            value: elongation,
            formula: 'Elongation = [(Elongated Length - Original Length) / Original Length] * 100',
          ),
          if (index < _calculatedResults.where((r) => r != null && r != "SKIPPED").length - 1)
            const Divider(height: 16, thickness: 0.5),
        ],
      ),
    );
  }
}
