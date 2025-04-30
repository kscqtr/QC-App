import 'package:flutter/material.dart';

class MutualCapacitancePage extends StatefulWidget {
  const MutualCapacitancePage({super.key});

  @override
  MutualCapacitancePageState createState() =>
      MutualCapacitancePageState();
}

class MutualCapacitancePageState extends State<MutualCapacitancePage> {
  // Controllers for inputs
  final TextEditingController _capacitanceController = TextEditingController();
  final TextEditingController _inductanceController = TextEditingController();
  final TextEditingController _resistanceController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();

  // State variables for dropdowns
  String _selectedCapacitanceUnit = 'nF';
  String _selectedInductanceUnit = 'µH';
  String _selectedResistanceUnit = 'mΩ';
  String _selectedLengthUnit = 'm';
  String? _selectedCableType;
  String? _selectedCableSize;

  // State variables for results
  String? _calculatedResultCapacitance; // Stores "X nF/km"
  String? _calculatedResultLR; // Stores "Y µs"
  String? _calculationError; // Stores error messages
  bool _showResultTab = false;
  bool _isPassCapacitance = true;
  bool _isPassLR = true;
  // Store the spec values used for display
  double? _currentCapSpecMax;
  double? _currentLRSpecMax;


  // Dropdown Options and Spec Maps
  final Map<String, double> _capacitanceSpecs = {
    'PVC': 250.0, 'Others': 250.0, 'XLPE': 150.0, 'PE': 150.0,
  };
  final List<String> _cableTypeOptions = ['PVC', 'XLPE', 'PE', 'Others'];

   final Map<String, double> _lrSpecs = {
    '≤ 1mm²': 25.0, '1.5mm²': 40.0, '2.5mm²': 60.0,
  };
  final List<String> _cableSizeOptions = ['≤ 1mm²', '1.5mm²', '2.5mm²'];


