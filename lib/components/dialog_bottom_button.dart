import 'package:flutter/material.dart';

class DialogBottomButton extends StatelessWidget {
  const DialogBottomButton(
      {super.key,
      required this.text,
      required this.onTap,
      required this.style});

  final String text;
  final Function onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      onTap: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Text(text, style: style),
      ),
    );
  }
}
