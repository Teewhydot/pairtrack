import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:provider/provider.dart';

class FirebaseGroupFunctions {
  final fireStore = FirebaseFirestore.instance;
  Future<void> createGroup(
      String pairName, BuildContext context, LatLng location) async {
    final user = Provider.of<GoogleSignInService>(context, listen: false);
    // create the group
    await fireStore
        .collection('Pairs')
        .doc(user.userEmail)
        .collection('pairs')
        .doc(pairName)
        .set({
      'created_at': DateTime.now(),
      'created_by': user.userEmail,
      'creator_photo_url': user.userPhotoUrl,
    });

    // add the creator as a member
    await fireStore
        .collection('Pairs')
        .doc(user.userEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .doc(user.userEmail)
        .set({
      'joined_at': DateTime.now(),
      'joined_by': user.userEmail,
      'photo_url': user.userPhotoUrl,
      'current_latitude': location.latitude,
      'current_longitude': location.longitude,
    });
  }

  Future<void> joinGroup(String pairName, groupCreatorEmail,
      BuildContext context, LatLng location) async {
    final user = Provider.of<GoogleSignInService>(context, listen: false);
    final bool isGroupFull =
        await checkNumOfMembersInGroup(pairName, groupCreatorEmail, context) >=
            2;
    if (isGroupFull) {
      return;
    }
    await fireStore
        .collection('Pairs')
        .doc(groupCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .doc(user.userEmail)
        .set({
      'joined_at': DateTime.now(),
      'joined_by': user.userEmail,
      'photo_url': user.userPhotoUrl,
      'current_latitude': location.latitude,
      'current_longitude': location.longitude,
    });
    // for the joiner, add the group to their list of Pairs showing who created the group and when they joined
    await fireStore
        .collection('Pairs')
        .doc(user.userEmail)
        .collection('pairs')
        .doc(pairName)
        .set({
      'created_at': DateTime.now(),
      'created_by': groupCreatorEmail,
      'creator_photo_url':
          await getPhotoUrlOfGroupCreator(pairName, groupCreatorEmail),
    });

    // for the joiner, create a members collection and copy the members from the group creator to the joiner
    final result = await fireStore
        .collection('Pairs')
        .doc(groupCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .get();
    final members = result.docs;
    for (final member in members) {
      await fireStore
          .collection('Pairs')
          .doc(user.userEmail)
          .collection('pairs')
          .doc(pairName)
          .collection('members')
          .doc(member['joined_by'])
          .set({
        'joined_at': member['joined_at'],
        'joined_by': member['joined_by'],
        'photo_url': member['photo_url'],
        'current_latitude': member['current_latitude'],
        'current_longitude': member['current_longitude'],
      });
    }
  }

  Future<LatLng> getLocationOfJoiner(String? pairName, pairCreatorEmail,bool activePairMemberJoined) async {
    if (pairName == null || activePairMemberJoined == false) {
      return LatLng(0, 0);
    }
    final result = await fireStore
        .collection('Pairs')
        .doc(pairCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .where('joined_by', isNotEqualTo: pairCreatorEmail)
        .get()
        .then((value) {
      return LatLng(value.docs.first['current_latitude'],
          value.docs.first['current_longitude']);
    });
    return result;
  }

  Future<String?> getJoinerPhotoLink(
      String? pairName, pairCreatorEmail, BuildContext context) {

    if (pairName == null) {
      return Future.value(null);
    }
    // go into the members collection and loop through the members and check
    // which email is not the same as the creator email meaning
    // the email is a joiner then grab the photo url of that joiner
    return fireStore
        .collection('Pairs')
        .doc(pairCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .where('joined_by', isNotEqualTo: pairCreatorEmail)
        .get()
        .then((value) => value.docs.first['photo_url']);
  }

  // leave group function for user who joined the group
  Future<void> leaveGroup(
      String pairName, groupCreatorEmail, BuildContext context) async {
    final user = Provider.of<GoogleSignInService>(context, listen: false);
    // delete the group for the user
    await fireStore
        .collection('Pairs')
        .doc(user.userEmail)
        .collection('pairs')
        .doc(pairName)
        .delete();
    // delete the user from the group
    await fireStore
        .collection('Pairs')
        .doc(groupCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .doc(user.userEmail)
        .delete();
  }

  // delete group function which should also delete the group for every member
  Future<void> deleteGroup(String pairName, BuildContext context) async {
    final user = Provider.of<GoogleSignInService>(context, listen: false);
    // get all the members of the group
    final result = await fireStore
        .collection('Pairs')
        .doc(user.userEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .get();
    final members = result.docs;
    for (final member in members) {
      // delete the group for each member
      await fireStore
          .collection('Pairs')
          .doc(member['joined_by'])
          .collection('pairs')
          .doc(pairName)
          .delete();
    }
    await fireStore
        .collection('Pairs')
        .doc(user.userEmail)
        .collection('pairs')
        .doc(pairName)
        .delete();
  }

  Future<void> updateLocation(
      String pairName, groupCreatorEmail, LatLng location) async {
    await fireStore
        .collection('Pairs')
        .doc(groupCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .doc(groupCreatorEmail)
        .update({
      'current_latitude': location.latitude,
      'current_longitude': location.longitude,
    });
  }

  Future<String?> getPhotoUrlOfGroupCreator(
      String pairName, groupCreatorEmail) async {
    final result = await fireStore
        .collection('Pairs')
        .doc(groupCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .get();
    final data = result.data();
    return data?['creator_photo_url'];
  }

  Future<int> checkNumOfMembersInGroup(
      String pairName, groupCreatorEmail, BuildContext context) async {
    // check if the number of members in a group is less than 2
    final result = await fireStore
        .collection('Pairs')
        .doc(groupCreatorEmail)
        .collection('pairs')
        .doc(pairName)
        .collection('members')
        .get();
    final noOfMembers = result.docs.length;
    return noOfMembers;
  }
}
