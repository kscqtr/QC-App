import 'package:flutter/material.dart';

class ConductorResistancePage extends StatefulWidget {
  const ConductorResistancePage({super.key});

  @override
  ConductorResistancePageState createState() =>
      ConductorResistancePageState();
}

class ConductorResistancePageState extends State<ConductorResistancePage> {
  final TextEditingController _input1Controller = TextEditingController(); // Length L
  final TextEditingController _input2Controller = TextEditingController(); // Resistance R
  String? _result; // Stores the calculated "X = Y Ω/km" string
  bool _showCalculationTab = false;
  bool _showComparisonTab = false;
  String _comparisonText = '';
  Color _comparisonColor = Colors.black;
  bool _isPass = true;

  // Dropdown values for units
  String _selectedLengthUnit = 'km';
  String _selectedRUnit = 'Ω';

  // State for selected cable class
  String? _selectedCableClass;

  // Temperature dropdown values (Key: Temp °C, Value: Factor K)
  final Map<double, double> _temperatureValues = {
    23.0: 0.9883, 23.5: 0.9864, 24.0: 0.9845, 24.5: 0.9826, 25.0: 0.9807,
    25.5: 0.9788, 26.0: 0.9770, 26.5: 0.9751, 27.0: 0.9732, 27.5: 0.9714,
    28.0: 0.9695, 28.5: 0.9677, 29.0: 0.9658, 29.5: 0.9640, 30.0: 0.9622,
    30.5: 0.9604, 31.0: 0.9586, 31.5: 0.9568, 32.0: 0.9550, 32.5: 0.9532,
    33.0: 0.9514, 33.5: 0.9496, 34.0: 0.9478, 34.5: 0.9461, 35.0: 0.9443,
  };

  // Cable size maps use String keys
  final Map<String, double> _cableSizeValuesClass2 = {
    "0.5": 36.0, "0.75": 24.5, "1.0": 18.1, "1.5": 12.1, "2.5": 7.41,
    "4.0": 4.61, "6.0": 3.08, "10.0": 1.83, "16.0": 1.15, "25.0": 0.727,
    "35.0": 0.524, "50.0": 0.387, "70.0": 0.268, "95.0": 0.193,
    "120.0": 0.153, "150.0": 0.121, "185.0": 0.0986, "240.0": 0.0754,
    "300.0": 0.0601, "400.0": 0.0470, "500.0": 0.0366, "630.0": 0.0283,
    "800.0": 0.0221, "1000.0": 0.0176,
  };
  final Map<String, double> _cableSizeValuesClass5 = {
     "#23": 25.08, "#40": 14.42, "#70": 8.242, "#110": 5.247, "#162": 3.561,
     "0.5": 39.0, "0.75": 26.0, "1.0": 19.5, "1.5": 13.3, "2.5": 7.98,
     "4.0": 4.95, "6.0": 3.30, "10.0": 1.91, "16.0": 1.21, "25.0": 0.780,
     "35.0": 0.554, "50.0": 0.386, "70.0": 0.272, "95.0": 0.206, "120.0": 0.161,
     "150.0": 0.129, "185.0": 0.106, "240.0": 0.0801, "300.0": 0.0641, "400.0": 0.0486,
     "500.0": 0.0384, "630.0": 0.0287,
  };
  final Map<String, double> _cableSizeValuesOthers = {
     "0.6 MM": 65.4, "0.9 MM": 29.1, "14 AWG": 8.45, "16 AWG": 13.5, "18 AWG": 21.4,
     "20 AWG": 33.9, "22 AWG": 54.3, "23 AWG": 67.9, "24 AWG": 85.9,
  };

  // Variable to hold the currently active map
  Map<String, double> _activeCableSizeMap = {};

  // Selected key for cable size dropdown (now String)
  String? _selectedCableSizeKey;
  // Selected key for temperature dropdown
  double? _selectedTemperatureKey;


  // Helper function to get decimal places from a string representation of a number
  int _getDecimalPlaces(String numberString) {
    if (!numberString.contains('.')) {
      return 0;
    }
    final parts = numberString.split('.');
    if (parts.length < 2 || parts[1].isEmpty) {
      return 0;
    }
    return parts.last.length;
  }

