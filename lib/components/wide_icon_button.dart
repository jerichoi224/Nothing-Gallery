import 'package:flutter/material.dart';
import 'package:nothing_gallery/style.dart';

class WideIconButton extends StatelessWidget {
  const WideIconButton(
      {super.key,
      required this.text,
      required this.hideIcon,
      required this.iconData,
      required this.onTapHandler});

  final String text;
  final bool hideIcon;
  final IconData iconData;
  final Function onTapHandler;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ClipRRect(
      child: Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(24, 28, 30, 1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () {
                    onTapHandler();
                  },
                  customBorder: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      hideIcon
                          ? Container()
                          : Icon(
                              iconData,
                              size: 28,
                            ),
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
