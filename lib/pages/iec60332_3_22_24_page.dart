import 'package:flutter/material.dart';
// import 'dart:math'; // No longer needed for pi

// Enum for IEC Test Types
enum IECTestType { iEC60332_3_22, iEC60332_3_24 }

// Helper class to hold controllers for each material's inputs
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

// Result class for IEC60332-3-22 (structurally same as Dumbbell for now)
class TubularSampleResults { // Kept original name, but represents IEC60332_3_22 result
  final String material;
  final String weight;
  final String density;
  final String volume;
  final double rawVolumeLM;

  TubularSampleResults({
    required this.material,
    required this.weight,
    required this.density,
    required this.volume,
    required this.rawVolumeLM,
  });

  @override
  String toString() {
    return 'Material: $material, Weight: $weight, Density: $density, Volume: $volume, RawVolume: $rawVolumeLM';
  }
}

// Result class for IEC60332-3-24 (structurally same as Tubular for now)
class DumbbellSampleResults { // Kept original name, but represents IEC60332_3_24 result
  final String material;
  final String weight;
  final String density;
  final String volume;
  final double rawVolumeLM;

  DumbbellSampleResults({
    required this.material,
    required this.weight,
    required this.density,
    required this.volume,
    required this.rawVolumeLM,
  });

  @override
  String toString() {
    return 'Material: $material, Weight: $weight, Density: $density, Volume: $volume, RawVolume: $rawVolumeLM';
  }
}

class IEC60332Page extends StatefulWidget {
  const IEC60332Page({super.key});

  @override
  IEC60332PageState createState() => IEC60332PageState();
}

class IEC60332PageState extends State<IEC60332Page> {
  IECTestType _selectedIECType = IECTestType.iEC60332_3_22;
  List<IECSampleControllers> _sampleControllers = [IECSampleControllers()]; // Renamed for clarity
  List<dynamic> _calculatedResults = [];
  String? _calculationError;
  bool _showResultTab = false;
  final int _maxSamples = 10;
  final ScrollController _scrollController = ScrollController();

  // Updated material density data
  final Map<String, double> _materialDensityData = {
    'Mica Tape': 1.6,   // g/cm³
    'XLPE': 0.94,       // g/cm³
    'PP Yarn': 1.47,    // g/cm³ - Note: PP density is usually lower, around 0.9. Please verify.
    'FRT Tape': 1.4,    // g/cm³ - Flame Retardant Tape, density can vary.
    'LSZH': 1.47,       // g/cm³
    // Add more materials and their densities here
  };

  String _totalVolumeDisplay = "";
  double _rawTotalVolumeLM = 0.0; 

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
    _totalVolumeDisplay = ""; // Reset display string
    _rawTotalVolumeLM = 0.0;  // <-- Reset raw total volume
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
        // Reset fields but keep the newly selected type.
        // Also, clear results as the test type context has changed.
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

