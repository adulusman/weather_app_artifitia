import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app_artifitia/constants/constants.dart';


void showAdlSnackbar(
  BuildContext context,
  String message, {
  String title = '',
  bool showLoading = false,
  bool isSuccess = false,
  bool isError = false,
  bool isWarning = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: isSuccess
            ? Colors.green
            : isError
                ? Colors.red
                : isWarning
                    ? Colors.amber
                    : Colors.blueGrey,
        duration: showLoading
            ? const Duration(minutes: 30)
            : const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        width: scrWidth * 0.8,
        showCloseIcon: true,
        closeIconColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        content: Row(
          children: [
            if (showLoading)
              const Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: CircularProgressIndicator(),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != '')
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  message,
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
}
