import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextStyleType {
  // HomePageWidget
  navBar(fontSize: 16),
  popUpMenu(fontSize: 16),

  // AlbumWidget
  albumTitle(fontSize: 12),
  buttonText(fontSize: 14),

  // GridItemWidget
  videoDuration(fontSize: 12),

  // VideoPlayerPage
  videoPlayerDuration(fontSize: 14),

  // Common
  pageTitle(fontSize: 22),

  // ImagePage
  picturesDateTaken(fontSize: 18),
  imageIndex(fontSize: 20),

  // SettingsPage
  settingTitle(fontSize: 24);

  const TextStyleType({required this.fontSize});
  final double fontSize;
}

TextStyle mainTextStyle(TextStyleType style) {
  return TextStyle(
      fontSize: style.fontSize,
      fontFamily: GoogleFonts.spaceGrotesk().fontFamily);
}
