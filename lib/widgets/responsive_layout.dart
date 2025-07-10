import 'package:flutter/material.dart';

////////////////////////////////////////////////////////////////////////////
//                             RESPONSIVENESS                             //
////////////////////////////////////////////////////////////////////////////
class ResponsiveLayout
{
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;

  // MOBILE
  static bool isMobile(BuildContext context)
  {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  // TABLET
  static bool isTablet(BuildContext context)
  {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  // DESKTOP
  static bool isDesktop(BuildContext context)
  {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
}