  void _calculateProduct() {
    double? input1 = double.tryParse(_input1Controller.text);
    double? input2 = double.tryParse(_input2Controller.text);
    double? input3 = _temperatureValues[_selectedTemperatureKey];
    double? input4 = _activeCableSizeMap[_selectedCableSizeKey];

    if (input1 != null && input2 != null && input3 != null && _selectedCableClass != null && _selectedCableSizeKey != null && input4 != null) {
      double length = input1;
      if (_selectedLengthUnit == 'm') length /= 1000;
      if (length == 0) {
         setState(() { _result = 'Length cannot be zero.'; _showCalculationTab = false; _showComparisonTab = false; });
         return;
      }

      double resistance = input2;
      if (_selectedRUnit == 'mΩ') resistance /= 1000;

      int decimalnum = 0;
      String valueStringForResult = input4.toString();
      if (valueStringForResult.contains('.')) {
        decimalnum = _getDecimalPlaces(valueStringForResult);
      }
      decimalnum = decimalnum.clamp(0, 20);

      double product = (resistance * input3) / length;
      setState(() {
        _result = '${product.toStringAsFixed(decimalnum)} Ω/km';
        _showCalculationTab = true;
        _showComparisonTab = true;
        _compareResults(product);
      });
    } else {
      setState(() {
        String errorMsg = 'Please enter valid numbers and select all options.';
         if (input4 == null && _selectedCableSizeKey != null) errorMsg = 'Max CR value missing for selected size/class.';
         if (_selectedCableSizeKey == null) errorMsg = 'Please select Cable Size.';
         if (_selectedCableClass == null) errorMsg = 'Please select Cable Class.';
         if (_selectedTemperatureKey == null) errorMsg = 'Please select Temperature.';
         if (input1 == null) errorMsg = 'Please enter valid Length.';
         if (input2 == null) errorMsg = 'Please enter valid Resistance.';
        _result = errorMsg;
        _showCalculationTab = false;
        _showComparisonTab = false;
      });
    }
    FocusScope.of(context).unfocus();
  }

  void _compareResults(double calculatedValue) {
    if (_selectedCableSizeKey != null) {
      double? crMaxValue = _activeCableSizeMap[_selectedCableSizeKey];

      if (crMaxValue != null) {
        int decimalnum = 0;
        String valueString = crMaxValue.toString();
        if (valueString.contains('.')) {
           decimalnum = _getDecimalPlaces(valueString);
        }
        decimalnum = decimalnum.clamp(0, 20);

        if (calculatedValue <= crMaxValue) {
          _comparisonText =
              'Pass. \n\nCalculated CR: ${calculatedValue.toStringAsFixed(decimalnum)} Ω/km. \n\nThe specification maximum is ${crMaxValue.toStringAsFixed(decimalnum)} Ω/km for a $_selectedCableSizeKey cable.';
          _comparisonColor = Colors.green;
          _isPass = true;
        } else {
          _comparisonText =
              'Fail. \n\nCalculated CR: ${calculatedValue.toStringAsFixed(decimalnum)} Ω/km. \n\nThe specification maximum is ${crMaxValue.toStringAsFixed(decimalnum)} Ω/km for a $_selectedCableSizeKey cable.';
          _comparisonColor = Colors.red;
          _isPass = false;
        }
      } else {
        _comparisonText = 'Error: CR Max value not found in active map for selected size.';
        _comparisonColor = Colors.black;
        _isPass = false;
      }
    } else {
      _comparisonText = 'Please select a cable size to compare.';
      _comparisonColor = Colors.black;
      _isPass = false;
    }
  }

