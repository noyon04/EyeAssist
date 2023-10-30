import 'package:flutter/material.dart';

class TableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TableRowWidget('Speech contains', 'Output', bold: true),
          TableRowWidget('"Object detection"', 'Detect objects'),
          TableRowWidget('"Money" or "Currency"', 'Detect currency'),
          TableRowWidget('"Time"', 'Phone time'),
          TableRowWidget('"Date"', 'Date in format dd-MM-yyyy'),
          TableRowWidget('"Location"', 'Exact location with postal code'),
          TableRowWidget('"Weather"', 'Weather update'),
          TableRowWidget('"Battery charge" or "Phone charge" or "Battery percentage"', 'Remaining Charge'),
          // TableRowWidget('"News"', 'News Update'),
          
          
        ],
      ),
    );
  }
}

class TableRowWidget extends StatelessWidget {
  final String column1Value;
  final String column2Value;
  final bool bold;

  TableRowWidget(this.column1Value, this.column2Value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                column1Value,
                style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                column2Value,
                style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}