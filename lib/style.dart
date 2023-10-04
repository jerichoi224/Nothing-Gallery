import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextStyleType {
  // HomePageWidget
  navBar(fontSize: 16, color: Colors.white),

  // AlbumWidget
  albumTitle(fontSize: 12, color: Colors.white),
  buttonText(fontSize: 14, color: Colors.white),

  // GridItemWidget
  videoDuration(fontSize: 12, color: Colors.white),

  // VideoPlayerPage
  videoPlayerDuration(fontSize: 14, color: Colors.white),

  // GridPage
  gridPageTitle(fontSize: 20, color: Colors.white),

  // Common
  pageTitle(fontSize: 22, color: Colors.white),
  popUpMenu(fontSize: 14, color: Colors.white),

  // ImagePage
  picturesDateTaken(fontSize: 18, color: Colors.white),
  imageIndex(fontSize: 20, color: Colors.white),

  // SettingsPage
  settingTitle(fontSize: 24, color: Colors.white),
  settingCategory(fontSize: 16, color: Colors.grey),
  settingsMenu(fontSize: 18, color: Colors.white),
  settingsFineText(fontSize: 14, color: Colors.grey);

  const TextStyleType({required this.fontSize, required this.color});
  final double fontSize;
  final Color color;
}

TextStyle mainTextStyle(TextStyleType style) {
  return TextStyle(
      color: style.color,
      fontSize: style.fontSize,
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily);
}
