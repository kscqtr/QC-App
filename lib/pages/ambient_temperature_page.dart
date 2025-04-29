import 'package:flutter/material.dart';

class AmbientTemperaturePage extends StatefulWidget {
  const AmbientTemperaturePage({super.key});

  @override
  AmbientTemperaturePageState createState() =>
      AmbientTemperaturePageState();
}

class AmbientTemperaturePageState extends State<AmbientTemperaturePage> {
  final TextEditingController _input1Controller = TextEditingController(); // Length L
  final TextEditingController _input2Controller = TextEditingController(); // Resistance R
  String? _result; // Stores the calculated "IR = X MΩ·km" string
  bool _showCalculationTab = false;
  // bool _isPass = true; // No pass/fail criteria mentioned

  // Dropdown values for units
  String _selectedLengthUnit = 'km';
  String _selectedRUnit = 'MΩ'; // Default unit

  // State for Material and Temperature/K Factor
  String? _selectedMaterial; // e.g., "PVC", "EPR"
  // --- MODIFIED: Temperature key is now String? ---
  String? _selectedTemperatureKey;
  double? _kFactor; // The K factor corresponding to material and temp

  // --- MODIFIED: Maps use String keys, added "None" ---
  final Map<String, double> _pvcTemperatureFactors = {
    "None": 1.0, // K=1 for "None"
    "23.0": 1.390, "23.5": 1.470, "24.0": 1.550, "24.5": 1.645, "25.0": 1.740,
    "25.5": 1.850, "26.0": 1.960, "26.5": 2.090, "27.0": 2.220, "27.5": 2.370,
    "28.0": 2.520, "28.5": 2.695, "29.0": 2.870, "29.5": 3.060, "30.0": 3.250,
    "30.5": 3.500, "31.0": 3.750, "31.5": 4.000, "32.0": 4.250, "32.5": 4.575,
    "33.0": 4.900, "33.5": 5.250, "34.0": 5.600, "34.5": 6.025, "35.0": 6.450
  };

  final Map<String, double> _eprTemperatureFactors = {
    "None": 1.0, // K=1 for "None"
    "25.0": 1.35, "25.5": 1.40, "26.0": 1.44, "26.5": 1.49, "27.0": 1.54,
    "27.5": 1.60, "28.0": 1.65, "28.5": 1.71, "29.0": 1.77, "29.5": 1.84,
    "30.0": 1.90, "30.5": 1.97, "31.0": 2.04, "31.5": 2.12, "32.0": 2.20,
    "32.5": 2.29, "33.0": 2.37
  };

  // Active map now uses String keys
  Map<String, double> _activeTemperatureMap = {};
  // --- End Modifications ---


  // Calculate Product Function
  void _calculateProduct() {
    double? inputL = double.tryParse(_input1Controller.text);
    double? inputR = double.tryParse(_input2Controller.text);

    // Check if all necessary inputs are valid (K factor is set when temp is selected)
    if (inputL != null && inputR != null && _selectedMaterial != null && _selectedTemperatureKey != null && _kFactor != null) {
      double lengthInKm = (_selectedLengthUnit == 'm') ? inputL / 1000.0 : inputL;

      if (lengthInKm <= 0) {
         setState(() { _result = 'Length must be positive.'; _showCalculationTab = false; });
         return;
      }

      double measuredValueInMOhm = (_selectedRUnit == 'GΩ') ? inputR * 1000.0 : inputR;

      // Apply formula IR = R * L * K (K will be 1.0 if "None" was selected)
      double product = measuredValueInMOhm * lengthInKm * _kFactor!;

      setState(() {
        _result = '${product.toStringAsFixed(2)} MΩ·km';
        _showCalculationTab = true;
      });
    } else {
      // Handle invalid or missing inputs
      setState(() {
        String errorMsg = 'Please enter valid numbers and select Material/Temperature.';
         // KFactor check removed as it depends on temp key selection
         if (_selectedTemperatureKey == null) errorMsg = 'Please select Temperature.';
         if (_selectedMaterial == null) errorMsg = 'Please select Material.';
         if (inputL == null) errorMsg = 'Please enter valid Length.';
         if (inputR == null) errorMsg = 'Please enter valid Resistance.';
        _result = errorMsg;
        _showCalculationTab = false;
      });
    }
     FocusScope.of(context).unfocus();
  }

