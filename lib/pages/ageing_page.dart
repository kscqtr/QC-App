import 'package:flutter/material.dart';
import 'dart:math'; // Import for pi

// Enum for Ageing Test Types
enum AgeingTestType { tubular, dumbbell }

// Helper class to hold controllers for each sample's inputs
class AgeingSampleControllers {
  // Controllers for Tubular & Dumbbell
  // For Dumbbell, diameterController will represent 'Width'
  final TextEditingController diameterController; // mm (or Width for Dumbbell)
  final TextEditingController avgThicknessController; // mm
  final TextEditingController forceController;          // N
  final TextEditingController elongatedController;      // cm

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

// Helper class to hold the calculated results for a single sample (Tubular)
class TubularSampleResults {
  final String area;
  final String tensileStrength;
  final String elongation;

  TubularSampleResults(
      {required this.area,
      required this.tensileStrength,
      required this.elongation});

  @override
  String toString() {
    return 'Area: $area, TS: $tensileStrength, Elong: $elongation';
  }
}

// Helper class to hold the calculated results for a single sample (Dumbbell)
class DumbbellSampleResults {
  final String area;
  final String tensileStrength;
  final String elongation;

  DumbbellSampleResults(
      {required this.area,
      required this.tensileStrength,
      required this.elongation});

  @override
  String toString() {
    return 'Area: $area, TS: $tensileStrength, Elong: $elongation';
  }
}

class AgeingPage extends StatefulWidget {
  const AgeingPage({super.key});

  @override
  AgeingPageState createState() => AgeingPageState();
}

class AgeingPageState extends State<AgeingPage> {
  AgeingTestType _selectedAgeingType = AgeingTestType.tubular;
  List<AgeingSampleControllers> _sampleControllers = [AgeingSampleControllers()];
  // Store structured results (TubularSampleResults, DumbbellSampleResults) or "SKIPPED" string
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 6;
  final ScrollController _scrollController = ScrollController(); // Scroll controller for auto-scroll

  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    // Dispose existing controllers if any, before re-initializing
    for (var controllers in _sampleControllers) {
        controllers.dispose();
    }
    _sampleControllers = [AgeingSampleControllers()];
    _calculatedResults =
        List.filled(_sampleControllers.length, null, growable: true);
  }

  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  void _onTestTypeChanged(AgeingTestType? newType) {
    if (newType != null && newType != _selectedAgeingType) {
      setState(() {
        _selectedAgeingType = newType;
        _resetFields(resetType: false); // Reset fields but keep the newly selected type
      });
    }
  }