  @override
  void dispose() {
    _capacitanceController.dispose();
    _inductanceController.dispose();
    _resistanceController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  // Calculation Logic
  void _performCalculations() {
    // Clear previous errors/results first
    setState(() {
       _calculationError = null;
       _calculatedResultCapacitance = null;
       _calculatedResultLR = null;
       _showResultTab = false;
       _currentCapSpecMax = null;
       _currentLRSpecMax = null;
       _isPassCapacitance = true; // Reset pass status
       _isPassLR = true;
    });

    // Parse inputs
    double? capacitanceInput = double.tryParse(_capacitanceController.text);
    double? inductanceInput = double.tryParse(_inductanceController.text);
    double? resistanceInput = double.tryParse(_resistanceController.text);
    double? lengthInput = double.tryParse(_lengthController.text);

    // Validate ALL required inputs
    String? errorMsg;
    if (_selectedCableType == null) {errorMsg = 'Please select Cable Type.';}
    else if (_selectedCableSize == null) {errorMsg = 'Please select Cable Size.';}
    else if (capacitanceInput == null) {errorMsg = 'Invalid Capacitance input.';}
    else if (lengthInput == null) {errorMsg = 'Invalid Length input.';}
    else if (inductanceInput == null) {errorMsg = 'Invalid Inductance input.';}
    else if (resistanceInput == null) {errorMsg = 'Invalid Resistance input.';}
    else if (lengthInput <= 0) {errorMsg = 'Length must be positive.';}
    else if (capacitanceInput < 0) {errorMsg = 'Capacitance cannot be negative.';}
    else if (inductanceInput < 0) {errorMsg = 'Inductance cannot be negative.';}
    else if (resistanceInput <= 0) {errorMsg = 'Resistance must be positive.';}

    if (errorMsg != null) {
      setState(() { _calculationError = errorMsg; _showResultTab = true; });
      FocusScope.of(context).unfocus();
      return;
    }

    // Get Spec values (safe ! because null checks passed above)
    _currentCapSpecMax = _capacitanceSpecs[_selectedCableType!];
    _currentLRSpecMax = _lrSpecs[_selectedCableSize!];

    // Double-check if specs were found for the selected options
    if (_currentCapSpecMax == null || _currentLRSpecMax == null) {
       setState(() {
         _calculationError = 'Specification not found for selected Type/Size.';
         _showResultTab = true;
       });
       FocusScope.of(context).unfocus();
       return;
    }

    // Unit Conversions (safe ! because null checks passed)
    double lengthInKm = (_selectedLengthUnit == 'm') ? lengthInput! / 1000.0 : lengthInput!;
    double capacitanceInNf = (_selectedCapacitanceUnit == 'pF') ? capacitanceInput! / 1000.0 : (_selectedCapacitanceUnit == 'µF' ? capacitanceInput! * 1000.0 : capacitanceInput!);
    double inductanceInMicroH = (_selectedInductanceUnit == 'mH') ? inductanceInput! * 1000.0 : inductanceInput!;
    double resistanceInOhm = (_selectedResistanceUnit == 'Ω') ? resistanceInput!: (_selectedResistanceUnit == 'mΩ') ? resistanceInput! / 1000.0 : (_selectedResistanceUnit == 'µΩ' ? resistanceInput! / 1000000.0 : resistanceInput!);

    // Calculations
    double mutualCapacitance = capacitanceInNf / lengthInKm;
    double lrRatioMicroSeconds = (resistanceInOhm == 0) ? double.infinity : inductanceInMicroH / resistanceInOhm;

    // Comparisons
    _isPassCapacitance = mutualCapacitance <= _currentCapSpecMax!;
    _isPassLR = (lrRatioMicroSeconds == double.infinity) ? false : lrRatioMicroSeconds <= _currentLRSpecMax!;

    setState(() {
      // Format results
      _calculatedResultCapacitance = '${mutualCapacitance.toStringAsFixed(3)} nF/km';
      _calculatedResultLR = lrRatioMicroSeconds == double.infinity ? 'Infinity (R=0)' : '${lrRatioMicroSeconds.toStringAsFixed(3)} µH/Ω';
      _showResultTab = true;
    });
     FocusScope.of(context).unfocus();
  }

  // Reset Logic
  void _resetFields() {
    setState(() {
      _capacitanceController.clear();
      _inductanceController.clear();
      _resistanceController.clear();
      _lengthController.clear();
      _selectedCapacitanceUnit = 'nF';
      _selectedInductanceUnit = 'µH';
      _selectedResistanceUnit = 'mΩ';
      _selectedLengthUnit = 'm';
      _selectedCableType = null;
      _selectedCableSize = null;
      _calculatedResultCapacitance = null;
      _calculatedResultLR = null;
      _calculationError = null;
      _showResultTab = false;
      _isPassCapacitance = true;
      _isPassLR = true;
      _currentCapSpecMax = null;
      _currentLRSpecMax = null;
    });
  }

  // Helper to build input rows
  Widget _buildInputRow({
      required String label,
      required TextEditingController controller,
      required String selectedUnit,
      required List<String> unitOptions,
      required ValueChanged<String?> onUnitChanged,
      double fieldWidth = 150,
      double unitWidth = 80,
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
              onChanged: (value) => setState(() => _showResultTab = false),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: unitWidth,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                 border: OutlineInputBorder(),
                 isDense: true,
                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
               ),
              value: selectedUnit,
              onChanged: (val) {
                  onUnitChanged(val);
                  setState(() => _showResultTab = false);
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

   // Helper to build dropdown rows
  Widget _buildDropdownRow({
    required String hint,
    required String? selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    double width = 240,
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
               onChanged: (val) {
                  onChanged(val);
                  setState(() => _showResultTab = false);
               },
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
    // Define styles for reuse
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87);
    const normalStyle = TextStyle(fontSize: 15, color: Colors.black87);
    final italicStyle = normalStyle.copyWith(fontStyle: FontStyle.italic);
    final formulaStyle = italicStyle.copyWith(fontSize: 13, color: Colors.grey[700]);
    final passStyle = boldStyle.copyWith(color: Colors.green.shade800);
    final failStyle = boldStyle.copyWith(color: Colors.red.shade800);
    final errorStyle = boldStyle.copyWith(color: Colors.red, fontSize: 16);


    return Scaffold(
      appBar: AppBar(title: const Text('Mutual Capacitance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Input Fields
                _buildInputRow(label: 'Capacitance (C):', controller: _capacitanceController, selectedUnit: _selectedCapacitanceUnit, unitOptions: const ['nF', 'pF', 'µF'], onUnitChanged: (val) => _selectedCapacitanceUnit = val!),
                _buildInputRow(label: 'Inductance (L):', controller: _inductanceController, selectedUnit: _selectedInductanceUnit, unitOptions: const ['µH', 'mH'], onUnitChanged: (val) => _selectedInductanceUnit = val!),
                _buildInputRow(label: 'Resistance (R):', controller: _resistanceController, selectedUnit: _selectedResistanceUnit, unitOptions: const ['µΩ','mΩ','Ω' ], onUnitChanged: (val) => _selectedResistanceUnit = val!),
                _buildInputRow(label: 'Length (L):', controller: _lengthController, selectedUnit: _selectedLengthUnit, unitOptions: const ['km', 'm'], onUnitChanged: (val) => _selectedLengthUnit = val!),

                // Dropdowns
                 _buildDropdownRow(hint: 'Select Cable Type', selectedValue: _selectedCableType, options: _cableTypeOptions, onChanged: (val) => _selectedCableType = val, width: 240),
                 _buildDropdownRow(hint: 'Select Cable Size', selectedValue: _selectedCableSize, options: _cableSizeOptions, onChanged: (val) => _selectedCableSize = val, width: 240),

                const SizedBox(height: 30),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(onPressed: _resetFields, icon: const Icon(Icons.refresh), label: const Text('Reset'), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], minimumSize: const Size(120, 45))),
                    ElevatedButton.icon(onPressed: _performCalculations, icon: const Icon(Icons.calculate), label: const Text('Calculate'), style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, minimumSize: const Size(120, 45))),
                  ],
                ),
                const SizedBox(height: 30),

                // --- MODIFIED Result Section with Formulas (using Text widgets) ---
                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _calculationError != null ? Colors.red[50] : Colors.blue[50], // Error or neutral background
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: _calculationError != null ? Colors.red.shade300 : Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Show Error if present
                              if (_calculationError != null)
                                Text(_calculationError!, style: errorStyle)
                              // Show Results if no error
                              else ...[
                                // Capacitance Result Block
                                const Text('Mutual Capacitance', style: boldStyle),
                                Text('  Formula: C / L', style: formulaStyle),
                                Text('  Spec Max (${_selectedCableType ?? ''}): ${_currentCapSpecMax?.toStringAsFixed(1) ?? 'N/A'} nF/km', style: formulaStyle),
                                const SizedBox(height: 10),
                                Text('Calculated: ${_calculatedResultCapacitance ?? '...'}', style: boldStyle),
                                Text(
                                  'Result: ${_isPassCapacitance ? 'Pass' : 'Fail'}',
                                  style: _isPassCapacitance ? passStyle : failStyle,
                                ),
                                const Divider(height: 25, thickness: 1),

                                // L/R Result Block
                                const Text('L/R Ratio', style: boldStyle),
                                Text('  Formula: L / R', style: formulaStyle),
                                Text('  Spec Max (${_selectedCableSize ?? ''}): ${_currentLRSpecMax?.toStringAsFixed(1) ?? 'N/A'} ɥH/Ω', style: formulaStyle),
                                const SizedBox(height: 10),
                                Text('Calculated: ${_calculatedResultLR ?? '...'}', style: boldStyle),
                                Text(
                                  'Result: ${_isPassLR ? 'Pass' : 'Fail'}',
                                  style: _isPassLR ? passStyle : failStyle,
                                ),
                              ]
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                 const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
