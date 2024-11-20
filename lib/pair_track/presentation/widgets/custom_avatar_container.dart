import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/domain/services/firebase_service.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/pair_manager.dart';
import 'package:provider/provider.dart';

import '../manager/providers/location_provider.dart';

class CustomAvatarContainer extends StatefulWidget {
  const CustomAvatarContainer({
    super.key,
  });
  @override
  State<CustomAvatarContainer> createState() => _CustomAvatarContainerState();
}

class _CustomAvatarContainerState extends State<CustomAvatarContainer> {
  FirebaseGroupFunctions firebaseGroupFunctions = FirebaseGroupFunctions();
  late Future joinerPhotoLink;
  String? activePair;
  String? userEmail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userEmail = Provider.of<GoogleSignInService>(context).userEmail;
    activePair = Provider.of<ActivePairJoinerManager>(context).activePairName;
    joinerPhotoLink = firebaseGroupFunctions.getJoinerPhotoLink(
        activePair ?? 'test', userEmail, context);
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<GoogleSignInService>(context);
    final location = Provider.of<LocationProvider>(context, listen: false);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.black54 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                final position = LatLng(location.lat, location.long);
                location.cameraToPosition(position);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 2, right: 2),
                child: CircleAvatar(
                  radius: 20,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: userDetails.userPhotoUrl ??
                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
                      placeholder: (context, url) =>
                          PlatformCircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          Icon(context.platformIcons.error),
                    ),
                  ),
                ),
              ),
            ),
            FutureBuilder(
                future: joinerPhotoLink,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (snapshot.hasError) {
                    return Container();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: CircleAvatar(
                      radius: 20,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: snapshot.data!,
                          placeholder: (context, url) =>
                              PlatformCircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(context.platformIcons.error),
                        ),
                      ),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
