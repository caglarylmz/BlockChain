import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;

  final myAdress =
      "3f07c0aa2cb94f732041e001172702d7f77233876f11914e15adb80f4b5ab3cd";

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Vx.gray300,
      body: ZStack(
        [
          VxBox()
              .blue600
              .size(context.screenWidth, context.percentHeight * 30)
              .make(),
          VStack([
            (context.percentHeight * 10).heightBox,
            "MYTOKEN".text.xl4.white.bold.center.makeCentered().py16(),
            (context.percentHeight * 5).heightBox,
            VxBox(
              child: VStack(
                [
                  "Balance".text.gray700.xl2.semiBold.makeCentered(),
                  10.heightBox,
                  data
                      ? "\$1".text.bold.xl6.makeCentered()
                      : const CircularProgressIndicator(
                          color: Vx.green700,
                        ).centered(),
                ],
              ),
            )
                .p16
                .white
                .size(context.screenWidth, context.percentHeight * 18)
                .rounded
                .shadowXl
                .make()
                .p16(),
            30.heightBox,
            VxBox(
              child: HStack(
                [
                  TextButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, color: Vx.white),
                    label: "Refresh".text.white.make(),
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.call_made_outlined, color: Vx.white),
                    label: "Deposit".text.white.make(),
                  ),
                  TextButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.call_received_outlined,
                        color: Vx.white),
                    label: "Withdraw".text.white.make(),
                  ),
                ],
                alignment: MainAxisAlignment.spaceAround,
                axisSize: MainAxisSize.max,
              ),
            )
                .size(context.screenWidth < 800 ? 400 : 500, 50)
                .alignTopCenter
                .makeCentered(),
          ]),
        ],
      ),
    );
  }
}
