import 'package:flutter/material.dart';
// import 'dart:math'; // Not strictly needed for this page's logic

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

  // Dropdown values for units
  String _selectedLengthUnit = 'km';
  String _selectedRUnit = 'MΩ'; // Default unit

  // State for Material and Temperature/K Factor
  String? _selectedMaterial;
  String? _selectedTemperatureKey; // Now String?
  double? _kFactor;

  // Maps use String keys, added "None"
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

  Map<String, double> _activeTemperatureMap = {};


  @override
  void dispose() {
    _input1Controller.dispose();
    _input2Controller.dispose();
    super.dispose();
  }

  void _calculateProduct() {
    double? inputL = double.tryParse(_input1Controller.text);
    double? inputR = double.tryParse(_input2Controller.text);

    if (inputL != null && inputR != null && _selectedMaterial != null && _selectedTemperatureKey != null && _kFactor != null) {
      double lengthInKm = (_selectedLengthUnit == 'm') ? inputL / 1000.0 : inputL;

      if (lengthInKm <= 0) {
         setState(() { _result = 'Length must be positive.'; _showCalculationTab = false; });
         return;
      }

      double measuredValueInMOhm = (_selectedRUnit == 'GΩ') ? inputR * 1000.0 : inputR;
      double product = measuredValueInMOhm * lengthInKm * _kFactor!;

      setState(() {
        _result = '${product.toStringAsFixed(4)} MΩ·km';
        _showCalculationTab = true;
      });
    } else {
      setState(() {
        String errorMsg = 'Please enter valid numbers and select Material/Temperature.';
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

  void _resetFields() {
    setState(() {
      _input1Controller.clear();
      _input2Controller.clear();
      _selectedMaterial = null;
      _selectedTemperatureKey = null;
      _kFactor = null;
      _activeTemperatureMap = {};
      _result = null;
      _showCalculationTab = false;
      _selectedLengthUnit = 'km'; // Reset to default
      _selectedRUnit = 'MΩ';    // Reset to default
    });
  }

  // --- ADDED: Helper to build input rows with units (similar to MutualCapacitancePage) ---
  Widget _buildInputRowWithUnit({
      required String label,
      required TextEditingController controller,
      required String selectedUnit,
      required List<String> unitOptions,
      required ValueChanged<String?> onUnitChanged,
      double fieldWidth = 180, // Original width from user code
      double unitWidth = 70,   // Adjusted for unit dropdown
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: fieldWidth,
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 15.0),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 15.0),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              onChanged: (value) => setState(() => _showCalculationTab = false),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: unitWidth,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                 border: OutlineInputBorder(),
                 isDense: true,
                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Fine-tuned padding
               ),
              value: selectedUnit,
              onChanged: (val) {
                  onUnitChanged(val);
                  setState(() => _showCalculationTab = false);
              },
              items: unitOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 15.0)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- ADDED: Helper to build general dropdowns (similar to MutualCapacitancePage) ---
  Widget _buildDropdownRow({
    required String hint,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?>? onChanged,
    double width = 260, // Adjusted to match combined width of input + unit
  }) {
     return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           SizedBox(
             width: width,
             child: DropdownButtonFormField<String>(
               decoration: InputDecoration(
                  labelText: hint,
                  labelStyle: const TextStyle(fontSize: 15.0),
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
               value: selectedValue,
               hint: Text(hint, style: const TextStyle(fontSize: 15.0, color: Colors.grey)),
               isExpanded: true,
               onChanged: onChanged != null ? (val) {
                  onChanged(val);
                  setState(() => _showCalculationTab = false);
               }: null,
               items: options.map<DropdownMenuItem<String>>((String value) {
                 return DropdownMenuItem<String>(
                   value: value,
                   child: Text(value, style: const TextStyle(fontSize: 15.0)),
                 );
               }).toList(),
             ),
           ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IR (Ambient Temperature)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      // --- Use Helper for Material Type Dropdown ---
                      _buildDropdownRow(
                        hint: 'Select Material Type',
                        selectedValue: _selectedMaterial,
                        options: const ['PVC', 'EPR'],
                        onChanged: (String? newValue) {
                           setState(() {
                             _selectedMaterial = newValue!;
                             _selectedTemperatureKey = null;
                             _kFactor = null;
                             if (_selectedMaterial == 'PVC') {_activeTemperatureMap = _pvcTemperatureFactors;}
                             else if (_selectedMaterial == 'EPR') {_activeTemperatureMap = _eprTemperatureFactors;}
                             else {_activeTemperatureMap = {};}
                             _showCalculationTab = false;
                           });
                        },
                        width: 260, // Consistent width
                      ),
                      const SizedBox(height: 10),

                      // --- Use Helper for Temperature Dropdown ---
                      _buildDropdownRow(
                        hint: _selectedMaterial == null ? 'Select Material first' : 'Select Temperature',
                        selectedValue: _selectedTemperatureKey,
                        options: _activeTemperatureMap.keys.toList(),
                        onChanged: (_selectedMaterial == null || _activeTemperatureMap.isEmpty) ? null : (String? newValue) {
                           setState(() {
                             _selectedTemperatureKey = newValue!;
                             _kFactor = _activeTemperatureMap[_selectedTemperatureKey];
                             _showCalculationTab = false;
                           });
                        },
                        width: 260, // Consistent width
                        // Custom display logic for "None" vs "Temp: X °C" is handled in items for DropdownButton
                        // For DropdownButtonFormField, the child of DropdownMenuItem handles the display
                      ),
                      const SizedBox(height: 10),

                      // --- Use Helper for Resistance Input ---
                      _buildInputRowWithUnit(
                        label: 'R, Measured value:',
                        controller: _input2Controller,
                        selectedUnit: _selectedRUnit,
                        unitOptions: const ['MΩ', 'GΩ'],
                        onUnitChanged: (val) => setState(() { _selectedRUnit = val!; _showCalculationTab = false; }),
                        fieldWidth: 180,
                        unitWidth: 70,
                      ),
                      const SizedBox(height: 10),

                      // --- Use Helper for Length Input ---
                      _buildInputRowWithUnit(
                        label: 'L, Length of cable:',
                        controller: _input1Controller,
                        selectedUnit: _selectedLengthUnit,
                        unitOptions: const ['km', 'm'],
                        onUnitChanged: (val) => setState(() { _selectedLengthUnit = val!; _showCalculationTab = false; }),
                        fieldWidth: 180,
                        unitWidth: 70,
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
                                       _selectedTemperatureKey != null)
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

                // Result Section (Kept original styling)
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
                              Text(
                                _selectedTemperatureKey == "None"
                                 ? 'K = Not Applied (Temp: None)'
                                 : 'K = ${_kFactor?.toStringAsFixed(4) ?? 'N/A'} (at $_selectedTemperatureKey °C for $_selectedMaterial)',
                                style: const TextStyle(fontSize: 15),
                              ),
                              const Divider(height: 15, thickness: 1),
                              Text(
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
