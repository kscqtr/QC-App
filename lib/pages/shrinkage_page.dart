import 'package:flutter/material.dart';

class ShrinkagePage extends StatefulWidget {
  const ShrinkagePage({super.key});

  @override
  ShrinkagePageState createState() => ShrinkagePageState();
}

class ShrinkagePageState extends State<ShrinkagePage> {
  final TextEditingController _l1Controller = TextEditingController();
  final TextEditingController _l2Controller = TextEditingController();
  String? _resultL1;
  String? _resultL2;
  bool _isPassL1 = true;
  bool _isPassL2 = true;
  bool _showSecondInput = false;
  bool _showCalculationTab = false; // Track if calculation is done

  void _calculateShrinkage() {
    double? l1 = double.tryParse(_l1Controller.text);
    double? l2 = _showSecondInput ? double.tryParse(_l2Controller.text) : null;

    if (l1 != null && (_showSecondInput ? l2 != null : true)) {
      double shrinkageL1 = ((20 - l1) / 20) * 100;
      double truncatedShrinkageL1 = (shrinkageL1 * 10000).truncateToDouble() / 10000.0;
      String statusL1 = truncatedShrinkageL1 <= 4 ? 'Pass' : 'Fail';

      double? shrinkageL2;
      String? statusL2;

    if (_showSecondInput && l2 != null) {
      shrinkageL2 = ((20 - l2) / 20) * 100;
      double truncatedShrinkageL2 = (shrinkageL2 * 10000).truncateToDouble() / 10000.0;
      statusL2 = truncatedShrinkageL2 <= 4 ? 'Pass' : 'Fail';
    }

      setState(() {
        _resultL1 =
            'Calculation: \n((20 - L1) / 20) * 100%\n\nShrinkage: ${shrinkageL1.toStringAsFixed(1)}%\n\nResult: $statusL1';
        _isPassL1 = statusL1 == 'Pass';

        if (_showSecondInput && shrinkageL2 != null && statusL2 != null) {
          _resultL2 =
              'Calculation: \n((20 - L2) / 20) * 100%\n\nShrinkage: ${shrinkageL2.toStringAsFixed(1)}%\n\nResult: $statusL2';
          _isPassL2 = statusL2 == 'Pass';
        } else {
          _resultL2 = null;
        }
        _showCalculationTab =
            true; // Show the calculation tab after pressing calculate
      });
    } else {
      setState(() {
        _resultL1 = 'Please enter valid numbers.';
        _resultL2 = null;
        _isPassL1 = true;
        _isPassL2 = true;
        _showCalculationTab =
            false; // Hide the calculation tab if input is invalid
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shrinkage Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Input Fields Section
                Padding(
                  padding: const EdgeInsets.only(top: 30.0), // Added padding here
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 265,
                                child: TextField(
                                  controller: _l1Controller,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 15.0), // Input text size
                                  decoration: const InputDecoration(
                                      labelText:
                                          'Measured length of L1 (in cm)',
                                      labelStyle: TextStyle(fontSize: 15.0), // Label font size
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _showCalculationTab = false;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(_showSecondInput
                                    ? Icons.remove
                                    : Icons.add),
                                onPressed: () {
                                  setState(() {
                                    _showSecondInput = !_showSecondInput;
                                    _showCalculationTab =
                                        false; //hide calculation when add/remove L2
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_showSecondInput) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 265,
                                  child: TextField(
                                    controller: _l2Controller,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 15.0), // Input text size
                                    decoration: const InputDecoration(
                                        labelText:
                                            'Measured length of L2 (in cm)',
                                        labelStyle: TextStyle(fontSize: 15.0), // Label font size
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _showCalculationTab = false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        45), // To align with the IconButton space
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.calculate),
                                label: const Text('Calculate'),
                                onPressed: _calculateShrinkage,
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[500],
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  minimumSize: const Size(120, 40),
                                ),
                                onPressed: () {
                                
                                  setState(() {
                                    _l1Controller.clear();
                                    _l2Controller.clear();
                                    _resultL1 = null;
                                    _resultL2 = null;
                                    _isPassL1 = true;
                                    _isPassL2 = true;
                                    _showSecondInput = false;
                                    _showCalculationTab =
                                        false; // Hide the calculation tab when resetting
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Output Boxes Section
                if (_showCalculationTab)
                  Column(
                    children: [
                      Container(
                        width: 250,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: _isPassL1 ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: _isPassL1 ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('L1:',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(
                              _resultL1 ?? 'No result yet.',
                              style: TextStyle(
                                fontSize: 16,
                                color: _isPassL1 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showSecondInput) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: _isPassL2 ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: _isPassL2 ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('L2:',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Text(
                                _resultL2 ?? 'No result yet.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _isPassL2 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

