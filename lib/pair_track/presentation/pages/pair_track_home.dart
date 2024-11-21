import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairtrack/generated/assets.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/domain/services/firebase_service.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/expanded_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/location_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/pair_manager.dart';
import 'package:pairtrack/pair_track/presentation/pages/permissions.dart';
import 'package:pairtrack/pair_track/presentation/pages/settings.dart';
import 'package:pairtrack/pair_track/presentation/widgets/custom_avatar_container.dart';
import 'package:pairtrack/pair_track/presentation/widgets/pair_manager.dart';
import 'package:pairtrack/pair_track/presentation/widgets/top_action.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

class PairTrackHome extends StatefulWidget {
  const PairTrackHome({super.key});

  @override
  State<PairTrackHome> createState() => _PairTrackHomeState();
}

class _PairTrackHomeState extends State<PairTrackHome> {
  FirebaseGroupFunctions firebaseGroupFunctions = FirebaseGroupFunctions();

  String? mapStyle, activePairName, userEmail;
  int activePairMemberCount = 1;
  BitmapDescriptor? creatorMarker;
  BitmapDescriptor? joinerMarker;
  Set<Marker> markers = {};

  LatLng joinerPosition = const LatLng(0, 0);
  Future<void> _setCreatorMarker(String? photoLink) async {
    final marker = await _createCustomMarker(photoLink);
    setState(() {
      creatorMarker = marker;
    });
  }

  Future<void> _setJoinerMarker(String? photoLink) async {
    final marker = await _createCustomMarker(photoLink);
    setState(() {
      joinerMarker = marker;
    });
  }

  Future<BitmapDescriptor> _createCustomMarker(String? url) async {
    if (url == null) {
      return BitmapDescriptor.defaultMarker;
    }
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(100, 150);

    // Draw the default marker shape
    final paint = Paint()..color = Colors.blue;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width, size.height * 0.6)
      ..arcToPoint(Offset(0, size.height * 0.6),
          radius: Radius.circular(size.width / 2))
      ..close();
    canvas.drawPath(path, paint);

    // Draw the circular image
    final rect = Rect.fromLTWH(0, 0, size.width, size.width);
    canvas.clipPath(Path()..addOval(rect));
    paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.cover);

    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = data!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(buffer);
  }

  Future<void> setMapStyle() async {
    if (context.isDarkMode) {
      mapStyle = await rootBundle.loadString(Assets.assetsMapThemeNight);
      setState(() {});
    } else {
      mapStyle = null;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    final userDetails =
        Provider.of<GoogleSignInService>(context, listen: false);
    final location = Provider.of<LocationProvider>(context, listen: false);
    location.fetchLocationUpdates();
    _setCreatorMarker(userDetails.userPhotoUrl);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final location = Provider.of<LocationProvider>(context);
    activePairName =
        Provider.of<ActivePairJoinerManager>(context).activePairName;
    activePairMemberCount =
        Provider.of<ActivePairJoinerManager>(context).numOfMembers;
    userEmail = Provider.of<GoogleSignInService>(context).userEmail;
    // create marker for the joiner using their photo
    joinerPosition = (await firebaseGroupFunctions.getLocationOfJoiner(
        activePairName, userEmail, activePairMemberCount == 2));

    if (joinerPosition != const LatLng(0, 0)) {
      final joinerPhotoLink = await firebaseGroupFunctions.getJoinerPhotoLink(
          activePairName ?? 'test', userEmail, context);
      _setJoinerMarker(joinerPhotoLink);
      setState(() {
        markers = {
          Marker(
            markerId: const MarkerId('creator'),
            position: LatLng(location.lat, location.long),
            icon: creatorMarker ?? BitmapDescriptor.defaultMarker,
          ),
          if (joinerPosition != const LatLng(0.0, 0.0) &&
              activePairName!.isNotEmpty)
            Marker(
              markerId: const MarkerId('joiner'),
              position: joinerPosition,
              icon: joinerMarker ?? BitmapDescriptor.defaultMarker,
            ),
        };
        print('creator marker and joiner marker');
      });
    } else {
      setState(() {
        print('only creator marker');
        markers = {
          Marker(
            markerId: const MarkerId('creator'),
            position: LatLng(location.lat, location.long),
            icon: creatorMarker ?? BitmapDescriptor.defaultMarker,
          ),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = Provider.of<LocationProvider>(context);
    final pairManager = Provider.of<ActivePairJoinerManager>(context);
    final expanded = Provider.of<TrayExpanded>(context).isExpanded;
    setMapStyle();
    return PlatformScaffold(
      material: (context, platform) => MaterialScaffoldData(
        extendBody: true,
        resizeToAvoidBottomInset: false,
      ),
      body: Stack(
        children: [
          location.lat != 0.0
              ? GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(location.lat, location.long),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    location.mapControllerCompleter.complete(controller);
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('creator'),
                      position: LatLng(location.lat, location.long),
                      icon: creatorMarker ?? BitmapDescriptor.defaultMarker,
                    ),
                    if (activePairMemberCount == 2 &&
                        activePairName!.isNotEmpty)
                      Marker(
                        markerId: const MarkerId('joiner'),
                        position: joinerPosition,
                        icon: joinerMarker ?? BitmapDescriptor.defaultMarker,
                      ),
                  },
                  mapType: MapType.normal,
                )
              : Center(child: PlatformCircularProgressIndicator()),
          Positioned(
            top: 0,
            child: Container(
              width: SizeConfig.screenWidth,
              height: 100,
              color: context.isDarkMode ? Colors.black54 : Colors.white,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Visibility(
                      visible: !expanded,
                      child: TopAction(
                        icon: Icon(context.platformIcons.settings),
                        onClick: () {
                          Navigator.push(
                            context,
                            platformPageRoute(
                              context: context,
                              builder: (context) => const AppSettings(),
                            ),
                          );
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Provider.of<TrayExpanded>(context, listen: false)
                            .toggleExpanded();
                      },
                      child: AnimatedContainer(
                        height: 40,
                        width: expanded ? 300 : 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        duration: const Duration(milliseconds: 150),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pairManager.activePairName ?? 'Select pair',
                                ),
                                expanded
                                    ? Icon(context.platformIcons.upArrow)
                                    : Icon(context.platformIcons.downArrow),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    TopAction(
                      icon: const Icon(Icons.chat),
                      onClick: () {
                        Navigator.push(
                          context,
                          platformPageRoute(
                            context: context,
                            builder: (context) => const PermissionsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(top: 100, left: 0, right: 0, child: PairsManager()),
          const Positioned(
              bottom: 0, left: 0, right: 0, child: CustomAvatarContainer())
        ],
      ),
    );
  }
}
