import 'package:flutter/material.dart';
import 'package:heart_toggle/heart_toggle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heart Toggle Demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Heart Toggle Demo'),
        ),
        body: Center(
          child: HeartToggle(
            props: HeartToggleProps(
              size: 260.0,
              passiveFillColor: Colors.grey[200]!,
              ballElevation: 4.0,
              heartElevation: 4.0,
              ballColor: Colors.white,
              onChanged: (toggled) => {},
            ),
          ),
        ),
      ),
    );
  }
}
