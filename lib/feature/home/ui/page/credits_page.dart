import 'package:accounting_app/feature/home/ui/widgets/gradient_app_bar.dart';
import 'package:flutter/material.dart';

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(context: context, title: "زمامات", hasPop: true),
      body: Column(children: []),
    );
  }
}
