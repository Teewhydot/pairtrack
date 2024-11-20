import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class SizeConfig {
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}

 addVerticalSpacing(double height) {
 return SizedBox(height: height);
}
 addHorizontalSpacing(double width) {
 return SizedBox(width: width);
}

ColorScheme generateColorScheme(Color seedColor, Brightness brightness) {
  return ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);
}

ThemeData createTheme(Color seedColor, Brightness brightness) {
  final colorScheme = generateColorScheme(seedColor, brightness);
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: brightness,
  );
}

extension DarkMode on BuildContext {
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}


void showWarningDialog(String message, BuildContext context){
  showPlatformDialog(
    context: context,
    builder: (_) => PlatformAlertDialog(
      title: const Text('Error'),
      content:
       Text(message),
      actions: <Widget>[
        PlatformDialogAction(
          child: const Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );

}