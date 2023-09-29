import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextStyleType {
  albumTitle(fontSize: 12),
  videoDuration(fontSize: 14),
  navrBarText(fontSize: 16),
  pageTitle(fontSize: 18),
  settingsMenu(fontSize: 18),
  picturesDateTaken(fontSize: 18),
  imageIndex(fontSize: 20),
  settingTitle(fontSize: 24);

  const TextStyleType({required this.fontSize});
  final double fontSize;
}

TextStyle mainTextStyle(TextStyleType style) {
  return TextStyle(
      fontSize: style.fontSize,
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily);
}
