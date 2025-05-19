import 'package:flutter/material.dart';
// import 'dart:math'; // No longer needed for pi

// Enum for Ageing Test Types (Kept as per instruction, though calculation is now the same for both)
enum IECTestType { iEC60332_3_22, iEC60332_3_24 }

// Helper class to hold controllers for each sample's inputs
class IECSampleControllers {
  String? selectedMaterialKey; // To store the key of the selected material (e.g., "PVC")
  final TextEditingController weightController; // For weight input

  IECSampleControllers()
      : weightController = TextEditingController(),
        selectedMaterialKey = null; // Initialize with no material selected

  void dispose() {
    weightController.dispose();
  }

  void clear() {
    selectedMaterialKey = null; // Reset selected material
    weightController.clear();
  }
}

// Updated Helper class to hold the calculated results for a single sample
// Kept separate classes as per original structure, but they will hold the same data.
class TubularSampleResults {
  final String material;
  final String weight;
  final String density;
  final String volume;

  TubularSampleResults({
    required this.material,
    required this.weight,
    required this.density,
    required this.volume,
  });

  @override
  String toString() {
    return 'Material: $material, Weight: $weight, Density: $density, Volume: $volume';
  }
}

class DumbbellSampleResults {
  final String material;
  final String weight;
  final String density;
  final String volume;

  DumbbellSampleResults({
    required this.material,
    required this.weight,
    required this.density,
    required this.volume,
  });

  @override
  String toString() {
    return 'Material: $material, Weight: $weight, Density: $density, Volume: $volume';
  }
}

class IEC60332Page extends StatefulWidget {
  const IEC60332Page({super.key});

  @override
  IEC60332PageState createState() => IEC60332PageState();
}

class IEC60332PageState extends State<IEC60332Page> {
  IECTestType _selectedIECType = IECTestType.iEC60332_3_22; // Kept as per instruction
  List<IECSampleControllers> _sampleControllers = [IECSampleControllers()];
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 10; // Updated max samples
  final ScrollController _scrollController = ScrollController();

  // Placeholder material density data - PLEASE UPDATE WITH YOUR ACTUAL VALUES AND UNITS
  // Assuming Weight is in grams (g) and these densities are in g/cm³
  // This will result in Volume in cm³
  final Map<String, double> _materialDensityData = {
    'Mica Tape': 1.6,      
    'XLPE': 0.94,     
    'PP Yarn': 1.47,      
    'FRT Tape': 1.4,       
    'LSZH': 1.47,    
    // Add more materials and their densities here
  };

  @override
  void initState() {
    super.initState();
    _initializeSamplesAndResults();
  }