  // Reset Fields Function
  void _resetFields() {
    setState(() {
      _input1Controller.clear();
      _input2Controller.clear();
      _selectedMaterial = null;
      _selectedTemperatureKey = null; // Reset String?
      _kFactor = null;
      _activeTemperatureMap = {};
      _result = null;
      _showCalculationTab = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insulation Resistance (Ambient Temperature)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Input Section
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      // Material Type Dropdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           SizedBox(
                             width: 200, // Keep original width or adjust
                             child: DropdownButtonHideUnderline(
                               child: DropdownButton<String>(
                                 value: _selectedMaterial,
                                 isExpanded: true,
                                 hint: const Text('Select Material Type', style: TextStyle(fontSize: 15.0)),
                                 onChanged: (String? newValue) {
                                   setState(() {
                                     _selectedMaterial = newValue!;
                                     _selectedTemperatureKey = null; // Reset temp
                                     _kFactor = null; // Reset K
                                     if (_selectedMaterial == 'PVC') {_activeTemperatureMap = _pvcTemperatureFactors;}
                                     else if (_selectedMaterial == 'EPR') {_activeTemperatureMap = _eprTemperatureFactors;}
                                     else {_activeTemperatureMap = {};}
                                     _showCalculationTab = false;
                                   });
                                 },
                                 items: <String>['PVC', 'EPR']
                                     .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text('Material: $value', style: const TextStyle(fontSize: 15.0)))).toList(),
                               ),
                             ),
                           ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // --- MODIFIED: Temperature Dropdown ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200, // Keep original width or adjust
                            child: DropdownButtonHideUnderline(
                              // --- Change type to String ---
                              child: DropdownButton<String>(
                                value: _selectedTemperatureKey,
                                isExpanded: true,
                                hint: Text(
                                  _selectedMaterial == null ? 'Select Material first' : 'Select Temperature', // Updated hint
                                  style: TextStyle(fontSize: 15.0, color: _selectedMaterial == null ? Colors.grey.shade500 : null),
                                ),
                                // --- Change onChanged type ---
                                onChanged: (_selectedMaterial == null || _activeTemperatureMap.isEmpty) ? null : (String? newValue) {
                                  setState(() {
                                    _selectedTemperatureKey = newValue!;
                                    // Look up and store the K factor (will be 1.0 for "None")
                                    _kFactor = _activeTemperatureMap[_selectedTemperatureKey];
                                    _showCalculationTab = false;
                                  });
                                },
                                // --- Map String keys ---
                                items: _activeTemperatureMap.keys
                                    .map<DropdownMenuItem<String>>((String key) { // Key is String
                                  return DropdownMenuItem<String>(
                                    value: key, // Value is String key
                                    // --- Display "None" or temperature ---
                                    child: Text(
                                      key == "None" ? "None" : 'Temperature: $key °C',
                                      style: const TextStyle(fontSize: 15.0)
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Original Input Rows (Resistance & Length)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _input2Controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15.0),
                              decoration: const InputDecoration(labelText: 'R, Measured value:', labelStyle: TextStyle(fontSize: 15.0)),
                              onChanged: (value) => setState(() { _showCalculationTab = false; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 56,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedRUnit,
                                onChanged: (String? newValue) => setState(() { _selectedRUnit = newValue!; _showCalculationTab = false; }),
                                items: <String>['MΩ', 'GΩ'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(top: 8), child: Text(value, style: const TextStyle(fontSize: 15.0))))).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _input1Controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15.0),
                              decoration: const InputDecoration(labelText: 'L, Length of cable:', labelStyle: TextStyle(fontSize: 15.0)),
                              onChanged: (value) => setState(() { _showCalculationTab = false; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 56,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedLengthUnit,
                                onChanged: (String? newValue) => setState(() { _selectedLengthUnit = newValue!; _showCalculationTab = false; }),
                                items: <String>['km', 'm'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Padding(padding: const EdgeInsets.only(top: 8), child: Text(value, style: const TextStyle(fontSize: 15.0))))).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calculate IR', style: TextStyle(fontSize: 16.0)),
                            onPressed: (_input1Controller.text.isNotEmpty &&
                                       _input2Controller.text.isNotEmpty &&
                                       _selectedMaterial != null &&
                                       _selectedTemperatureKey != null) // K factor is implicitly checked via temp key
                                ? _calculateProduct
                                : null,
                            style: ElevatedButton.styleFrom(minimumSize: const Size(150, 45)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset', style: TextStyle(fontSize: 16.0)),
                            onPressed: _resetFields,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[500],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(120, 45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Result Section
                AnimatedOpacity(
                  opacity: _showCalculationTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showCalculationTab
                      ? Container(
                          width: 300,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Calculation:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                              const SizedBox(height: 10),
                              Text('R = ${_input2Controller.text} $_selectedRUnit', style: const TextStyle(fontSize: 15)),
                              Text('L = ${_input1Controller.text} $_selectedLengthUnit', style: const TextStyle(fontSize: 15)),
                              // --- MODIFIED: Display K factor info ---
                              Text(
                                _selectedTemperatureKey == "None"
                                 ? 'K = Not Applied (Temp: None)'
                                 : 'K = ${_kFactor?.toStringAsFixed(4) ?? 'N/A'} (at $_selectedTemperatureKey °C for $_selectedMaterial)',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const Divider(height: 15, thickness: 1),
                              Text(
                                // --- MODIFIED: Formula display ---
                                _selectedTemperatureKey == "None"
                                 ? 'IR = R x L \n   = ${_result ?? '...'}'
                                 : 'IR = R x L x K \n   = ${_result ?? '...'}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
