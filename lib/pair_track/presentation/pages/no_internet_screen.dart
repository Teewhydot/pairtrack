import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      material: (_, __) => MaterialAppData(
        debugShowCheckedModeBanner: false,
        title: 'PairTrackApp',
      ),
      cupertino: (_, __) => CupertinoAppData(
        debugShowCheckedModeBanner: false,
        title: 'PairTrackApp',
      ),
      title: 'Error',
      home: PlatformScaffold(
        body: Center(
          child: Text('Your data don finish'),
        ),
      ),

    );
  }
}