  void _initializeSamplesAndResults() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _sampleControllers = [IECSampleControllers()];
    _calculatedResults =
        List.filled(_sampleControllers.length, null, growable: true);
  }

  @override
  void dispose() {
    for (var controllers in _sampleControllers) {
      controllers.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  void _onTestTypeChanged(IECTestType? newType) {
    if (newType != null && newType != _selectedIECType) {
      setState(() {
        _selectedIECType = newType;
        _resetFields(resetType: false); 
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
        _sampleControllers.add(IECSampleControllers());
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
        _showResultTab = false;
        _calculationError = null;
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
        if (_calculatedResults.length > index) {
          _calculatedResults.removeAt(index);
        }
        bool hasAnyValidResult = _calculatedResults.any((r) => r != null && r != "SKIPPED");
        if (!hasAnyValidResult && _calculationError == null) {
            _showResultTab = false;
        } else {
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

    // The distinction is now superficial as both will call the new common logic.
    // You could simplify this to one call if AgeingTestType is truly irrelevant.
    if (_selectedIECType == IECTestType.iEC60332_3_22) {
      _calculateNewValues(); // Changed to new common calculation
    } else if (_selectedIECType == IECTestType.iEC60332_3_24) {
      _calculateNewValues(); // Changed to new common calculation
    }
  }

  // New common calculation method for Density and Volume
  void _calculateNewValues() {
    List<dynamic> tempResults = List.filled(_sampleControllers.length, null, growable: true);
    String? firstErrorMsg;

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String? materialKey = controllers.selectedMaterialKey;
      final String weightText = controllers.weightController.text;

      if (materialKey == null && weightText.isEmpty) {
        if (_sampleControllers.length > 1 && (i == 0 || (tempResults.length > i - 1 && tempResults[i-1] != null))) {
          tempResults[i] = "SKIPPED";
          continue;
        } else if (_sampleControllers.length == 1) {
          firstErrorMsg ??= 'Please enter data for Sample ${i + 1}.';
        }
      }

      double? weight = double.tryParse(weightText);
      String? errorMsg;

      if (materialKey == null && (weightText.isNotEmpty || i==0 && _sampleControllers.length == 1) ) { // Error if material not selected but weight might be, or if it's the only sample
         if (tempResults[i] != "SKIPPED") {
            errorMsg = 'Material not selected (Sample ${i + 1}).';
         }
      }
      else if (weight == null && weightText.isNotEmpty) {
        errorMsg = 'Invalid Weight (Sample ${i + 1}).';
      } else if (materialKey == null || weightText.isEmpty) {
         if (tempResults[i] != "SKIPPED") {
             errorMsg = 'Material and Weight required for Sample ${i + 1}.';
         }
      } else if (weight != null) {
        if (weight <= 0) {
          errorMsg = 'Weight must be positive (Sample ${i + 1}).';
        }
      }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        tempResults[i] = null;
      } else if (materialKey != null && weight != null) {
        double? density = _materialDensityData[materialKey];
        if (density == null || density <= 0) {
          firstErrorMsg ??= 'Invalid or zero density for material: $materialKey (Sample ${i + 1}).';
          tempResults[i] = null;
        } else {
          double volume = (weight / density) / 1000;
          // Using the original result classes but populating them with new data
          if (_selectedIECType == IECTestType.iEC60332_3_22) {
            tempResults[i] = TubularSampleResults(
              material: materialKey,
              weight: '${weight.toStringAsFixed(2)} g',
              density: '${density.toStringAsFixed(2)} g/cm³', // Example unit
              volume: '${volume.toStringAsFixed(4)} l/m',   // Example unit
            );
          } else { // Dumbbell
             tempResults[i] = DumbbellSampleResults(
              material: materialKey,
              weight: '${weight.toStringAsFixed(2)} g',
              density: '${density.toStringAsFixed(2)} g/cm³',
              volume: '${volume.toStringAsFixed(3)} cm³',
            );
          }
        }
      } else if (tempResults[i] != "SKIPPED" && (materialKey != null || weightText.isNotEmpty)) {
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

  void _resetFields({bool resetType = true}) {
    FocusScope.of(context).unfocus();
    setState(() {
      for (var controllers in _sampleControllers) {
        controllers.dispose();
      }
      _sampleControllers = [IECSampleControllers()];
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _calculationError = null;
      _showResultTab = false;
      // _selectedOriginalLength = 20.0; // This line is removed as the variable is removed
      if (resetType) {
        _selectedIECType = IECTestType.iEC60332_3_22;
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
    // Labels are now fixed as Material and Weight
    const String materialFieldLabel = 'Material';
    const String weightFieldLabel = 'Weight (g)'; // Assuming grams

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
                // Material Dropdown
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: materialFieldLabel,
                      labelStyle: TextStyle(fontSize: 14.0),
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    value: controllers.selectedMaterialKey,
                    items: _materialDensityData.keys.map((String key) {
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(key, style: const TextStyle(fontSize: 14.0)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        controllers.selectedMaterialKey = newValue;
                        _showResultTab = false;
                        _calculationError = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20.0),
                // Weight TextField
                _buildTextField(label: weightFieldLabel, controller: controllers.weightController),
              ],
            ),
             // Removed the second row of text fields as there are only two inputs now
            const SizedBox(height: 10.0),
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
    final resultValueStyle = normalStyle.copyWith(fontSize: 14);

    return Scaffold(
      appBar: AppBar(title: const Text('IEC 60332-3-22/24 Calculations')), // Updated AppBar Title
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                // Kept AgeingTestType dropdown as per instruction, though its utility is diminished
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: DropdownButtonFormField<IECTestType>(
                    decoration: const InputDecoration(
                      labelText: 'Select IEC Test:', // Clarified label
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    value: _selectedIECType,
                    items: IECTestType.values.map((IECTestType type) {
                      return DropdownMenuItem<IECTestType>(
                        value: type,
                        child: Text(type.toString().split('.').last[0].toUpperCase() + type.toString().split('.').last.substring(1)),
                      );
                    }).toList(),
                    onChanged: _onTestTypeChanged,
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
                                  // Title for results can be generic or reflect the superficial type
                                  _selectedIECType == IECTestType.iEC60332_3_22 
                                      ? 'Calculation Results (IEC60332-3-22):' 
                                      : 'Calculation Results (IEC60332-3-24):',
                                  style: boldStyle
                                ),
                                if (_calculationError != null)
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
                                    // Results are now either TubularSampleResults or DumbbellSampleResults
                                    // but contain the same fields: material, weight, density, volume
                                    String materialRes = "", weightRes = "", densityRes = "", volumeRes = "";
                                    if (result is TubularSampleResults) {
                                        materialRes = result.material;
                                        weightRes = result.weight;
                                        densityRes = result.density;
                                        volumeRes = result.volume;
                                    } else if (result is DumbbellSampleResults) {
                                        materialRes = result.material;
                                        weightRes = result.weight;
                                        densityRes = result.density;
                                        volumeRes = result.volume;
                                    }

                                    if (materialRes.isNotEmpty) { // Check if we have a valid result to display
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
                                                  Text('Material: $materialRes', style: resultValueStyle),
                                                  Text('Weight: $weightRes', style: resultValueStyle),
                                                  Text('Density: $densityRes', style: resultValueStyle),
                                                  Text('Volume: $volumeRes', style: resultValueStyle),
                                                ],
                                              ),
                                            ),
                                            if (index < _calculatedResults.length -1 && _calculatedResults.skip(index+1).any((r) => r != null && r != "SKIPPED"))
                                               const Divider(height: 10, thickness: 0.5),
                                          ],
                                        ),
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
    );
  }
}