  void _resetFields() {
    setState(() {
      _input1Controller.clear();
      _input2Controller.clear();
      _selectedTemperatureKey = null;
      _selectedCableSizeKey = null;
      _selectedCableClass = null;
      _activeCableSizeMap = {};
      _result = null;
      _showCalculationTab = false;
      _showComparisonTab = false;
      _comparisonText = '';
      _comparisonColor = Colors.black;
      _isPass = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conductor Resistance Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column( // Changed outer Row to Column for vertical stacking of input groups
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Resistance Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center, // Center items in row
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _input2Controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15.0),
                              decoration: InputDecoration( // Apply new style
                                labelText: 'R, Measured value:',
                                labelStyle: const TextStyle(fontSize: 15.0),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                              onChanged: (value) => setState(() { _showCalculationTab = false; _showComparisonTab = false; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80, // Consistent width for unit dropdowns
                            child: DropdownButtonFormField<String>( // Changed to DropdownButtonFormField
                              decoration: const InputDecoration(
                                 border: OutlineInputBorder(),
                                 isDense: true,
                                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8), // Adjusted padding
                               ),
                              value: _selectedRUnit,
                              onChanged: (String? newValue) => setState(() { _selectedRUnit = newValue!; _showCalculationTab = false; _showComparisonTab = false; }),
                              items: <String>['Ω', 'mΩ', '-'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15.0)))).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Length Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _input1Controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15.0),
                              decoration: InputDecoration( // Apply new style
                                labelText: 'L, Length of cable:',
                                labelStyle: const TextStyle(fontSize: 15.0),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                              onChanged: (value) => setState(() { _showCalculationTab = false; _showComparisonTab = false; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            child: DropdownButtonFormField<String>( // Changed to DropdownButtonFormField
                              decoration: const InputDecoration(
                                 border: OutlineInputBorder(),
                                 isDense: true,
                                 contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                               ),
                              value: _selectedLengthUnit,
                              onChanged: (String? newValue) => setState(() { _selectedLengthUnit = newValue!; _showCalculationTab = false; _showComparisonTab = false; }),
                              items: <String>['km', 'm'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15.0)))).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Temperature Row
                      SizedBox( // Wrap in SizedBox for consistent width
                        width: 270, // 180 (field) + 10 (space) + 80 (unit)
                        child: DropdownButtonFormField<double>( // Changed to DropdownButtonFormField
                          decoration: InputDecoration( // Apply new style
                            labelText: 'K, Temperature:',
                            labelStyle: const TextStyle(fontSize: 15.0),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          value: _selectedTemperatureKey,
                          hint: const Text('Select Temperature', style: TextStyle(fontSize: 15.0, color: Colors.grey)), // Standard hint
                          isExpanded: true,
                          onChanged: (double? newValue) => setState(() { _selectedTemperatureKey = newValue!; _showCalculationTab = false; _showComparisonTab = false; }),
                          items: _temperatureValues.keys.map<DropdownMenuItem<double>>((key) => DropdownMenuItem<double>(value: key, child: Text('$key °C', style: const TextStyle(fontSize: 15.0)))).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cable Class Dropdown
                       SizedBox(
                        width: 270,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Cable Class:',
                            labelStyle: const TextStyle(fontSize: 15.0),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          value: _selectedCableClass,
                          isExpanded: true,
                          hint: const Text('Select Class', style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCableClass = newValue!;
                              _selectedCableSizeKey = null;
                              if (_selectedCableClass == 'Class 2') {_activeCableSizeMap = _cableSizeValuesClass2;}
                              else if (_selectedCableClass == 'Class 5') {_activeCableSizeMap = _cableSizeValuesClass5;}
                              else if (_selectedCableClass == 'Others') {_activeCableSizeMap = _cableSizeValuesOthers;}
                              else {_activeCableSizeMap = {};}
                              _showCalculationTab = false;
                              _showComparisonTab = false;
                            });
                          },
                          items: <String>['Class 2', 'Class 5', 'Others']
                              .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15.0)))).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Cable Size Dropdown
                      SizedBox(
                        width: 270,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Cable Size:',
                            labelStyle: TextStyle(fontSize: 15.0, color: (_selectedCableClass == null || _activeCableSizeMap.isEmpty) ? Colors.grey.shade500 : null),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          value: _selectedCableSizeKey,
                          hint: Text(_selectedCableClass == null ? 'Select Class first' : 'Select Size', style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                          isExpanded: true,
                          onChanged: (_selectedCableClass == null || _activeCableSizeMap.isEmpty) ? null : (String? newValue) {
                            setState(() {
                              _selectedCableSizeKey = newValue!;
                              _showComparisonTab = false;
                              _showCalculationTab = false;
                            });
                          },
                          items: _activeCableSizeMap.keys
                              .map<DropdownMenuItem<String>>((String key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(key, style: const TextStyle(fontSize: 15.0)), // Display key directly
                                );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action Buttons Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: (_input1Controller.text.isNotEmpty &&
                                       _input2Controller.text.isNotEmpty &&
                                       _selectedTemperatureKey != null &&
                                       _selectedCableClass != null &&
                                       _selectedCableSizeKey != null)
                                ? _calculateProduct
                                : null,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calculate CR', style: TextStyle(fontSize: 16.0)),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(150, 45)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _resetFields,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset', style: TextStyle(fontSize: 16.0)),
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

                // Output Boxes Section
                if (_showCalculationTab)
                  Container(
                    width: 250, // Original width
                    padding: const EdgeInsets.all(16.0,),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Original color
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Calculation:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          '(${_selectedRUnit == 'mΩ' ? (double.tryParse(_input2Controller.text) ?? 0) / 1000 : _input2Controller.text} * ${_temperatureValues[_selectedTemperatureKey]}) / ${_selectedLengthUnit == 'm' ? (double.tryParse(_input1Controller.text) ?? 0) / 1000 : _input1Controller.text} \n= ${_result ?? 'Calculation not available'}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                if (_showComparisonTab)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      width: 250, // Original width
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: _isPass ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: _isPass ? Colors.green : Colors.red),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Result:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(
                            _comparisonText,
                            style: TextStyle(fontSize: 16, color: _comparisonColor),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
