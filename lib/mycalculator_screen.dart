import 'package:flutter/material.dart';
import 'package:mycal/button_values.dart';

class MycalculatorScreen extends StatefulWidget {
  const MycalculatorScreen({super.key});

  @override
  State<MycalculatorScreen> createState() => _MycalculatorScreenState();
}

class _MycalculatorScreenState extends State<MycalculatorScreen> {
  String number1 = ""; // . 0-9
  String operand = ""; // + - * /
  String number2 = ""; // .0-9

  // List to store calculation history
  List<String> history = [];
  bool showHistory = false; // Flag to toggle history display

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(showHistory ? Icons.history : Icons.history_toggle_off),
            onPressed: () {
              setState(() {
                showHistory = !showHistory; // Toggle history view
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // History view (shown when showHistory is true)
            if (showHistory) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(history[index]),
                    );
                  },
                ),
              ),
            ],

            // Output
            if (!showHistory) ...[
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "$number1$operand$number2".isEmpty
                          ? "0"
                          : "$number1$operand$number2",
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ),
              ),
            ],

            // Buttons
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.n0
                          ? screenSize.width / 2
                          : screenSize.width / 4,
                      height: screenSize.width / 5,
                      child: buildButton(value),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(value) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(100)),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function for BtnTap
  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }
    if (value == Btn.clr) {
      clearAll();
      return;
    }
    if (value == Btn.per) {
      convertToPercentage();
      return;
    }
    if (value == Btn.calculate) {
      calculate();
      return;
    }

    appendValue(value);
  }

  // Convert output to %
  void convertToPercentage() {
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      calculate();
    }

    if (operand.isNotEmpty) {
      return;
    }

    final number = double.parse(number1);
    setState(() {
      number1 = "${(number / 100)}";
      operand = "";
      number2 = "";
    });
  }

  // Clear all output
  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  // Delete one from the end
  void delete() {
    if (number2.isNotEmpty) {
      number2 = number2.substring(0, number2.length - 1);
    } else if (operand.isNotEmpty) {
      operand = "";
    } else if (number1.isNotEmpty) {
      number1 = number1.substring(0, number1.length - 1);
    }
    setState(() {});
  }

  // ########### Calculate Function ##########
  void calculate() {
    if (number1.isEmpty || operand.isEmpty || number2.isEmpty) return;

    double num1 = double.parse(number1);
    double num2 = double.parse(number2);

    double result = 0.0;

    // Check for division by zero
    if (operand == Btn.divide && num2 == 0) {
      if (num1 == 0) {
        _showErrorMessage("0 cannot be divided by 0");
      } else {
        _showErrorMessage("A number cannot be divided by 0");
      }
      return;
    }

    // Perform the calculation
    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
        return;
    }

    // Limit the result to 10 decimal places and round it
    String resultString =
        result.toStringAsFixed(10); // Round to 10 decimal places

    // Remove trailing zeros if necessary
    if (resultString.endsWith(".0000000000")) {
      resultString = resultString.substring(0, resultString.indexOf('.'));
    } else {
      resultString = resultString.replaceAll(RegExp(r'0+$'), '');
    }

    // Save the calculation to history
    history.insert(0, "$number1 $operand $number2 = $resultString");

    setState(() {
      number1 = resultString;
      operand = "";
      number2 = "";
    });
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ########### Append Value Function ##########
  void appendValue(String value) {
    if (value != Btn.dot && int.tryParse(value) == null) {
      if (operand.isNotEmpty && number2.isNotEmpty) {
        calculate();
      }
      operand = value;
    } else if (number1.isEmpty || operand.isEmpty) {
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        value = "0.";
      }
      number1 += value;
    } else if (number2.isEmpty || operand.isNotEmpty) {
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        return;
      }
      number2 += value;
    }

    setState(() {});
  }

  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? const Color(0xFF0B1B32)
        : [
            Btn.divide,
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.calculate,
          ].contains(value)
            ? const Color.fromARGB(255, 224, 154, 13)
            : const Color(0xFF83A6CE);
  }
}
