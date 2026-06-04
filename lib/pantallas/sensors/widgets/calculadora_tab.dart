import 'package:flutter/material.dart';

class CalculadoraTab extends StatefulWidget {
  const CalculadoraTab({super.key});

  @override
  State<CalculadoraTab> createState() => _CalculadoraTabState();
}

class _CalculadoraTabState extends State<CalculadoraTab> {
  String _calcDisplay = "0";
  double? _firstValue;
  String? _operator;
  bool _shouldResetDisplay = false;

  void _onKeypadPressed(String key) {
    setState(() {
      if (key == "C") {
        _calcDisplay = "0"; _firstValue = null; _operator = null;
      } else if (key == "+" || key == "-" || key == "×" || key == "÷") {
        _firstValue = double.tryParse(_calcDisplay);
        _operator = key; _shouldResetDisplay = true;
      } else if (key == "=") {
        if (_operator == null || _firstValue == null) return;
        double secondValue = double.tryParse(_calcDisplay) ?? 0;
        double resultado = 0;
        switch (_operator) {
          case "+": resultado = _firstValue! + secondValue; break;
          case "-": resultado = _firstValue! - secondValue; break;
          case "×": resultado = _firstValue! * secondValue; break;
          case "÷": resultado = secondValue != 0 ? _firstValue! / secondValue : 0; break;
        }
        _calcDisplay = resultado.toStringAsFixed(resultado % 1 == 0 ? 0 : 2);
        _operator = null; _firstValue = null;
      } else {
        if (_calcDisplay == "0" || _shouldResetDisplay) {
          _calcDisplay = key; _shouldResetDisplay = false;
        } else {
          _calcDisplay += key;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            alignment: Alignment.bottomRight,
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            color: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[100],
            child: Text(_calcDisplay, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildRow(["C", "÷"]),
                _buildRow(["7", "8", "9", "×"]),
                _buildRow(["4", "5", "6", "-"]),
                _buildRow(["1", "2", "3", "+"]),
                _buildRow(["0", "="]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: keys.map((key) {
          bool isOperator = ["+", "-", "×", "÷", "=", "C"].contains(key);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: isOperator ? Colors.blue.withOpacity(0.1) : null,
                  side: isOperator ? const BorderSide(color: Colors.blueAccent, width: 1) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _onKeypadPressed(key),
                child: Text(key, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isOperator ? Colors.blueAccent : null)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}