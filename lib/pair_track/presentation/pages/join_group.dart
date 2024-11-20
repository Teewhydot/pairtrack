import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/domain/services/firebase_service.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/location_provider.dart';
import 'package:provider/provider.dart';

class JoinPair extends StatefulWidget {
  const JoinPair({super.key});

  @override
  State<JoinPair> createState() => _JoinPairState();
}

class _JoinPairState extends State<JoinPair> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  FirebaseGroupFunctions firebaseService = FirebaseGroupFunctions();
  bool loading = false;

  void startLoading() {
    setState(() {
      loading = true;
    });
  }

  void stopLoading() {
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationProvider>(context);
    final userEmail = Provider.of<GoogleSignInService>(context).userEmail;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Join Pair'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.black54 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'Pair creator email',
                    border: InputBorder.none,
                  ),
                ),
              ),
              addVerticalSpacing(20),
              Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.black54 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'Pair code',
                    border: InputBorder.none,
                  ),
                ),
              ),
              addVerticalSpacing(20),
              loading
                  ? PlatformCircularProgressIndicator()
                  : PlatformElevatedButton(
                      child: const Text('Join'),
                      onPressed: () {
                        if (_emailController.text.isNotEmpty &&
                            _codeController.text.isNotEmpty) {
                          if (_emailController.text.trim() == userEmail) {
                            showWarningDialog(
                                'You cannot join a pair you created', context);
                            stopLoading();
                          } else {
                            startLoading();
                            firebaseService
                                .joinGroup(
                                    _codeController.text.trim(),
                                    _emailController.text.trim(),
                                    context,
                                    LatLng(location.lat, location.long))
                                .whenComplete(() {
                              if (context.mounted) {
                                stopLoading();
                                Navigator.pop(context);
                              }
                            });
                          }
                        } else {
                          showWarningDialog(
                              'Please enter both email and code', context);
                          stopLoading();
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
