import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/pages/auth.dart';
import 'package:pairtrack/pair_track/presentation/pages/edit_profile.dart';
import 'package:pairtrack/pair_track/presentation/widgets/settings_option.dart';

import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    final googleSignInService =
        Provider.of<GoogleSignInService>(context, listen: false);
    final userDetails = Provider.of<GoogleSignInService>(context);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text('Settings'),
        leading: PlatformIconButton(
          icon: Icon(context.platformIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 90,
                width: SizeConfig.screenWidth,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? Colors.black54 : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(userDetails
                                .userPhotoUrl ??
                            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                      ),
                      addHorizontalSpacing(20),
                      Text(userDetails.userName ?? 'User Name'),
                    ],
                  ),
                )),
          ),
          addVerticalSpacing(50),
          const Divider(),
          SettingsOption(
            leadingIcon: Icon(context.platformIcons.person),
            label: 'Edit Profile',
            onTap: () {
              Navigator.push(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => const EditProfile(),
                ),
              );
            },
          ),
          const Divider(),
          SettingsOption(
            leadingIcon: const Icon(Icons.logout),
            label: 'Logout',
            onTap: () {
              googleSignInService.signOut().whenComplete(() {
               if(context.mounted) {
                 Navigator.pushReplacement(
                 context,
                 platformPageRoute(
                   context: context,
                   builder: (context) => const Auth(),
                 ),
               );
               }
              });
            },
          ),
        ],
      ),
    );
  }
}
