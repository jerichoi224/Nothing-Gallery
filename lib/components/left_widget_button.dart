import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';

class LeftWidgetButton extends StatelessWidget {
  const LeftWidgetButton(
      {super.key,
      required this.text,
      required this.widget,
      required this.onTapHandler});

  final String text;
  final Widget widget;
  final Function onTapHandler;
  @override
  Widget build(BuildContext context) {
    double radius = 8;
    return Padding(
        padding: const EdgeInsets.fromLTRB(12, 3, 12, 3),
        child: ClipRRect(
          child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 16, 16, 16),
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      onTap: () {
                        onTapHandler();
                      },
                      customBorder: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(radius))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(4), child: widget),
                          const SizedBox(
                            height: double.infinity,
                            width: 16,
                          ),
                          Text(
                            text,
                            style: mainTextStyle(TextStyleType.buttonText),
                          )
                        ],
                      )))),
        ));
  }
}
