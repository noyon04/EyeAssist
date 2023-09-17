import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/*
Focus: To maintain app wide design consistency all
the text style that are used in this app should be
declared here.

*Note: In special case: When let's say one title
text or textButton theme needsto be different,
say the color needs to be red instead of Black.
Don't create titleStyle1 (-_-). Just follow this:
Code Snippet:  (Applicable for all styles)
Text(segmentTitle,
style: AppTextStyle.titleStyle.copyWith(color: KColor.red)),
*/

class KTextStyle {
  static TextStyle headline1 = GoogleFonts.montserrat(fontSize: 93, fontWeight: FontWeight.w300, letterSpacing: -1.5);

  static TextStyle headline2 = GoogleFonts.montserrat(fontSize: 58, fontWeight: FontWeight.w300, letterSpacing: -0.5);

  static TextStyle headline3 = GoogleFonts.montserrat(fontSize: 46, fontWeight: FontWeight.w400);

  static TextStyle headline4 = GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25);

  static TextStyle headline5 = GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w400);

  static TextStyle headline6 = GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w400, letterSpacing: 0.15);

  static TextStyle subtitle1 = GoogleFonts.montserrat(fontSize: 15, fontWeight: FontWeight.w400, letterSpacing: 0.15);

  static TextStyle subtitle2 = GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);

  static TextStyle drawer = GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.1);

  static TextStyle bodyText1 = GoogleFonts.montserrat(fontSize: 17, fontWeight: FontWeight.w400, letterSpacing: 0.5);

  static TextStyle bodyText2 = GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25);
  static TextStyle button = GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25);

  static TextStyle caption = GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4);

  static TextStyle overline = GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5);
}