  void _addMaterial() { // Renamed from _addSample
    if (_sampleControllers.length < _maxSamples) {
      setState(() {
        _sampleControllers.add(IECSampleControllers());
        // Ensure _calculatedResults list is extended correctly
        _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
        _showResultTab = false;
        _calculationError = null;
        _totalVolumeDisplay = ""; // Clear total when adding new material
        _rawTotalVolumeLM = 0.0;
      });
      Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of $_maxSamples material entries reached.')),
      );
    }
  }

  void _removeMaterial(int index) { // Renamed from _removeSample
    if (_sampleControllers.length > 1) { // Allow removing if more than one material exists
      setState(() {
        _sampleControllers[index].dispose();
        _sampleControllers.removeAt(index);
        if (_calculatedResults.length > index) {
          _calculatedResults.removeAt(index);
        }
        bool hasAnyValidResult = _calculatedResults.any((r) => r != null && r != "SKIPPED");
        if (!hasAnyValidResult && _calculationError == null) {
            _showResultTab = false;
            _totalVolumeDisplay = ""; // Clear total if no valid results
            _rawTotalVolumeLM = 0.0;
        } else {
            // Recalculate total if some results remain
            _performCalculations(); // This will re-evaluate everything including total
            _showResultTab = _calculatedResults.any((r) => r != null) || _calculationError != null;
        }
        if (!_showResultTab) {
            _calculationError = null;
            _totalVolumeDisplay = "";
            _rawTotalVolumeLM = 0.0;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one material is required.')),
      );
    }
  }

  void _performCalculations() {
    FocusScope.of(context).unfocus();
    setState(() {
      _calculationError = null;
      _calculatedResults = List.filled(_sampleControllers.length, null, growable: true);
      _showResultTab = false;
      _totalVolumeDisplay = "";
      _rawTotalVolumeLM = 0.0;
    });
    // Simplified: _calculateNewValues handles the logic based on _selectedIECType for result instantiation
    _calculateNewValues(); 
  }

  void _calculateNewValues() {
    List<dynamic> tempResults = List.filled(_sampleControllers.length, null, growable: true);
    String? firstErrorMsg;
    double currentRunningTotalVolumeLM = 0.0; // Local variable for summing in this run
    int validCalculationsCount = 0;

    for (int i = 0; i < _sampleControllers.length; i++) {
      final controllers = _sampleControllers[i];
      final String? materialKey = controllers.selectedMaterialKey;
      final String weightText = controllers.weightController.text;
      
      if (materialKey == null && weightText.isEmpty) {
        if (_sampleControllers.length > 1 && (i == 0 || (tempResults.length > i - 1 && tempResults[i-1] != null))) {
          tempResults[i] = "SKIPPED";
          continue;
        } else if (_sampleControllers.length == 1) {
          firstErrorMsg ??= 'Please enter data for Material ${i + 1}.'; 
        }
      }

      double? weight = double.tryParse(weightText);
      String? errorMsg;

      if (materialKey == null && (weightText.isNotEmpty || (i == 0 && _sampleControllers.length == 1))) {
         if (tempResults[i] != "SKIPPED") {
            errorMsg = 'Material not selected (Material ${i + 1}).'; 
         }
      }
      else if (weight == null && weightText.isNotEmpty) {
        errorMsg = 'Invalid Weight (Material ${i + 1}).'; 
      } else if (materialKey == null || weightText.isEmpty) {
         if (tempResults[i] != "SKIPPED") {
             errorMsg = 'Material and Weight required for Material ${i + 1}.'; 
         }
      } else if (weight != null) {
        if (weight <= 0) {
          errorMsg = 'Weight must be positive (Material ${i + 1}).'; 
        }
      }

      if (errorMsg != null) {
        firstErrorMsg ??= errorMsg;
        tempResults[i] = null;
      } else if (materialKey != null && weight != null) {
        double? density = _materialDensityData[materialKey];
        if (density == null || density <= 0) {
          firstErrorMsg ??= 'Invalid or zero density for material: $materialKey (Material ${i + 1}).'; 
          tempResults[i] = null;
        } else {
          double volumeCm3 = weight / density; 
          double volumeLM = volumeCm3 / 1000; 

          currentRunningTotalVolumeLM += volumeLM; 
          validCalculationsCount++;       

          if (_selectedIECType == IECTestType.iEC60332_3_22) {
            tempResults[i] = TubularSampleResults( 
              material: materialKey,
              weight: '${weight.toStringAsFixed(2)} g',
              density: '${density.toStringAsFixed(2)} g/cm³',
              volume: '${volumeLM.toStringAsFixed(4)} l/m', 
              rawVolumeLM: volumeLM,
            );
          } else { // IECTestType.iEC60332_3_24
             tempResults[i] = DumbbellSampleResults( 
              material: materialKey,
              weight: '${weight.toStringAsFixed(2)} g',
              density: '${density.toStringAsFixed(2)} g/cm³',
              volume: '${volumeLM.toStringAsFixed(4)} l/m', 
              rawVolumeLM: volumeLM,
            );
          }
        }
      } else if (tempResults[i] != "SKIPPED" && (materialKey != null || weightText.isNotEmpty)) {
         firstErrorMsg ??= 'Incomplete or invalid data for Material ${i+1}.'; 
         tempResults[i] = null;
      }
    }

    setState(() {
      _calculatedResults = tempResults;
      _rawTotalVolumeLM = currentRunningTotalVolumeLM; // Set state for raw total volume

      if (firstErrorMsg != null) {
        _calculationError = firstErrorMsg;
        _totalVolumeDisplay = ""; 
        _rawTotalVolumeLM = 0.0; 
      } else if (validCalculationsCount > 0) { 
        _totalVolumeDisplay = "Total Volume: ${currentRunningTotalVolumeLM.toStringAsFixed(4)} l/m";
      } else {
        _totalVolumeDisplay = ""; 
        _rawTotalVolumeLM = 0.0; 
      }

      bool hasActualCalculations = _calculatedResults.any((r) => r is TubularSampleResults || r is DumbbellSampleResults);
      bool hasSkipped = _calculatedResults.any((r) => r == "SKIPPED");

      if (hasActualCalculations || _calculationError != null || hasSkipped) {
        if (!hasActualCalculations && _calculationError == null && hasSkipped) {
          _calculationError = "All valid entries were skipped. No results to display.";
        } else if (!hasActualCalculations && _calculationError == null && !hasSkipped) {
          if (_totalVolumeDisplay.isEmpty) { // Check if total is also empty
             _calculationError = "No valid data entered for calculation.";
          }
        }
        _showResultTab = true;
      } else {
        if (_totalVolumeDisplay.isEmpty) { // If no results and no total, then no data
            _calculationError = "No data to process.";
        }
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
      _totalVolumeDisplay = "";
      _rawTotalVolumeLM = 0.0;
      if (resetType) {
        _selectedIECType = IECTestType.iEC60332_3_22; // Default IEC type
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
            _totalVolumeDisplay = ""; // Clear total on input change
            _rawTotalVolumeLM = 0.0;
        }),
      ),
    );
  }

  Widget _buildMaterialInputRow(int index) {
    final controllers = _sampleControllers[index];
    const String materialFieldLabel = 'Material';
    const String weightFieldLabel = 'Weight (g)';

    return Padding( 
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
          Expanded( 
            flex: 2, 
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
                  child: Text(key, style: const TextStyle(fontSize: 14.0), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  controllers.selectedMaterialKey = newValue;
                  _showResultTab = false;
                  _calculationError = null;
                  _totalVolumeDisplay = ""; // Clear total on input change
                  _rawTotalVolumeLM = 0.0;
                });
              },
              isExpanded: true, 
            ),
          ),
          const SizedBox(width: 10.0), 
          Expanded( 
            flex: 2, 
            child: _buildTextField(
              label: weightFieldLabel, 
              controller: controllers.weightController,
              fieldWidth: null, 
            ),
          ),
          if (_sampleControllers.length > 1)
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade700),
              tooltip: 'Remove Material', // Changed tooltip
              padding: const EdgeInsets.only(left: 8.0), 
              constraints: const BoxConstraints(),
              onPressed: () => _removeMaterial(index),
            )
          else 
            const SizedBox(width: 48), 
        ],
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
      appBar: AppBar(title: const Text('IEC 60332-3-22/24')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, 
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: DropdownButtonFormField<IECTestType>(
                    decoration: const InputDecoration(
                      labelText: 'Select IEC Test:',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    ),
                    value: _selectedIECType,
                    items: IECTestType.values.map((IECTestType type) {
                      String typeName = type.toString().split('.').last;
                      if (type == IECTestType.iEC60332_3_22) typeName = "IEC 60332-3-22";
                      if (type == IECTestType.iEC60332_3_24) typeName = "IEC 60332-3-24";
                      return DropdownMenuItem<IECTestType>(
                        value: type,
                        child: Text(typeName),
                      );
                    }).toList(),
                    onChanged: _onTestTypeChanged,
                  ),
                ),
                
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  elevation: 1.0,
                  color: const Color(0xFFFFEBEB), 
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _sampleControllers.length,
                      itemBuilder: (context, index) {
                        return _buildMaterialInputRow(index); 
                      },
                    ),
                  )
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
                        onPressed: _addMaterial, 
                        icon: const Icon(Icons.add),
                        label: const Text('Add Material'), 
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade300,
                            minimumSize: const Size(140, 45))), 
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
                                  _selectedIECType == IECTestType.iEC60332_3_22 
                                      ? 'Calculation Results (IEC 60332-3-22):' 
                                      : 'Calculation Results (IEC 60332-3-24):',
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
                                        child: Text('Material ${index + 1}: Skipped', style: normalStyle.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[700])),
                                      );
                                    }
                                    
                                    String materialRes = "", weightRes = "", densityRes = "", volumeDisplayStr = "";
                                    double individualRawVolume = 0.0;

                                    if (result is TubularSampleResults) { 
                                        materialRes = result.material;
                                        weightRes = result.weight;
                                        densityRes = result.density;
                                        volumeDisplayStr = result.volume;
                                        individualRawVolume = result.rawVolumeLM;
                                    } else if (result is DumbbellSampleResults) { 
                                        materialRes = result.material;
                                        weightRes = result.weight;
                                        densityRes = result.density;
                                        volumeDisplayStr = result.volume;
                                        individualRawVolume = result.rawVolumeLM;
                                    }

                                    if (materialRes.isNotEmpty) { 
                                      String percentageText = "";
                                      if (_rawTotalVolumeLM > 1e-9 && individualRawVolume > 0) { 
                                        double percentage = (individualRawVolume / _rawTotalVolumeLM) * 100;
                                        percentageText = " (${percentage.toStringAsFixed(1)}%)"; 
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Material ${index + 1}: $materialRes', style: boldStyle.copyWith(fontSize: 15)), 
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Weight: $weightRes', style: resultValueStyle),
                                                  Text('Density: $densityRes', style: resultValueStyle),
                                                  Text('Volume: $volumeDisplayStr$percentageText', style: resultValueStyle), // Corrected Line
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

                                if (_totalVolumeDisplay.isNotEmpty && _calculationError == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0), 
                                    child: Column(
                                      children: [
                                        const Divider(height: 10, thickness: 0.8, color: Colors.blueGrey),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Text(
                                            _totalVolumeDisplay,
                                            style: boldStyle.copyWith(fontSize: 16, color: Theme.of(context).primaryColorDark), 
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
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
