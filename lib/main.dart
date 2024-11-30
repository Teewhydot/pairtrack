import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/firebase_options.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/domain/constants/theme.dart';
import 'package:pairtrack/pair_track/domain/services/connectivity_service.dart';
import 'package:pairtrack/pair_track/domain/services/permission_service.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/expanded_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/location_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/pair_manager.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/selected_pair_manager.dart';
import 'package:pairtrack/pair_track/presentation/pages/auth.dart';
import 'package:pairtrack/pair_track/presentation/pages/no_internet_screen.dart';
import 'package:pairtrack/pair_track/presentation/pages/pair_track_home.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    // Workaround for https://github.com/flutter/flutter/issues/35162
    await FlutterDisplayMode.setHighRefreshRate();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserLocationProvider()),
    ChangeNotifierProvider(create: (context) => PermissionService()),
    ChangeNotifierProvider(create: (context) => GoogleSignInService()),
    ChangeNotifierProvider(create: (context) => ActivePairJoinerManager()),
    ChangeNotifierProvider(create: (context) => TrayExpanded()),
    ChangeNotifierProvider(
        create: (context) => SelectedGroup()..loadSelectedGroupId()),
    ChangeNotifierProvider(create: (context) => ConnectivityService()),
  ], child: const Home()));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    final googleService =
        Provider.of<GoogleSignInService>(context, listen: false);
    googleService.renderButton();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<GoogleSignInService>(context).userEmail;
    return PlatformProvider(
      builder: (context) => PlatformTheme(
          materialLightTheme: AppTheme.lightTheme,
          materialDarkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          cupertinoLightTheme: CupertinoThemeData(
            primaryColor: AppTheme.lightTheme.primaryColor,
          ),
          cupertinoDarkTheme: CupertinoThemeData(
            primaryColor: AppTheme.darkTheme.primaryColor,
          ),
          builder: (context) {
            SizeConfig().init(context);
            return PlatformApp(
              material: (_, __) => MaterialAppData(
                debugShowCheckedModeBanner: false,
                title: 'PairTrackApp',
              ),
              localizationsDelegates: const <LocalizationsDelegate<
                  dynamic>>[
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
              ],
              home: userEmail != null
                  ? const PairTrackHome()
                  : const Auth(),
            );
          }),
    );
  }
}
