import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  static const route = '/home';

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute
        .of(context)!
        .settings
        .arguments;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.yellow, child: Column(children: [

            Text('${message}')
          ],),
      ),
    ),);
  }
}
