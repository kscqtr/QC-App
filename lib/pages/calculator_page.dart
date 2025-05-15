import 'package:flutter/material.dart';
import 'dart:math'; // For sqrt

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // --- State Variables ---
  String _output = "0"; // The text displayed on the calculator screen
  String _currentInput = ""; // The current number being entered or result of unary op
  String _operand = ""; // The selected operator (+, -, ×, ÷)
  double _num1 = 0; // The first number in the operation
  bool _operatorJustPressed = false; // Flag to manage display after operator

  // --- Button Press Logic ---
  void _buttonPressed(String buttonText) {
    setState(() {
      if (_output == "Error" && buttonText != "=" && buttonText != "CLEAR" && buttonText != "DEL") {
        // If it's an error, and the user presses a number, operator, or function,
        // effectively start fresh but keep the button press.
        _clearAll();
        // Let the subsequent logic handle the buttonText on the cleared state
      }

      if (buttonText == "CLEAR") {
        _clearAll();
      } else if (buttonText == "DEL") {
        _deleteLast();
      } else if (_isDigit(buttonText)) {
        _handleDigit(buttonText);
      } else if (buttonText == ".") {
        _handleDecimal();
      } else if (_isOperator(buttonText)) {
        _handleOperator(buttonText);
      } else if (buttonText == "=") {
        _calculateResult();
      } else if (_isFunction(buttonText)) {
        _handleFunction(buttonText);
      }
    });
  }

  // --- Helper Methods for Logic ---

  void _clearAll() {
    _output = "0";
    _currentInput = "";
    _operand = "";
    _num1 = 0;
    _operatorJustPressed = false;
  }

  void _deleteLast() {
    if (_output == "Error") {
      _clearAll();
      return;
    }

    if (_currentInput.isNotEmpty) {
      _currentInput = _currentInput.substring(0, _currentInput.length - 1);
      if (_operand.isEmpty) {
        _output = _currentInput.isEmpty ? "0" : _currentInput;
      } else {
        _output = _formatOutput(_num1) + " " + _operand + (_currentInput.isEmpty ? "" : (" " + _currentInput));
      }
    } else if (_operand.isNotEmpty) { // _currentInput is empty, but there's an operator (e.g. "123 + ")
      _operand = "";
      _currentInput = _formatOutput(_num1); // Put _num1 back into _currentInput
      _output = _currentInput;
      _operatorJustPressed = false;
    } else {
      _output = "0"; // Default to 0 if nothing else to delete
    }
  }

  void _handleDigit(String digit) {
    if (_output == "Error") _clearAll(); // Clear error state before processing digit

    if (_operatorJustPressed) {
      _currentInput = digit; // Start num2
      _operatorJustPressed = false;
    } else {
      // Handle leading zeros
      if (_currentInput == "0" && digit == "0" && !_currentInput.contains(".")) {
        // Do nothing, already "0"
      } else if (_currentInput == "0" && digit != "0" && !_currentInput.contains(".")) {
        _currentInput = digit; // Replace "0" with new digit
      } else if (_currentInput == "-" && _operand.isEmpty) { // For typing negative numbers like "-5"
        _currentInput += digit;
      }
      else {
        _currentInput += digit;
      }
    }

    if (_operand.isEmpty) {
      _output = _currentInput;
    } else {
      _output = _formatOutput(_num1) + " " + _operand + " " + _currentInput;
    }
  }

  void _handleDecimal() {
    if (_output == "Error") _clearAll();

    if (_operatorJustPressed) {
      _currentInput = "0."; // Start num2 with "0."
      _operatorJustPressed = false;
    } else if (!_currentInput.contains(".")) {
      if (_currentInput.isEmpty || _currentInput == "-") { // If empty or just a minus sign
        _currentInput += "0.";
      } else {
        _currentInput += ".";
      }
    }

    if (_operand.isEmpty) {
      _output = _currentInput;
    } else {
      _output = _formatOutput(_num1) + " " + _operand + " " + _currentInput;
    }
  }

  void _handleOperator(String op) {
    if (_output == "Error") { // Don't allow setting an operator if current state is error
        // Optionally, allow operator if _num1 has a valid pre-error value?
        // For now, require clearing error first or inputting a new number.
        return;
    }

    // If _currentInput has a value (it's num1 or the result of a previous operation)
    if (_currentInput.isNotEmpty) {
      // And if an operand is already active and we're not just changing it (e.g. 5 + 3 then press -)
      if (_operand.isNotEmpty && !_operatorJustPressed) {
        _calculateResult(isChainedOperation: true); // Calculate num1 op num2
        // If calculation resulted in error, _output is "Error", _currentInput might be cleared
        if (_output == "Error") return;
        // After calculation, _num1 has the result, _currentInput has the result string.
      }
      // The value in _currentInput (either original num1, or result of chained op) becomes the new _num1
      // Ensure _currentInput is a valid number string before parsing
      if (double.tryParse(_currentInput) != null) {
        _num1 = double.parse(_currentInput);
      } else if (_currentInput == "" && _num1 != 0) {
        // This case might happen if DEL cleared _currentInput but _num1 is set
        // and user presses an operator. _num1 is already correct.
      } else {
         // _currentInput is not a valid number (e.g. just "-"), or some other edge case.
         // Potentially show error or reset. For now, if it's not parseable, don't update _num1
         // unless _num1 was already valid.
         if (_num1 == 0 && _currentInput.isEmpty) { /* Allow 0 + type ops */ }
         else if (_currentInput.isNotEmpty) { /* _currentInput not parseable, maybe error? */ return; }

      }

    } else if (_operand.isNotEmpty && _currentInput.isEmpty) {
      // This case is for changing operator: e.g., "5 +" then user presses "*"
      // _num1 is already set. We just change the operand below.
      // _operatorJustPressed will be true here.
    } else if (_currentInput.isEmpty && _operand.isEmpty) {
      // Pressing an operator at the very start or after CLEAR.
      // _num1 is 0, _currentInput is "".
      // We want display "0 op". _num1 = 0 is fine.
    }


    _operand = op;
    _output = _formatOutput(_num1) + " " + _operand;
    _currentInput = ""; // Ready for the second number
    _operatorJustPressed = true;
  }

  void _calculateResult({bool isChainedOperation = false}) {
    if (_currentInput.isNotEmpty && _operand.isNotEmpty && _currentInput != "Error") {
      // Ensure _currentInput is parseable before proceeding
      double? num2 = double.tryParse(_currentInput);
      if (num2 == null) {
        // _output = "Error"; // Or handle as invalid input for num2
        return; // Don't proceed if num2 is not a valid number
      }

      double result = 0;
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
              _output = "Error";
              _currentInput = "";
              // _operand = ""; // Keep operand or clear?
              // _num1 = 0; // Keep num1 or clear?
              _operatorJustPressed = false; // Reset this flag on error
              return;
            }
            result = _num1 / num2;
            break;
        }
        _output = _formatOutput(result);
        _num1 = result;
        _currentInput = _output; // Result becomes current input
        if (!isChainedOperation) {
          _operand = ""; // Clear operand only on final "="
        }
        _operatorJustPressed = false;
      } catch (e) {
        _output = "Error";
        _currentInput = "";
        // _operand = "";
        // _num1 = 0;
        _operatorJustPressed = false;
      }
    } else if (_operand.isNotEmpty && _currentInput.isEmpty && !isChainedOperation) {
      // Case like "5 * =" -> use _num1 as num2 (5*5)
      if (_num1 != 0 || _operand == "+" || _operand == "-") { // Allow 0+0 or 0-0
        double num2 = _num1;
        double result = 0;
        try {
          switch (_operand) {
            case "+": result = _num1 + num2; break;
            case "-": result = _num1 - num2; break;
            case "×": result = _num1 * num2; break;
            case "÷":
              if (num2 == 0) { _output = "Error"; _currentInput = ""; _operatorJustPressed = false; return; }
              result = _num1 / num2; break;
          }
          _output = _formatOutput(result);
          _num1 = result;
          _currentInput = _output;
          if (!isChainedOperation) _operand = "";
          _operatorJustPressed = false;
        } catch (e) {
          _output = "Error"; _currentInput = ""; _operatorJustPressed = false;
        }
      }
    }
  }

  void _handleFunction(String func) {
    if (_output == "Error" && func != "+/-") { // Allow +/- to attempt to clear error by making num negative
         if (func == "+/-" && _num1 != 0) {
            // Try to recover from error if _num1 is valid by negating it
            _num1 *= -1;
            _currentInput = _formatOutput(_num1);
            _output = _operand.isEmpty ? _currentInput : _formatOutput(_num1) + " " + _operand;
            _operatorJustPressed = _operand.isNotEmpty;
            return;
         }
         return; // Don't operate on error state for other functions
    }


    double valToOperateOn;
    bool operateOnNum1 = false;

    // Determine what value the function should operate on
    if (_currentInput.isNotEmpty && double.tryParse(_currentInput) != null) {
        valToOperateOn = double.parse(_currentInput);
    } else if (_operand.isNotEmpty && _currentInput.isEmpty && !_operatorJustPressed) {
        // e.g. "5 + " then user presses "√" -> operate on _num1 (5)
        valToOperateOn = _num1;
        operateOnNum1 = true; // Flag that we modified _num1 effectively
    } else if (_currentInput.isEmpty && _operand.isEmpty && double.tryParse(_output) != null) {
        // After "=", output contains result, currentInput is also result.
        // Or after CLEAR, output is "0".
        valToOperateOn = double.parse(_output);
    }
     else { // Fallback or if _currentInput is just "-"
        if (func == "+/-" && _currentInput == "-") { // If current input is just "-", make it empty for +/- logic
            _currentInput = ""; valToOperateOn = 0;
        } else if (func == "+/-") {
            valToOperateOn = 0; // +/- on empty or "0"
        }
        else {
            return; // Not enough valid input for other functions
        }
    }


    String tempResultString = "";

    switch (func) {
      case "+/-":
        valToOperateOn *= -1;
        tempResultString = _formatOutput(valToOperateOn);
        if (operateOnNum1) {
            _num1 = valToOperateOn; // Update _num1 if it was the target
            _output = _formatOutput(_num1) + " " + _operand;
            _currentInput = ""; // Keep _currentInput empty as we are waiting for num2
            _operatorJustPressed = true; // Operator is still active
        } else {
            _currentInput = tempResultString;
            _output = _operand.isEmpty ? _currentInput : _formatOutput(_num1) + " " + _operand + " " + _currentInput;
            _operatorJustPressed = false;
        }
        break;
      case "%":
        if (operateOnNum1) { // e.g. 5 + then % -> 5 + (5 * 0.01) - this is not standard.
                             // Standard: 5 + X then % on X => 5 + (X/100)
                             // Or 5 then % => 0.05
            // Let's assume % applies to the current number or the second number in an operation
            return; // Avoid ambiguous % on _num1 directly this way
        }
        valToOperateOn /= 100;
        _currentInput = _formatOutput(valToOperateOn);
        _output = _operand.isEmpty ? _currentInput : _formatOutput(_num1) + " " + _operand + " " + _currentInput;
        _operatorJustPressed = false;
        break;
      case "x²":
        valToOperateOn = valToOperateOn * valToOperateOn;
        tempResultString = _formatOutput(valToOperateOn);
         if (operateOnNum1) {
            _num1 = valToOperateOn;
            _output = _formatOutput(_num1) + " " + _operand;
            _currentInput = "";
            _operatorJustPressed = true;
        } else {
            _currentInput = tempResultString;
            _output = _operand.isEmpty ? _currentInput : _formatOutput(_num1) + " " + _operand + " " + _currentInput;
            _operatorJustPressed = false;
        }
        break;
      case "√":
        if (valToOperateOn < 0) {
          _output = "Error";
          _currentInput = "";
          _operatorJustPressed = false;
        } else {
          valToOperateOn = sqrt(valToOperateOn);
          tempResultString = _formatOutput(valToOperateOn);
          if (operateOnNum1) {
            _num1 = valToOperateOn;
            _output = _formatOutput(_num1) + " " + _operand;
            _currentInput = "";
            _operatorJustPressed = true;
          } else {
            _currentInput = tempResultString;
             _output = _operand.isEmpty ? _currentInput : _formatOutput(_num1) + " " + _operand + " " + _currentInput;
            _operatorJustPressed = false;
          }
        }
        break;
    }
  }

  bool _isDigit(String s) => double.tryParse(s) != null;
  bool _isOperator(String s) => s == "+" || s == "-" || s == "×" || s == "÷";
  bool _isFunction(String s) => s == "+/-" || s == "%" || s == "x²" || s == "√";

  String _formatOutput(double number) {
    if (number.isNaN || number.isInfinite) {
      // This should ideally be caught earlier and result in "Error" state
      // but as a safeguard for formatting:
      return "Error";
    }

    // Use scientific notation for very large or very small numbers
    if (number.abs() > 999999999999.0 || (number.abs() < 0.000000001 && number != 0)) {
      return number.toStringAsExponential(7);
    }

    if (number == number.toInt()) {
      // Prevent -0 display, show 0 instead
      if (number == 0 && number.isNegative) return "0";
      return number.toInt().toString();
    } else {
      String s = number.toString();
      // Further precision control for non-integer, non-scientific numbers
      if (s.contains('.') && s.length > 15) {
        try {
          int decimalPointIndex = s.indexOf('.');
          // Count integer digits, considering negative sign
          int integerDigits = number.isNegative ? decimalPointIndex -1 : decimalPointIndex;
          if (number.truncate().abs() == 0 && number != 0) integerDigits = 0;


          int desiredDecimalPlaces = 12 - integerDigits;
          if (desiredDecimalPlaces < 2) desiredDecimalPlaces = 2;
          if (desiredDecimalPlaces > 8) desiredDecimalPlaces = 8;

          String formatted = number.toStringAsFixed(desiredDecimalPlaces);
          // Remove trailing zeros from decimal part if any, but keep .0 if it's like 12.0
          // if (formatted.contains('.')) {
          //   formatted = formatted.replaceAll(RegExp(r'0*$'), '');
          //   if (formatted.endsWith('.')) {
          //     formatted = formatted.substring(0, formatted.length - 1);
          //   }
          // }
          return formatted;
        } catch (e) {
          return s; // Fallback
        }
      }
      return s;
    }
  }

  // --- UI Build ---
  Widget _buildButton(String buttonText, {Color? color, Color? textColor, int flex = 1}) {
    Color defaultTextColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
    Color btnColor = color ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    TextStyle buttonTextStyle = TextStyle(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      color: textColor ?? defaultTextColor,
    );

    if (_isOperator(buttonText) || buttonText == "=") {
      btnColor = color ?? Theme.of(context).colorScheme.primary;
      buttonTextStyle = buttonTextStyle.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontSize: 26);
    } else if (_isFunction(buttonText) || buttonText == "DEL") {
      btnColor = color ?? Theme.of(context).colorScheme.secondaryContainer; // A distinct color for functions
      buttonTextStyle = buttonTextStyle.copyWith(color: Theme.of(context).colorScheme.onSecondaryContainer);
    } else if (buttonText == "CLEAR") {
      btnColor = color ?? Theme.of(context).colorScheme.errorContainer;
      buttonTextStyle = buttonTextStyle.copyWith(color: Theme.of(context).colorScheme.onErrorContainer);
    }


    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: buttonTextStyle.color,
            padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 8.0), // Adjusted for potentially smaller screens
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 2.0,
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: buttonTextStyle,
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
        centerTitle: true,
      ),
      body: SafeArea( // Ensure content is within safe area (e.g. notches)
        child: SingleChildScrollView( // Make the whole body scrollable
          child: ConstrainedBox( // Ensure the column takes at least screen height if content is short
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - (AppBar().preferredSize.height) - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Pushes buttons to bottom if content is short
              children: <Widget>[
                // Display Area
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _output,
                      style: TextStyle(
                        fontSize: _output.length > 12 ? 38.0 : (_output.length > 8 ? 46.0 : 52.0), // Dynamic font size
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                // Button Grid Area
                Padding( // Moved Divider and Padding for buttons here
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    // Removed mainAxisAlignment.end as ConstrainedBox and SpaceBetween handles it
                    children: <Widget>[
                      const Divider(height: 1, thickness: 1),
                      const SizedBox(height: 10), // Space after divider
                      Row(
                        children: <Widget>[
                          _buildButton("CLEAR", flex: 2),
                          _buildButton("DEL"),
                          _buildButton("÷"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          _buildButton("x²"),
                          _buildButton("√"),
                          _buildButton("%"),
                          _buildButton("×"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          _buildButton("7"),
                          _buildButton("8"),
                          _buildButton("9"),
                          _buildButton("-"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          _buildButton("4"),
                          _buildButton("5"),
                          _buildButton("6"),
                          _buildButton("+"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: <Widget>[
                          _buildButton("1"),
                          _buildButton("2"),
                          _buildButton("3"),
                          _buildButton("=", flex: 1),
                        ],
                      ),
                      const SizedBox(height: 5),
                       Row(
                        children: <Widget>[
                          _buildButton("+/-"),
                          _buildButton("0", flex: 2),
                          _buildButton("."),
                          // Removed equals from here, it's on the row above
                        ],
                      ),
                    ],
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
