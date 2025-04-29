import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // --- State Variables ---
  String _output = "0"; // The text displayed on the calculator screen
  String _currentInput = ""; // The current number being entered
  String _operand = ""; // The selected operator (+, -, *, /)
  double _num1 = 0; // The first number in the operation

  // --- Button Press Logic ---
  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "CLEAR") {
        // Reset everything
        _output = "0";
        _currentInput = "";
        _operand = "";
        _num1 = 0;
      } else if (buttonText == "+" || buttonText == "-" || buttonText == "×" || buttonText == "÷") {
        // Operator pressed
        if (_currentInput.isNotEmpty) {
          // Store the first number and the operand
          _num1 = double.parse(_currentInput);
          _operand = buttonText;
          _output = _formatOutput(_num1) + _operand; // Show num1 and operand
          _currentInput = ""; // Clear input for the next number
        } else if (_operand.isNotEmpty) {
           // Allow changing operand if no second number entered yet
           _operand = buttonText;
           _output = _formatOutput(_num1) + _operand;
        }
      } else if (buttonText == ".") {
        // Decimal point pressed
        if (!_currentInput.contains(".")) {
          _currentInput += ".";
          _output = _currentInput; // Update display immediately
        }
      } else if (buttonText == "=") {
        // Equals pressed
        if (_currentInput.isNotEmpty && _operand.isNotEmpty) {
          double num2 = double.parse(_currentInput);
          double result = 0;

          // Perform calculation
          try {
             switch (_operand) {
               case "+":
                 result = _num1 + num2;
                 break;
               case "-":
                 result = _num1 - num2;
                 break;
               case "×":
                 result = _num1 * num2;
                 break;
               case "÷":
                 if (num2 == 0) {
                   _output = "Error"; // Handle division by zero
                   _currentInput = "";
                   _operand = "";
                   _num1 = 0;
                   return; // Exit early
                 }
                 result = _num1 / num2;
                 break;
             }
             _output = _formatOutput(result); // Display result
             _num1 = result; // Store result for chained calculations
             _currentInput = _output; // Allow using result as next num1
             _operand = ""; // Clear operand
          } catch (e) {
             _output = "Error"; // Handle potential calculation errors
             _currentInput = "";
             _operand = "";
             _num1 = 0;
          }

        }
      } else {
        // Digit pressed
        if (_output == "0" || _output == "Error") {
           _currentInput = buttonText; // Start new number
        } else if (_operand.isNotEmpty && _currentInput.isEmpty) {
           // Start entering second number after operator
           _currentInput = buttonText;
        }
        else {
           _currentInput += buttonText;
        }
         _output = _currentInput; // Update display
      }
    });
  }

  // Helper to format output (remove .0 for integers)
  String _formatOutput(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    } else {
      // Optional: Limit decimal places if needed
      // return number.toStringAsFixed(2);
      return number.toString();
    }
  }


  // --- UI Build ---

  // Helper function to build calculator buttons
  Widget _buildButton(String buttonText, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? Theme.of(context).textTheme.bodyLarge?.color, // Text color
            backgroundColor: color ?? Theme.of(context).colorScheme.surfaceContainerHighest, // Button background
            padding: const EdgeInsets.all(20.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true, // Optional: Center title
      ),
      body: Column(
        children: <Widget>[
          // Display Area
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            child: Text(
              _output,
              style: const TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1, // Prevent wrapping
              overflow: TextOverflow.ellipsis, // Handle overflow
            ),
          ),
          const Divider(), // Separator
          // Button Grid Area
          Expanded( // Use Expanded to make buttons fill remaining space
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column( // Use Column for rows of buttons
                mainAxisAlignment: MainAxisAlignment.end, // Align buttons to bottom
                children: <Widget>[
                  // Button Row 1
                  Row(
                    children: <Widget>[
                      _buildButton("CLEAR", color: Theme.of(context).colorScheme.secondaryContainer),
                      _buildButton("÷", color: Theme.of(context).colorScheme.tertiaryContainer),
                    ],
                  ),
                  // Button Row 2
                  Row(
                    children: <Widget>[
                      _buildButton("7"),
                      _buildButton("8"),
                      _buildButton("9"),
                      _buildButton("×", color: Theme.of(context).colorScheme.tertiaryContainer),
                    ],
                  ),
                  // Button Row 3
                  Row(
                    children: <Widget>[
                      _buildButton("4"),
                      _buildButton("5"),
                      _buildButton("6"),
                      _buildButton("-", color: Theme.of(context).colorScheme.tertiaryContainer),
                    ],
                  ),
                  // Button Row 4
                  Row(
                    children: <Widget>[
                      _buildButton("1"),
                      _buildButton("2"),
                      _buildButton("3"),
                      _buildButton("+", color: Theme.of(context).colorScheme.tertiaryContainer),
                    ],
                  ),
                  // Button Row 5
                  Row(
                    children: <Widget>[
                      _buildButton("."),
                      _buildButton("0"),
                      _buildButton("=", color: Theme.of(context).colorScheme.primaryContainer),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
