// ageing_page.dart
import 'package:flutter/material.dart';
// import 'dart:math'; // Not strictly needed for this version

// Enum for Ageing Test Types
enum AgeingTestType { tubular, dumbbell }

// Helper class to hold controllers for each sample's inputs
// For now, this is tailored for Tubular. It will need adjustment for Dumbbell.
class AgeingSampleControllers {
  final TextEditingController diameterController;
  final TextEditingController avgThicknessController;
  final TextEditingController forceController;
  final TextEditingController elongatedController;


  AgeingSampleControllers({bool isTubular = true}) // Default to tubular for now
      : 
        diameterController = TextEditingController(),
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

class AgeingPage extends StatefulWidget {
  const AgeingPage({super.key});

  @override
  AgeingPageState createState() => AgeingPageState();
}

class AgeingPageState extends State<AgeingPage> {
  // State variable for selected test type
  AgeingTestType _selectedAgeingType = AgeingTestType.tubular; // Default to Tubular

  // List to manage controllers for each sample
  List<AgeingSampleControllers> _sampleControllers = [AgeingSampleControllers()]; // Start with one sample

  // State variables for results
  // For Tubular: List of percentage changes
  // For Dumbbell: This will need to be a list of more complex result objects
  List<String?> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 6;

  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    // Based on the selected type, initialize controllers and results
    // For now, it's always Tubular-like initialization
    _sampleControllers = [AgeingSampleControllers(isTubular: _selectedAgeingType == AgeingTestType.tubular)];
    _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
  }


  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    super.dispose();
  }

  void _onTestTypeChanged(AgeingTestType? newType) {
    if (newType != null) {
      setState(() {
        _selectedAgeingType = newType;
        _resetFields(); // Reset when type changes to ensure clean state
      });
    }
  }

  void _addSample() {
    if (_sampleControllers.length < _maxSamples) {
      setState(() {
        _sampleControllers.add(AgeingSampleControllers(isTubular: _selectedAgeingType == AgeingTestType.tubular));
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
        _showResultTab = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 6 samples reached.')),
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
        _showResultTab = false;
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
      // Placeholder for Dumbbell calculation
      setState(() {
        _calculationError = "Dumbbell calculations are not yet implemented.";
        _showResultTab = true;
      });
    }
  }

  void _calculateForTubular() {
    List<String?> tempResults = List.filled(_sampleControllers.length, null, growable: true);
    bool allInputsValid = true;
    String? firstErrorMsg;

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String initialText = controllers.diameterController.text;
      final String finalText = controllers.avgThicknessController.text;

      // Skip empty sample if it's not the only one and previous ones were processed
      if (initialText.isEmpty && finalText.isEmpty) {
        if (_sampleControllers.length > 1 && (i == 0 || tempResults[i-1] != null || tempResults[i-1] == "SKIPPED")) {
             tempResults[i] = "SKIPPED";
             continue;
        } else if (_sampleControllers.length == 1) { // If it's the only sample and it's empty
            firstErrorMsg ??= 'Please enter data for at least one sample.';
            allInputsValid = false;
            break;
        }
      }


      double? initialReading = double.tryParse(initialText);
      double? finalReading = double.tryParse(finalText);

      String? errorMsg;
      if (initialReading == null) {
        errorMsg = 'Invalid Initial Reading for Sample ${i + 1}.';
      } else if (finalReading == null) {
        errorMsg = 'Invalid Final Reading for Sample ${i + 1}.';
      } else if (initialReading == 0) {
        errorMsg = 'Initial Reading for Sample ${i + 1} cannot be zero.';
      }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg; // Store only the first error
        allInputsValid = false;
        tempResults[i] = null;
        // Don't break here, let's evaluate all samples for errors or skipped status
      } else if (initialReading != null && finalReading != null) { // Ensure both are non-null
        double percentageChange = ((finalReading - initialReading) / initialReading) * 100.0;
        tempResults[i] = '${percentageChange.toStringAsFixed(2)} %';
      }
    }

    setState(() {
      _calculatedResults = tempResults;
      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
      }

      // Determine if results tab should be shown
      bool hasActualData = _calculatedResults.any((res) => res != null && res != "SKIPPED");
      if (hasActualData || _calculationError != null) {
          if(!hasActualData && _calculationError == null) { // All skipped, no errors
            _calculationError = "All samples were skipped or empty.";
          }
        _showResultTab = true;
      } else {
        _calculationError = "No data entered for calculation."; // Default message if nothing to show
        _showResultTab = true;
      }
    });
  }


  void _resetFields() {
    FocusScope.of(context).unfocus();
    setState(() {
      // _selectedAgeingType remains as is, or reset it if needed:
      _selectedAgeingType = AgeingTestType.tubular;
      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      _initializeSamplesAndResults(); // Re-initialize based on current (or default) type
      _calculationError = null;
      _showResultTab = false;
    });
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    double fieldWidth = 150,
  }) {
    return SizedBox(
      width: fieldWidth,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), // Allow negative for change
        style: const TextStyle(fontSize: 15.0),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 15.0),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        onChanged: (value) => setState(() => _showResultTab = false),
      ),
    );
  }

  Widget _buildSampleInputCard(int index) {
    final controllers = _sampleControllers[index];
    // This card is for Tubular type. Dumbbell will have a different card structure.
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
                Text('Sample ${index + 1}', style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
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
            // Inputs for Tubular
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField(
                  label: 'Diameter (mm)',
                  controller: controllers.diameterController,
                ),

                const SizedBox(height: 12.0),
                                
                _buildTextField(
                  label: 'Average Thickness (mm)',
                  controller: controllers.avgThicknessController,
                ),
                _buildTextField(
                  label: 'Force (N)',
                  controller: controllers.forceController,
                ),
                _buildTextField(
                  label: 'Elongated (cm)',
                  controller: controllers.elongatedController,
                )
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
      appBar: AppBar(title: const Text('Tensile Strength & Elongation (Ageing)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Test Type Dropdown ---
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
                        child: Text(type.toString().split('.').last[0].toUpperCase() + type.toString().split('.').last.substring(1)), // "Tubular" or "Dumbbell"
                      );
                    }).toList(),
                    onChanged: _onTestTypeChanged,
                  ),
                ),
                const SizedBox(height: 10),

                // --- Conditional Input Section ---
                if (_selectedAgeingType == AgeingTestType.tubular)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sampleControllers.length,
                    itemBuilder: (context, index) {
                      return _buildSampleInputCard(index); // Shows Tubular inputs
                    },
                  )
                else if (_selectedAgeingType == AgeingTestType.dumbbell)
                  Container( // Placeholder for Dumbbell
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!)
                    ),
                    child: const Center(
                      child: Text(
                        'Dumbbell test inputs and calculations will be implemented here.',
                        style: TextStyle(fontSize: 15, color: Colors.grey, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Action Buttons
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
                            minimumSize: const Size(120, 45))),
                    const SizedBox(width: 10),
                    // Only show Add sample if a type that uses samples is selected
                    if (_selectedAgeingType == AgeingTestType.tubular) // Or other types that use samples
                      ElevatedButton.icon(
                          onPressed: _addSample,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey.shade300,
                              minimumSize: const Size(100, 45))),
                    if (_selectedAgeingType == AgeingTestType.tubular) const SizedBox(width: 10),
                    ElevatedButton.icon(
                        onPressed: _resetFields,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[400],
                            minimumSize: const Size(100, 45))),
                  ],
                ),
                const SizedBox(height: 30),

                // Result Section
                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _calculationError != null && (_selectedAgeingType == AgeingTestType.dumbbell || _calculatedResults.every((r) => r == null || r == "SKIPPED"))
                                ? Colors.red[50]
                                : Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: _calculationError != null && (_selectedAgeingType == AgeingTestType.dumbbell || _calculatedResults.every((r) => r == null || r == "SKIPPED"))
                                    ? Colors.red.shade300
                                    : Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show error prominently if it's the only thing to show OR if it's a dumbbell placeholder error
                              if (_calculationError != null && (_selectedAgeingType == AgeingTestType.dumbbell || _calculatedResults.every((r) => r == null || r == "SKIPPED")))
                                Text(_calculationError!, style: errorStyle)
                              // Else, show results (and error if it coexists with some results)
                              else ...[
                                Text(
                                  _selectedAgeingType == AgeingTestType.tubular ? 'Tubular Test Results:' : 'Results:',
                                  style: boldStyle
                                ),
                                const SizedBox(height: 5),
                                if (_calculationError != null) // Show non-blocking error if present
                                   Padding(
                                     padding: const EdgeInsets.only(bottom: 8.0),
                                     child: Text(_calculationError!, style: errorStyle.copyWith(fontSize: 14)),
                                   ),
                                if (_selectedAgeingType == AgeingTestType.tubular)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _calculatedResults.length,
                                    itemBuilder: (context, index) {
                                      final resultString = _calculatedResults[index];
                                      if (resultString == null && _sampleControllers[index].diameterController.text.isEmpty && _sampleControllers[index].avgThicknessController.text.isEmpty) {
                                        // Don't show anything for truly empty, uncalculated samples if no "SKIPPED" marker
                                        return const SizedBox.shrink();
                                      }
                                      if (resultString == "SKIPPED") {
                                         return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                                          child: Text('Sample ${index + 1}: Skipped', style: normalStyle.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                        );
                                      }
                                      if (resultString == null) return const SizedBox.shrink(); // Should not happen if error handling is correct

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Text(
                                          'Sample ${index + 1} Change: $resultString',
                                          style: normalStyle,
                                        ),
                                      );
                                    },
                                  ),
                                // Placeholder for Dumbbell results (if any were to be shown)
                                // else if (_selectedAgeingType == AgeingTestType.dumbbell)
                                //   Text("Dumbbell results will appear here.", style: normalStyle),
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
