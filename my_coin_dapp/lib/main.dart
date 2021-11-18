import 'package:flutter/material.dart';
import 'package:my_coin_dapp/views/home_view/home_view.dart';

void main() {
  runApp(const MyCoinDapp());
}

class MyCoinDapp extends StatelessWidget {
  const MyCoinDapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeView(),
    );
  }
}
