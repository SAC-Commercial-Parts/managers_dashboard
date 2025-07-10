
// CREATED BY KEVIN ALERS
//╔═══════════════════════════════════════════════════════════════════════════╗
//║   █████████  ███████████   █████████   ███████████ ██████████  █████████  ║
//║  ███░░░░░███░█░░░███░░░█  ███░░░░░███ ░█░░░███░░░█░░███░░░░░█ ███░░░░░███ ║
//║ ░███    ░░░ ░   ░███  ░  ░███    ░███ ░   ░███  ░  ░███  █ ░ ░███    ░░░  ║
//║ ░░█████████     ░███     ░███████████     ░███     ░██████   ░░█████████  ║
//║  ░░░░░░░░███    ░███     ░███░░░░░███     ░███     ░███░░█    ░░░░░░░░███ ║
//║  ███    ░███    ░███     ░███    ░███     ░███     ░███ ░   █ ███    ░███ ║
//║ ░░█████████     █████    █████   █████    █████    ██████████░░█████████  ║
//║  ░░░░░░░░░     ░░░░░    ░░░░░   ░░░░░    ░░░░░    ░░░░░░░░░░  ░░░░░░░░░   ║
//╚═══════════════════════════════════════════════════════════════════════════╝
// ╔═══════════════════════════════════════════════════════════════════════════╗
// ╚═══════════════════════════════════════════════════════════════════════════╝
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoadingAndStates {
  // ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  // ╔═════════════════════════════════════════════════════════════════════════╗
  // ║                          USED FOR LOADING                               ║
  // ╚═════════════════════════════════════════════════════════════════════════╝
  // ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  bool isLoading = true;
  String loadingMessage = "Loading";
  int delay = 5;

  /// UNIVERSAL DELAY ;)

  /// TURNS LOADING ON
  void setIsLoading(String message) {
    isLoading = true;
    loadingMessage = message;
  }

  /// TURNS LOADING OFF
  void setNotLoading() {
    isLoading = false;
    loadingMessage = "Loading";
  }

  void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
