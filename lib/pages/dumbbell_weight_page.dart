import 'package:flutter/material.dart';

class DumbbellWeightPage extends StatefulWidget {
  const DumbbellWeightPage({super.key});

  @override
  State<DumbbellWeightPage> createState() => _DumbbellWeightPageState();
}

class _DumbbellWeightPageState extends State<DumbbellWeightPage> {
  // --- ADDED: Controller and FocusNode for Width Input ---
  final TextEditingController _widthController = TextEditingController();
  final FocusNode _widthFocusNode = FocusNode();
  // --- End Addition ---

  // List to hold controllers for each row (T - Thickness)
  final List<TextEditingController> _thicknessControllers = [];
  // List to hold FocusNodes for each row
  final List<FocusNode> _thicknessFocusNodes = [];
  // List to hold result pairs [Area, Weight] strings for each row
  List<List<String>> _rowResults = [];

  // Maximum number of input field rows allowed
  final int _maxRows = 6;

  // Constant for weight calculation
  final double _weightFactor = 20.387;

  // State for image visibility
  bool _showImage = false;
  final String _imagePath = 'images/dumbbell_conversion.png';


  @override
  void initState() {
    super.initState();
    // Initialize with one row when the page loads
    _addRow();
  }

  @override
  void dispose() {
    // --- ADDED: Dispose new controller/focus node ---
    _widthController.dispose();
    _widthFocusNode.dispose();
    // --- End Addition ---

    // Dispose all thickness controllers and focus nodes
    for (var controller in _thicknessControllers) {
      controller.dispose();
    }
    for (var focusNode in _thicknessFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Function to add a new row of input fields
  void _addRow() {
    if (_thicknessControllers.length < _maxRows) {
      setState(() {
        _thicknessControllers.add(TextEditingController());
        _thicknessFocusNodes.add(FocusNode());
        // Ensure results list grows with controllers
        while (_rowResults.length < _thicknessControllers.length) {
             _rowResults.add(['', '']);
        }
      });
    }
  }

   // Function to toggle image visibility
  void _toggleImageVisibility() {
    setState(() {
      _showImage = !_showImage;
    });
  }


  // Function to remove the last row of input fields
  void _removeRow() {
    if (_thicknessControllers.length > 1) {
      setState(() {
          _thicknessControllers.last.dispose();
          _thicknessFocusNodes.last.dispose();
          _thicknessControllers.removeLast();
          _thicknessFocusNodes.removeLast();
          if (_rowResults.length > 1) {
             _rowResults.removeLast();
          }
      });
    }
  }

  // Function to clear all input fields and reset to one row
  void _resetFields() {
    setState(() {
      // --- ADDED: Clear width controller ---
      _widthController.clear();
      // --- End Addition ---

      while (_thicknessControllers.length > 1) {
         _thicknessControllers.last.dispose();
         _thicknessFocusNodes.last.dispose();
         _thicknessControllers.removeLast();
         _thicknessFocusNodes.removeLast();
         if (_rowResults.length > 1) {
             _rowResults.removeLast();
         }
      }
      if (_thicknessControllers.isNotEmpty) {
        _thicknessControllers[0].clear();
      }
       if (_rowResults.isNotEmpty) {
         _rowResults[0] = ['', ''];
       } else if (_thicknessControllers.isNotEmpty) {
         _rowResults = [['', '']];
       }
       _showImage = false; // Also hide image on reset
    });
  }

  // Function to perform calculation for all rows
  void _calculate() {
    // --- ADDED: Parse and validate Width (W) ---
    final String wText = _widthController.text;
    if (wText.isEmpty) {
      // Show error message if width is empty - maybe use a SnackBar or dedicated error field
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please enter Width (W).'), backgroundColor: Colors.orange)
       );
       return; // Stop calculation
    }
    final double? wValue = double.tryParse(wText);
    if (wValue == null || wValue <= 0) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Please enter a valid positive Width (W).'), backgroundColor: Colors.orange)
       );
       return; // Stop calculation
    }
    // --- End Width Parsing/Validation ---


     // Ensure results list matches controller list length and structure
     if(_rowResults.length != _thicknessControllers.length) {
        _rowResults = List<List<String>>.generate(_thicknessControllers.length, (_) => ['', ''], growable: true);
     } else {
        for(int i=0; i < _rowResults.length; i++) {
            if (_rowResults[i].length != 2) _rowResults[i] = ['', ''];
        }
     }


