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
  
  Map<String, String> _resultsMap = {};
  bool _showResultTab = false;
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

  Map<String, double> _activeCableSizeMap = {};
  String? _selectedCableSizeKey;
  double? _selectedTemperatureKey;

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

    if (input1 != null && input2 != null && input3 != null) {
      double length = input1;
      if (_selectedLengthUnit == 'm') length /= 1000;
      if (length == 0) {
          setState(() { 
            _resultsMap = {'Error': 'Length cannot be zero.'}; 
            _isPass = false;
            _showResultTab = true; 
          });
          return;
      }

      double resistance = input2;
      if (_selectedRUnit == 'mΩ') resistance /= 1000;

      double product = (resistance * input3) / length;
      String formulaString = '(${resistance.toString()} * ${input3.toString()}) / ${length.toString()}';

      if (input4 != null) {
        bool isPass = product <= input4;
        int decimalnum = _getDecimalPlaces(input4.toString()).clamp(0, 20);

        setState(() {
          _isPass = isPass;
          _resultsMap = {
            'Calculation': formulaString,
            'Calculated CR': '${product.toStringAsFixed(decimalnum)} Ω/km',
            'Specification Max': '${input4.toStringAsFixed(decimalnum)} Ω/km',
            'Result': isPass ? 'Pass' : 'Fail',
          };
          _showResultTab = true;
        });
      } else {
        setState(() {
          _isPass = true;
          _resultsMap = {
            'Calculation': formulaString,
            'Calculated CR': '${product.toStringAsFixed(4)} Ω/km',
            'Specification Max': '-',
            'Result': '-',
          };
          _showResultTab = true;
        });
      }
    } else {
      // --- MODIFIED: This block now also shows a SnackBar pop-up ---
      String errorMsg;
      if (input2 == null) {
        errorMsg = 'Please enter valid Resistance.';
      } else if (input1 == null) {
        errorMsg = 'Please enter valid Length.';
      } else {
        errorMsg = 'Please select Temperature.';
      }

      // Show the pop-up error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red.shade700,
        ),
      );
      
      // Also display the error in the results box
      setState(() {
        _resultsMap = {'Error': errorMsg};
        _isPass = false;
        _showResultTab = true;
      });
    }
    FocusScope.of(context).unfocus();
  }

  void _resetFields() {
    setState(() {
      _input1Controller.clear();
      _input2Controller.clear();
      _selectedTemperatureKey = null;
      _selectedCableSizeKey = null;
      _selectedCableClass = null;
      _activeCableSizeMap = {};
      _resultsMap = {};
      _showResultTab = false;
      _isPass = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    final errorStyle = boldStyle.copyWith(color: Colors.red.shade700, fontSize: 16);
    final resultLabelStyle = const TextStyle(fontSize: 15, color: Colors.black87).copyWith(fontSize: 14, fontWeight: FontWeight.w500);
    final resultValueStyle = const TextStyle(fontSize: 15, color: Colors.black87).copyWith(fontSize: 14);

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _input2Controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15.0),
                              decoration: InputDecoration(
                                labelText: 'R, Measured value:',
                                labelStyle: const TextStyle(fontSize: 15.0),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                              onChanged: (value) => setState(() { _showResultTab = false; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              value: _selectedRUnit,
                              onChanged: (String? newValue) => setState(() { _selectedRUnit = newValue!; _showResultTab = false; }),
                              items: <String>['Ω', 'mΩ', '-'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15.0)))).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _input1Controller,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 15.0),
                              decoration: InputDecoration(
                                labelText: 'L, Length of cable:',
                                labelStyle: const TextStyle(fontSize: 15.0),
                                border: const OutlineInputBorder(),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                              onChanged: (value) => setState(() { _showResultTab = false; }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                              value: _selectedLengthUnit,
                              onChanged: (String? newValue) => setState(() { _selectedLengthUnit = newValue!; _showResultTab = false; }),
                              items: <String>['km', 'm'].map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15.0)))).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 270,
                        child: DropdownButtonFormField<double>(
                          decoration: InputDecoration(
                            labelText: 'K, Temperature:',
                            labelStyle: const TextStyle(fontSize: 15.0),
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                          value: _selectedTemperatureKey,
                          hint: const Text('Select Temperature', style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                          isExpanded: true,
                          onChanged: (double? newValue) => setState(() { _selectedTemperatureKey = newValue!; _showResultTab = false; }),
                          items: _temperatureValues.keys.map<DropdownMenuItem<double>>((key) => DropdownMenuItem<double>(value: key, child: Text('$key °C', style: const TextStyle(fontSize: 15.0)))).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                              _showResultTab = false;
                            });
                          },
                          items: <String>['Class 2', 'Class 5', 'Others']
                              .map<DropdownMenuItem<String>>((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 15.0)))).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                          hint: Text(_selectedCableClass == null ? 'Select Class first' : 'Select Size', style: const TextStyle(fontSize: 15.0, color: Colors.grey)),
                          isExpanded: true,
                          onChanged: (_selectedCableClass == null || _activeCableSizeMap.isEmpty) ? null : (String? newValue) {
                            setState(() {
                              _selectedCableSizeKey = newValue!;
                              _showResultTab = false;
                            });
                          },
                          items: _activeCableSizeMap.keys
                              .map<DropdownMenuItem<String>>((String key) {
                                return DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(key, style: const TextStyle(fontSize: 15.0)),
                                );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            // --- MODIFIED: Button is now always pressable ---
                            onPressed: _calculateProduct,
                            icon: const Icon(Icons.calculate),
                            label: const Text('Calculate CR'),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(150, 45)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _resetFields,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
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

                AnimatedOpacity(
                  opacity: _showResultTab ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: _showResultTab
                      ? Container(
                          constraints: const BoxConstraints(maxWidth: 380),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _isPass ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: _isPass ? Colors.green.shade300 : Colors.red.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _resultsMap.containsKey('Error') ? 'Error:' : 'Results:',
                                style: _resultsMap.containsKey('Error') ? errorStyle : boldStyle,
                              ),
                              if (_resultsMap.containsKey('Calculation')) ...[
                                const SizedBox(height: 8),
                                Text('Calculation: ${_resultsMap['Calculation']}', style: resultValueStyle),
                                const Divider(height: 16, thickness: 1),
                              ],
                              ..._resultsMap.entries
                                .where((entry) => entry.key != 'Calculation' && entry.key != 'Error')
                                .map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${entry.key}:', style: resultLabelStyle),
                                        Text(
                                          entry.value, 
                                          style: entry.key == 'Result' 
                                            ? boldStyle.copyWith(color: _isPass ? Colors.green.shade800 : Colors.red.shade800)
                                            : resultValueStyle,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              if (_resultsMap.containsKey('Error'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(_resultsMap['Error']!, style: errorStyle.copyWith(fontSize: 14)),
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