 void _scrollToBottom() {
    // Ensure the scroll controller has clients and the widget is built.
    if (_scrollController.hasClients) {
      // Using addPostFrameCallback to ensure the scroll happens after the layout pass
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _addSample() {
    if (_sampleControllers.length < _maxSamples) {
      setState(() {
        _sampleControllers.add(AgeingSampleControllers());
        // Ensure _calculatedResults list is extended and initialized with null
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
        _showResultTab = false; // Hide results when inputs change
        _calculationError = null;
      });
      // Scroll to the bottom after the state is updated and widget rebuilds
      // Adding a slight delay to ensure the new item is rendered before scrolling
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
        if (_calculatedResults.length > index) {
          _calculatedResults.removeAt(index);
        }
        // Re-evaluate if results tab should be shown
        bool hasAnyValidResult = _calculatedResults.any((r) => r != null && r != "SKIPPED");
        if (!hasAnyValidResult && _calculationError == null) {
            _showResultTab = false;
        } else {
            // If there was an error related to this specific sample, it might need more complex logic to clear.
            // For now, a general check. If no results and no general error, hide.
            // If an error remains, it will be shown.
             _showResultTab = _calculatedResults.any((r) => r != null) || _calculationError != null;
        }
        if (!_showResultTab) _calculationError = null;
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

    if (_selectedAgeingType == AgeingTestType.tubular) {
      _calculateForTubular();
    } else if (_selectedAgeingType == AgeingTestType.dumbbell) {
      _calculateForDumbbell();
    }
  }

  void _calculateForTubular() {
    List<dynamic> tempResults = List.filled(_sampleControllers.length, null, growable: true);
    String? firstErrorMsg;

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String diameterText = controllers.diameterController.text;
      final String thicknessText = controllers.avgThicknessController.text;
      final String forceText = controllers.forceController.text;
      final String elongatedText = controllers.elongatedController.text;

      if (diameterText.isEmpty && thicknessText.isEmpty && forceText.isEmpty && elongatedText.isEmpty) {
        if (_sampleControllers.length > 1 && (i == 0 || (tempResults.length > i-1 && tempResults[i-1] != null))) {
            tempResults[i] = "SKIPPED";
            continue;
        } else if (_sampleControllers.length == 1) {
            firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
        }
      }

      double? diameter = double.tryParse(diameterText);
      double? thickness = double.tryParse(thicknessText);
      double? force = double.tryParse(forceText);
      double? elongatedCm = double.tryParse(elongatedText);
      String? errorMsg;

      if (diameter == null && diameterText.isNotEmpty) {errorMsg = 'Invalid Diameter (Sample ${i+1}).';}
      else if (thickness == null && thicknessText.isNotEmpty) {errorMsg = 'Invalid Avg. Thickness (Sample ${i+1}).';}
      else if (force == null && forceText.isNotEmpty) {errorMsg = 'Invalid Force (Sample ${i+1}).';}
      else if (elongatedCm == null && elongatedText.isNotEmpty) {errorMsg = 'Invalid Elongated (Sample ${i+1}).';}
      else if (diameterText.isEmpty || thicknessText.isEmpty || forceText.isEmpty || elongatedText.isEmpty) {
        if (tempResults[i] != "SKIPPED") {
            errorMsg = 'All fields required for Sample ${i+1}.';
        }
      }
      else if (diameter != null && thickness != null && force != null && elongatedCm != null) {
        if (diameter <= 0) {errorMsg = 'Diameter must be positive (Sample ${i+1}).';}
        else if (thickness <= 0) {errorMsg = 'Avg. Thickness must be positive (Sample ${i+1}).';}
        else if (thickness >= diameter / 2) {errorMsg = 'Avg. Thickness too large for Sample ${i+1}.';}
        else if (force <= 0) {errorMsg = 'Force must be positive (Sample ${i+1}).';}
        else if (elongatedCm <= 0) {errorMsg = 'Elongated length must be positive (Sample ${i+1}).';}
        // Using 20.0 cm as the original length for elongation calculation
        // else if (elongatedCm < 20.0 && elongatedText.isNotEmpty) { /* Allow negative elongation */ }
      }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        tempResults[i] = null;
      } else if (diameter != null && thickness != null && force != null && elongatedCm != null) {
        double area = (diameter - thickness) * thickness * pi;
        if (area <= 0) {
          firstErrorMsg ??= 'Calculated area is invalid for Sample ${i+1}. Check Diameter and Thickness.';
          tempResults[i] = null;
        } else {
          double tensileStrength = force / area;
          double originalLengthCm = 20.0; // Elongation based on 20mm (2.0cm) marking
          double elongationPercentage = ((elongatedCm - originalLengthCm) / originalLengthCm) * 100.0;
          tempResults[i] = TubularSampleResults(
            area: '${area.toStringAsFixed(2)} mm²',
            tensileStrength: '${tensileStrength.toStringAsFixed(2)} N/mm²',
            elongation: '${elongationPercentage.toStringAsFixed(2)}%',
          );
        }
      } else if (tempResults[i] != "SKIPPED" && (diameterText.isNotEmpty || thicknessText.isNotEmpty || forceText.isNotEmpty || elongatedText.isNotEmpty)) {
        firstErrorMsg ??= 'Incomplete or invalid data for Sample ${i+1}.';
        tempResults[i] = null;
      }
    }

    setState(() {
      _calculatedResults = tempResults;
      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
      }

      bool hasActualCalculations = _calculatedResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults);
      bool hasSkipped = _calculatedResults.any((r) => r == "SKIPPED");

      if (hasActualCalculations || _calculationError != null || hasSkipped) {
        if (!hasActualCalculations && _calculationError == null && hasSkipped) {
          _calculationError = "All valid samples were skipped. No results to display.";
        } else if (!hasActualCalculations && _calculationError == null && !hasSkipped) {
          _calculationError = "No valid data entered for calculation.";
        }
        _showResultTab = true;
      } else {
         _calculationError = "No data to process."; // Should ideally not be reached
        _showResultTab = true; // Show tab to display this message
      }
    });
  }

  void _calculateForDumbbell() {
    List<dynamic> tempResults = List.filled(_sampleControllers.length, null, growable: true);
    String? firstErrorMsg;

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      // For Dumbbell, diameterController holds 'Width'
      final String widthText = controllers.diameterController.text;
      final String thicknessText = controllers.avgThicknessController.text;
      final String forceText = controllers.forceController.text;
      final String elongatedText = controllers.elongatedController.text;

      if (widthText.isEmpty && thicknessText.isEmpty && forceText.isEmpty && elongatedText.isEmpty) {
         if (_sampleControllers.length > 1 && (i == 0 || (tempResults.length > i-1 && tempResults[i-1] != null))) {
            tempResults[i] = "SKIPPED";
            continue;
        } else if (_sampleControllers.length == 1) {
            firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
        }
      }

      double? width = double.tryParse(widthText);
      double? thickness = double.tryParse(thicknessText);
      double? force = double.tryParse(forceText);
      double? elongatedCm = double.tryParse(elongatedText);
      String? errorMsg;

      if (width == null && widthText.isNotEmpty) {errorMsg = 'Invalid Width (Sample ${i+1}).';}
      else if (thickness == null && thicknessText.isNotEmpty) {errorMsg = 'Invalid Avg. Thickness (Sample ${i+1}).';}
      else if (force == null && forceText.isNotEmpty) {errorMsg = 'Invalid Force (Sample ${i+1}).';}
      else if (elongatedCm == null && elongatedText.isNotEmpty) {errorMsg = 'Invalid Elongated (Sample ${i+1}).';}
      else if (widthText.isEmpty || thicknessText.isEmpty || forceText.isEmpty || elongatedText.isEmpty) {
        if (tempResults[i] != "SKIPPED") {
             errorMsg = 'All fields required for Sample ${i+1}.';
        }
      }
      else if (width != null && thickness != null && force != null && elongatedCm != null) {
        if (width <= 0) {errorMsg = 'Width must be positive (Sample ${i+1}).';}
        else if (thickness <= 0) {errorMsg = 'Avg. Thickness must be positive (Sample ${i+1}).';}
        // Add any specific validation for dumbbell, e.g., thickness vs width if necessary
        // else if (thickness >= width) {errorMsg = 'Avg. Thickness cannot be greater than or equal to Width (Sample ${i+1}).';}
        else if (force <= 0) {errorMsg = 'Force must be positive (Sample ${i+1}).';}
        else if (elongatedCm <= 0) {errorMsg = 'Elongated length must be positive (Sample ${i+1}).';}
      }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        tempResults[i] = null;
      } else if (width != null && thickness != null && force != null && elongatedCm != null) {
        // Area = Width * Thickness for Dumbbell
        double area = width * thickness;
        if (area <= 0) { // Additional check for calculated area
            firstErrorMsg ??= 'Calculated area is invalid for Sample ${i+1}. Check Width and Thickness.';
            tempResults[i] = null;
        } else {
            double tensileStrength = force / area;
            double originalLengthCm = 20.0; // Elongation based on 20mm (2.0cm) marking
            double elongationPercentage = ((elongatedCm - originalLengthCm) / originalLengthCm) * 100.0;

            tempResults[i] = DumbbellSampleResults(
                area: '${area.toStringAsFixed(2)} mm²',
                tensileStrength: '${tensileStrength.toStringAsFixed(2)} N/mm²',
                elongation: '${elongationPercentage.toStringAsFixed(2)}%',
            );
        }
      } else if (tempResults[i] != "SKIPPED" && (widthText.isNotEmpty || thicknessText.isNotEmpty || forceText.isNotEmpty || elongatedText.isNotEmpty)) {
        firstErrorMsg ??= 'Incomplete or invalid data for Sample ${i+1}.';
        tempResults[i] = null;
      }
    }

    setState(() {
      _calculatedResults = tempResults;
      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
      }

      bool hasActualCalculations = _calculatedResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults);
      bool hasSkipped = _calculatedResults.any((r) => r == "SKIPPED");

      if (hasActualCalculations || _calculationError != null || hasSkipped) {
        if (!hasActualCalculations && _calculationError == null && hasSkipped) {
          _calculationError = "All valid samples were skipped. No results to display.";
        } else if (!hasActualCalculations && _calculationError == null && !hasSkipped) {
          _calculationError = "No valid data entered for calculation.";
        }
        _showResultTab = true;
      } else {
        _calculationError = "No data to process.";
        _showResultTab = true;
      }
    });
  }

  void _resetFields({bool resetType = true}) { // Added optional param
    FocusScope.of(context).unfocus();
    setState(() {
      // Removed: _selectedAgeingType = AgeingTestType.tubular;
      // This allows the reset button to clear fields for the current type
      // and _onTestTypeChanged to set the type before resetting fields.
      // If resetType is true (e.g. from a global reset button not tied to type change),
      // then we might want to reset the type. For now, type is preserved on reset.
      // If you want the "Reset" button to also reset the type to tubular, add:
      // if (resetType) _selectedAgeingType = AgeingTestType.tubular;

      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      // Re-initialize to one sample
      _sampleControllers = [AgeingSampleControllers()];
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _calculationError = null;
      _showResultTab = false;
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
            _showResultTab = false; // Hide results when input changes
            _calculationError = null; // Clear error when input changes
        }),
      ),
    );
  }

  Widget _buildSampleInputCard(int index) {
    final controllers = _sampleControllers[index];
    String firstFieldLabel = _selectedAgeingType == AgeingTestType.tubular
        ? 'Diameter (mm)'
        : 'Width (mm)';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 1.0,
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
                _buildTextField(label: firstFieldLabel, controller: controllers.diameterController),
                const SizedBox(width: 20.0),
                _buildTextField(label: 'Avg. Thick (mm)', controller: controllers.avgThicknessController),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(label: 'Force (N)', controller: controllers.forceController),
                const SizedBox(width: 20.0),
                _buildTextField(label: 'Elongated (cm)', controller: controllers.elongatedController),
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
    // final resultLabelStyle = normalStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500);
    final resultValueStyle = normalStyle.copyWith(fontSize: 14);
    final noteStyle = TextStyle(fontSize: 13, color: Colors.grey.shade700, fontStyle: FontStyle.italic);


    return Scaffold(
      appBar: AppBar(title: const Text('Tensile Strength & Elongation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Attach scroll controller here
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, // Center the note text
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
                // Added Note Text Widget
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 4.0), // Add some padding
                  child: Text(
                    'Note: Elongation based on 20mm marking',
                    style: noteStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Input fields section - now common for both types
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
                        onPressed: () => _resetFields(resetType: true), // Pass true if reset button should also reset type to default
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            minimumSize: const Size(90, 45))),
                  ],
                ),

                Row( // Add Sample button row
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 80), // For spacing from above buttons
                     ElevatedButton.icon( // "Add Sample" button now always available
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
                            color: _calculationError != null && !(_calculatedResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults))
                                ? Colors.red[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _calculationError != null && !(_calculatedResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults))
                                    ? Colors.red.shade300
                                    : Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_calculationError != null && !(_calculatedResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults)))
                                Text(_calculationError!, style: errorStyle)
                              else ...[
                                Text(
                                  _selectedAgeingType == AgeingTestType.tubular
                                      ? 'Tubular Test Results:'
                                      : 'Dumbbell Test Results:',
                                  style: boldStyle
                                ),
                                if (_calculationError != null) // Show error alongside results if any
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0, bottom: 8.0),
                                    child: Text(_calculationError!, style: errorStyle.copyWith(fontSize: 14)),
                                  ),
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
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Sample ${index + 1}:', style: boldStyle.copyWith(fontSize: 15)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Area: ${result.area}', style: resultValueStyle),
                                                  Text('Tensile Strength: ${result.tensileStrength}', style: resultValueStyle),
                                                  Text('Elongation: ${result.elongation}', style: resultValueStyle),
                                                ],
                                              ),
                                            ),
                                            if (index < _calculatedResults.length -1 && _calculatedResults.skip(index+1).any((r) => r != null && r != "SKIPPED"))
                                              const Divider(height: 10, thickness: 0.5),
                                          ],
                                        ),
                                      );
                                    }
                                    if (result is DumbbellSampleResults) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Sample ${index + 1}:', style: boldStyle.copyWith(fontSize: 15)),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Area: ${result.area}', style: resultValueStyle),
                                                  Text('Tensile Strength: ${result.tensileStrength}', style: resultValueStyle),
                                                  Text('Elongation: ${result.elongation}', style: resultValueStyle),
                                                ],
                                              ),
                                            ),
                                           if (index < _calculatedResults.length -1 && _calculatedResults.skip(index+1).any((r) => r != null && r != "SKIPPED"))
                                              const Divider(height: 10, thickness: 0.5),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink(); // For null results not caught as errors/skipped
                                  },
                                ),
                              ]
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20), // For scroll padding at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}
