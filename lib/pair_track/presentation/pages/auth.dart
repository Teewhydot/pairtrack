import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/pages/pair_track_home.dart';
import 'package:provider/provider.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  @override
  Widget build(BuildContext context) {
    final googleSignInService = Provider.of<GoogleSignInService>(context);
    return PlatformScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (googleSignInService.errorMessage != null)
              Text(
                googleSignInService.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            googleSignInService.showLoading
                ? PlatformCircularProgressIndicator()
                : PlatformElevatedButton(
                    child: const Text('Sign In With Google'),
                    onPressed: () async {
                      await googleSignInService
                          .signInWithGoogle();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
