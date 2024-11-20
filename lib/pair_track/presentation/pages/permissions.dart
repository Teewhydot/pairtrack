import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/pair_track/domain/services/permission_service.dart';
import 'package:pairtrack/pair_track/presentation/pages/pair_track_home.dart';
import 'package:provider/provider.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  @override
  Widget build(BuildContext context) {
    final permissionService =
        Provider.of<PermissionService>(context, listen: false);
    final permission = Provider.of<PermissionService>(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Permissions'),
        leading: PlatformIconButton(
          icon: Icon(context.platformIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              ListTile(
                title: const Text('Location'),
                subtitle: const Text(
                    'Allow PairTrack to access your location for seamless sharing of live location with your trusted pair'),
                trailing: PlatformSwitch(
                  value: permission.locationPermissionGranted,
                  onChanged: (value) async {
                    await permissionService.requestLocationPermission();
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Background Location'),
                subtitle: const Text(
                    'Allow PairTrack to access your location in the background for seamless sharing of live location with your trusted pair'),
                trailing: PlatformSwitch(
                  value: permission.backgroundLocationPermissionGranted,
                  onChanged: (value) async {
                    await permissionService
                        .requestBackgroundLocationPermission();
                  },
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Notifications'),
                subtitle: permission.isNotificationPermissionGranted
                    ? const Text(
                        'You have granted consent to PairTrack to send you notifications.')
                    : const Text('Allow PairTrack to send you chat notifications'),
                trailing: PlatformSwitch(
                  value: permission.notificationPermissionGranted,
                  onChanged: (value) async {
                    if (permission.isNotificationPermissionGranted) {
                      await permissionService.openAppSettings();
                    }
                    await permissionService.requestNotificationPermission();
                  },
                ),
              ),
            ],
          ),
          PlatformElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  platformPageRoute(
                    context: context,
                    builder: (context) => const PairTrackHome(),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
