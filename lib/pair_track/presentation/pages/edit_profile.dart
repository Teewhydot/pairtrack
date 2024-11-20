import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<GoogleSignInService>(context);

    return PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Edit Profile'),
          leading: PlatformIconButton(
            icon: Icon(context.platformIcons.back),
            onPressed: () {
              Navigator.pop(context);
            },

          ),
          trailingActions: [
            PlatformIconButton(
              icon: Icon(context.platformIcons.checkMark),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 90,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: userDetails.userPhotoUrl!,
                              placeholder: (context, url) =>
                                  PlatformCircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(context.platformIcons.error),
                            ),
                            )
                        ),
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Icon(context.platformIcons.edit),
                          ),
                        )
                      ],
                    )),
                    addVerticalSpacing(20),
                    const Text(
                      'Name',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    addVerticalSpacing(10),
                    PlatformTextField(
                      material: (_, __) => MaterialTextFieldData(
                        decoration: InputDecoration(
                          hintText: userDetails.userName,
                        ),
                      ),
                      cupertino: (_, __) => CupertinoTextFieldData(
                        placeholder: 'Enter your name',
                      ),
                    ),
                    addVerticalSpacing(20),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    addVerticalSpacing(10),
                    PlatformTextField(
                      enabled: false,
                      material: (_, __) => MaterialTextFieldData(
                        decoration: InputDecoration(
                          hintText: userDetails.userEmail,
                        ),
                      ),
                      cupertino: (_, __) => CupertinoTextFieldData(
                        placeholder: 'tchipsical@gmail.com',
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: PlatformElevatedButton(
                  onPressed: () {},
                  child: const Text('Delete Account',
                      style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ));
  }
}
