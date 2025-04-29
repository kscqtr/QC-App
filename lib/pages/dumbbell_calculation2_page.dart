import 'package:flutter/material.dart';
// Import the page to return to - ensure this path is correct
// Assuming HotSetDumbbellPage is where you want to return.
// If using named routes, you might not need this import directly for navigation.

class DumbbellCalculation2Page extends StatefulWidget {
  const DumbbellCalculation2Page({super.key});

  @override
  State<DumbbellCalculation2Page> createState() => _DumbbellCalculation2PageState();
}

class _DumbbellCalculation2PageState extends State<DumbbellCalculation2Page> {
  // List to hold controllers for each row (single value Y)
  final List<TextEditingController> _controllers = [];
  // List to hold FocusNodes for each row
  final List<FocusNode> _focusNodes = [];
  // List to hold result strings for each row
  List<String> _rowResults = [];

  // Maximum number of input field rows allowed
  final int _maxRows = 6;
  // Specification threshold for Permanent Elongation
  final double _specification = 15.0;
  // Flag to control visibility of the specification text
  bool _showSpecification = false;


  @override
  void initState() {
    super.initState();
    // Initialize with one row when the page loads
    _addRow();
  }

  @override
  void dispose() {
    // Dispose all controllers and focus nodes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Function to add a new row of input fields
  void _addRow() {
    if (_controllers.length < _maxRows) {
      setState(() {
        // Add single controller and focus node
        _controllers.add(TextEditingController());
        _focusNodes.add(FocusNode());
        _rowResults.add('');
        _showSpecification = false; // Hide spec when rows change
      });
    }
  }

  // Function to remove the last row of input fields
  void _removeRow() {
    if (_controllers.length > 1) {
      // Dispose resources before removing
      _controllers.last.dispose();
      _focusNodes.last.dispose();
      // Remove from lists
      _controllers.removeLast();
      _focusNodes.removeLast();
      _rowResults.removeLast();
       _showSpecification = false; // Hide spec when rows change
    }
  }

  // Function to clear all input fields and reset to one row
  void _resetFields() {
    setState(() {
      // Remove all rows except the first one
      while (_controllers.length > 1) {
         _controllers.last.dispose();
         _focusNodes.last.dispose();
         _controllers.removeLast();
         _focusNodes.removeLast();
         _rowResults.removeLast();
      }
      // Clear the text in the remaining first row
      if (_controllers.isNotEmpty) {
        _controllers[0].clear();
      }
      // Clear the result for the first row
       if (_rowResults.isNotEmpty) {
         _rowResults[0] = '';
       } else if (_controllers.isNotEmpty) {
         _rowResults = [''];
       }
       // Hide specification text on reset
       _showSpecification = false;
    });
  }

  // Function to perform calculation for all rows
  void _calculate() {
     if(_rowResults.length != _controllers.length) {
        _rowResults = List<String>.filled(_controllers.length, '');
     }

    setState(() {
       _showSpecification = true; // Show specification text after calculation
       for (int i = 0; i < _controllers.length; i++) {
        final yText = _controllers[i].text; // Y value text

        if (yText.isEmpty) {
          _rowResults[i] = 'Input is empty';
          continue;
        }

        final double? yValue = double.tryParse(yText); // Parsed Y

        if (yValue == null) {
          _rowResults[i] = 'Error: Invalid number';
          continue;
        }

        // Perform the calculation: [(Y - 2) / 2] * 100
        double result = ((yValue - 2) / 2) * 100;

        // Determine Pass/Fail based on specification (<= 15% is Pass)
        if (result > _specification) {
           _rowResults[i] = 'Result: ${result.toStringAsFixed(2)}% (Fail)';
        } else {
           _rowResults[i] = 'Result: ${result.toStringAsFixed(2)}% (Pass)';
        }
      }
    });
    // Hide keyboard after calculation
    FocusScope.of(context).unfocus();
  }

  // Function to navigate back (assumes specific navigation stack)
  void _navigateBack() {
     // Pop current page (DumbbellCalculation2Page)
     // Pop previous page (DumbbellCalculationPage)
     // This should land back on HotSetDumbbellPage if the flow was
     // HotSetDumbbellPage -> DumbbellCalculationPage -> DumbbellCalculation2Page
     int popCount = 0;
     Navigator.of(context).popUntil((route) {
        return popCount++ == 2; // Pop twice
     });
     // Alternative if using named routes and HotSetDumbbellPage has a known route name:
     // Navigator.popUntil(context, ModalRoute.withName('/hotSetDumbbell'));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dumbbell: Permanent Elongation'), // Updated title
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display Specification conditionally
             Visibility(
               visible: _showSpecification,
               child: Padding(
                 padding: const EdgeInsets.only(bottom: 10.0),
                 child: Text(
                   'Specification: ${_specification.toStringAsFixed(0)}%', // Show spec value (15%)
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                 ),
               ),
             ),

            // Scrollable list for input rows and their results
            Expanded(
              child: ListView.builder(
                itemCount: _controllers.length, // Number of rows
                itemBuilder: (context, index) {
                  final bool hasResult = index < _rowResults.length;
                  final String currentResult = hasResult ? _rowResults[index] : '';

                  // Determine result color based on content
                  Color resultColor = Colors.blueGrey[700]!; // Default color
                  if (currentResult.startsWith('Error:')) {
                     resultColor = Colors.redAccent;
                  } else if (currentResult == 'Input is empty') {
                     resultColor = Colors.grey;
                  } else if (currentResult.contains('(Fail)')) {
                     resultColor = Colors.redAccent;
                  } else if (currentResult.contains('(Pass)')) {
                     resultColor = Colors.green[700]!; // Darker green for pass
                  }


                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row( // Input Row
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Label for the row
                            Text('Sample ${index + 1}: '),
                            // Input field (Y) - Wrapped in SizedBox for width control
                            SizedBox(
                              width: 100, // Adjusted width for single input
                              child: TextField(
                                controller: _controllers[index], // Single controller
                                focusNode: _focusNodes[index], // Single focus node
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: 'Y', // Hint text
                                  isDense: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                ),
                              ),
                            ),
                            // "cm" unit text
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('cm'),
                            ),
                          ],
                        ),
                        // Display Result/Error/Empty message for this row with dynamic color
                        if (hasResult && currentResult.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 70.0), // Indent result
                            child: Text(
                              currentResult,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: resultColor, // Use dynamic color
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- Control Buttons ---

            // Row for Add and Remove buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (_controllers.length > 1)
                    ElevatedButton.icon(
                      // Use setState wrapper for removeRow to trigger rebuild
                      onPressed: () => setState(() => _removeRow()),
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                         minimumSize: const Size(120, 40),
                      ),
                    )
                  else
                    const SizedBox(width: 120, height: 40),

                  if (_controllers.length < _maxRows)
                    ElevatedButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        minimumSize: const Size(120, 40),
                      ),
                    )
                  else
                    const SizedBox(width: 120, height: 40),
                ],
              ),
            ),

            // Row for Calculate and Reset buttons
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.grey[500],
                       minimumSize: const Size(120, 40),
                     ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).primaryColor,
                       foregroundColor: Theme.of(context).colorScheme.onPrimary,
                       minimumSize: const Size(120, 40),
                     ),
                  ),
                ],
              ),
            ),

             // Return Button
             Padding(
               padding: const EdgeInsets.only(top: 15.0), // Add space above the return button
               child: Center( // Center the return button
                 child: ElevatedButton.icon(
                   onPressed: _navigateBack, // Navigate back on press
                   icon: const Icon(Icons.arrow_back), // Back icon
                   label: const Text('Return'), // Changed label
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Colors.grey[600], // Distinct color for return
                     foregroundColor: Colors.white,
                     minimumSize: const Size(150, 45), // Make it slightly larger
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                   ),
                 ),
               ),
             ),

             const SizedBox(height: 5), // Final padding adjusted
          ],
        ),
      ),
    );
  }
}
