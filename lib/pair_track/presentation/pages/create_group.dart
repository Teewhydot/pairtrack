import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/domain/services/firebase_service.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/location_provider.dart';
import 'package:provider/provider.dart';

class CreatePair extends StatefulWidget {
  const CreatePair({super.key});

  @override
  State<CreatePair> createState() => _CreatePairState();
}

class _CreatePairState extends State<CreatePair> {
  final TextEditingController _pairNameController = TextEditingController();
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
  Widget build(BuildContext context) {
    final location = Provider.of<LocationProvider>(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Create Pair'),
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
                  controller: _pairNameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(10),
                    labelText: 'Pair Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
              addVerticalSpacing(20),
              loading
                  ? PlatformCircularProgressIndicator()
                  : PlatformElevatedButton(
                child: const Text('Create Pair'),
                onPressed: () {
                  if (_pairNameController.text.isNotEmpty) {
                    startLoading();
                    firebaseService
                        .createGroup(
                        _pairNameController.text.trim(),
                        context,
                        LatLng(location.lat, location.long))
                        .whenComplete(() {
                      if (context.mounted) {
                        stopLoading();
                        Navigator.pop(context);
                      }
                    });
                  } else {
                    showPlatformDialog(
                      context: context,
                      builder: (_) => PlatformAlertDialog(
                        title: const Text('Error'),
                        content:
                        const Text('Please enter a pair name'),
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
