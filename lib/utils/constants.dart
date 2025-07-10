// CREATED BY THATO MUSA 26/05/2025

import 'package:flutter/material.dart';
// lib/utils/constants.dart

import 'package:google_fonts/google_fonts.dart'; // Assuming you use google_fonts

// Text Styles
const TextStyle kHeaderTextStyle = TextStyle(
  fontSize: 28.0,
  fontWeight: FontWeight.bold,
  color: Colors.black87, // Adjust as needed
);

const InputDecoration kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  hintStyle: TextStyle(color: Colors.grey),
);

// Spacing
const double kSmallSpacing = 8.0;
const double kMediumSpacing = 16.0;
const double kLargeSpacing = 32.0;

// Responsive Padding
const EdgeInsets kMobileContentPadding = EdgeInsets.symmetric(horizontal: 24.0);
const EdgeInsets kDesktopContentPadding = EdgeInsets.symmetric(horizontal: 200.0); // For larger screens
const double kLogoHeightFactor = 0.25; // Percentage of screen height for logo

// Button Styles
final ButtonStyle kPrimaryButtonStyle = ElevatedButton.styleFrom(
  foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color, Button background color
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30.0),
  ),
  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
  elevation: 5.0,
  textStyle: GoogleFonts.inter(fontSize: 18.0, fontWeight: FontWeight.bold),
);

final ButtonStyle kTextButtonStyle = TextButton.styleFrom(
  foregroundColor: Colors.lightBlueAccent, // Text color
  textStyle: GoogleFonts.inter(fontSize: 16.0),
);
/// ┌──────────────────────────────────────────────────────────────────────────┐
/// │                                APP CONSTANTS                             │
/// └──────────────────────────────────────────────────────────────────────────┘

const double kDefaultBorderRadius = 8.0;
const double kCardElevation = 8.0;
const kScaffoldColor = Color(0xAAEDEDED);

const kLightText = Color(0xFFEDEDED);

const kTableTitleStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30);

const kColumnNameStyle = TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800);

const kDataStyle = TextStyle(color: Colors.black, fontSize: 16);

// COLORS
const kCreatedUser = Colors.yellow;
const kApprovedUser = Colors.green;
const kUpdatedUser = Colors.blue;
const kDeletedUser = Colors.red;
const kBlockedUser = Colors.deepOrange;
const kUnblockedUser = Colors.greenAccent;
const kDeniedUser = Colors.redAccent;
const kFieldAdded = Colors.orangeAccent;
const kUserApprovalUpdate = Colors.blueGrey;