    setState(() {
       for (int i = 0; i < _thicknessControllers.length; i++) {
         final tText = _thicknessControllers[i].text;

         if (tText.isEmpty) {
           _rowResults[i] = ['Input is empty', ''];
           continue;
         }

         final double? tValue = double.tryParse(tText);

         if (tValue == null) {
           _rowResults[i] = ['Error: Invalid number', ''];
           continue;
         }

         if (tValue <= 0) {
            _rowResults[i] = ['Error: T must be > 0', ''];
            continue;
         }

         // --- MODIFIED: Use parsed wValue instead of _fixedWidthW ---
         double area = wValue * tValue;
         double weight = area * _weightFactor;
         // --- End Modification ---

         // --- MODIFIED: Update result string to show entered width ---
         _rowResults[i] = [
           'Area: ${wValue.toStringAsFixed(2)} mm x ${tValue.toStringAsFixed(2)} mm = ${area.toStringAsFixed(2)} mm²', // Show W value
           'Mass: ${area.toStringAsFixed(2)} mm² x 20.387 = ${weight.toStringAsFixed(2)} g'
         ];
         // --- End Modification ---
     }
    });
    FocusScope.of(context).unfocus();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dumbbell: Weight Calculation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( // Main column for the page layout
          children: [
            // --- ADDED: Width Input Field ---
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, top: 10.0), // Add some padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Center the row
                children: [
                  SizedBox(
                    width: 100, // Adjust width as needed
                    child: TextField(
                      controller: _widthController,
                      focusNode: _widthFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15.0),
                      decoration: InputDecoration(
                        labelStyle: const TextStyle(fontSize: 15.0),
                        hintText: 'Width',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // Adjust padding
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('mm'),
                  ),
                ],
              ),
            ),
            // --- End Width Input Field ---

            // Scrollable list for input rows and their results
            Expanded(
              child: ListView.builder(
                itemCount: _thicknessControllers.length,
                itemBuilder: (context, index) {
                  final bool hasResult = index < _rowResults.length && _rowResults[index].length == 2;
                  final String areaResult = hasResult ? _rowResults[index][0] : '';
                  final String weightResult = hasResult ? _rowResults[index][1] : '';
                  final bool isErrorOrEmpty = areaResult.startsWith('Error:') || areaResult == 'Input is empty';

                  Color resultColor1 = Colors.grey;
                   if (areaResult.startsWith('Error:')) {resultColor1 = Colors.redAccent;}
                   else if (areaResult.startsWith('Area:')) {resultColor1 = Colors.blueGrey[700]!;}

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row( // Input Row
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Sample ${index + 1}: ', style: const TextStyle(fontWeight: FontWeight.w500)),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _thicknessControllers[index],
                                focusNode: _thicknessFocusNodes[index],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 15.0), // User requested 15.0
                                decoration: InputDecoration(
                                  hintText: 'Thickness', // Changed from 'T'
                                  hintStyle: const TextStyle(fontSize: 15.0, color: Colors.grey), // Style hint
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8)
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('mm'),
                            ),
                          ],
                        ),
                        // Display Area Result/Error/Empty message
                        if (hasResult && areaResult.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Center(
                              child: RichText( // Use RichText for bolding
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: resultColor1),
                                  children: <TextSpan>[
                                    if (areaResult.startsWith('Area:')) ...[
                                      const TextSpan(text: 'Area: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: areaResult.substring(6)),
                                    ] else TextSpan(text: areaResult), // Handle errors/empty
                                  ],
                                ),
                              ),
                            ),
                          ),
                        // Display Weight Result
                        if (hasResult && weightResult.isNotEmpty && !isErrorOrEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Center(
                              child: RichText( // Use RichText for bolding
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.purple[700]),
                                  children: <TextSpan>[
                                     if (weightResult.startsWith('Mass:')) ...[
                                      const TextSpan(text: 'Mass: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: weightResult.substring(6)),
                                    ] else TextSpan(text: weightResult), // Handle potential errors?
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ), // End Expanded ListView

            // Visibility widget for Image
            Visibility(
              visible: _showImage,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Container(
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.black, width: 1.0),
                   ),
                   child: Image.asset(
                     _imagePath,
                     height: 150,
                     errorBuilder: (context, error, stackTrace) {
                       return const Text('Error loading image.', style: TextStyle(color: Colors.red));
                     },
                   ),
                 ),
              ),
            ),

            // Control Buttons (Add/Remove)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (_thicknessControllers.length > 1)
                    ElevatedButton.icon(
                      onPressed: _removeRow,
                      icon: const Icon(Icons.remove),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, minimumSize: const Size(120, 40)),
                    )
                  else
                    const SizedBox(width: 120, height: 40),

                  if (_thicknessControllers.length < _maxRows)
                    ElevatedButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.lightGreen, minimumSize: const Size(120, 40)),
                    )
                  else
                    const SizedBox(width: 120, height: 40),
                ],
              ),
            ),

            // Control Buttons (Reset/Calculate)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _resetFields,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[400], minimumSize: const Size(120, 40)),
                  ),
                  ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('Calculate'),
                     style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Theme.of(context).colorScheme.onPrimary, minimumSize: const Size(120, 40)),
                  ),
                ],
              ),
            ),

            // Image Button
             Padding(
               padding: const EdgeInsets.only(top: 0, bottom: 10),
               child: Center(
                 child: ElevatedButton.icon(
                   onPressed: _toggleImageVisibility,
                   icon: const Icon(Icons.image),
                   label: const Text('Image'),
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, minimumSize: const Size(150, 45), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                 ),
               ),
             ),
          ],
        ),
      ),
    );
  }
}
