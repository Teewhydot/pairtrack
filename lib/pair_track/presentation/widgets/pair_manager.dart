
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/expanded_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/google_signin_provider.dart';
import 'package:pairtrack/pair_track/presentation/manager/providers/pair_manager.dart';
import 'package:pairtrack/pair_track/presentation/pages/create_group.dart';
import 'package:pairtrack/pair_track/presentation/pages/join_group.dart';
import 'package:provider/provider.dart';

import '../../domain/services/firebase_service.dart';

class PairsManager extends StatefulWidget {
  const PairsManager({super.key});
  @override
  State<PairsManager> createState() => _PairsManagerState();
}

class _PairsManagerState extends State<PairsManager>
    with SingleTickerProviderStateMixin {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseGroupFunctions firebaseGroupFunctions = FirebaseGroupFunctions();
  late StreamController<QuerySnapshot> _groupsController;
  late AnimationController _controller;
  late Animation<double> _animation;
  String? userEmail;

  @override
  void initState() {
    userEmail =
        Provider.of<GoogleSignInService>(context, listen: false).userEmail;
    _groupsController = StreamController<QuerySnapshot>.broadcast();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    super.initState();
    firestore
        .collection('Pairs')
        .doc(userEmail)
        .collection('pairs')
        .snapshots()
        .listen(
      (snapshot) {
        _groupsController.add(snapshot);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pairManager = Provider.of<ActivePairJoinerManager>(context);
    final expanded = Provider.of<TrayExpanded>(context).isExpanded;
    if(expanded){
      _controller.forward();
    } else {
      _controller.reverse();
    }
    return StreamBuilder<QuerySnapshot>(
        stream: _groupsController.stream,
        builder: (context, groupsSnapshot) {
          if (groupsSnapshot.hasError) {
            return Center(child: Text('Error: ${groupsSnapshot.error}'));
          }
          if (!groupsSnapshot.hasData) {
            return Center(child: PlatformCircularProgressIndicator());
          }
          if (groupsSnapshot.hasData) {
            if (groupsSnapshot.data!.docs.isEmpty) {
              return SizeTransition(
                sizeFactor: _animation,
                axis: Axis.vertical,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: context.isDarkMode ? Colors.black54 : Colors.white,
                    ),
                    child: Column(
                      children: [
                        const Text('No Pairs available'),
                        Row(
                          children: [
                            Expanded(
                              child: PlatformElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    platformPageRoute(
                                      context: context,
                                      builder: (context) => const CreatePair(),
                                    ),
                                  );
                                },
                                child: const Text('Create Pair'),
                              ),
                            ),
                            Expanded(
                              child: PlatformElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    platformPageRoute(
                                      context: context,
                                      builder: (context) => const JoinPair(),
                                    ),
                                  );
                                },
                                child: const Text('Join Pair'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            final groups = groupsSnapshot.data!.docs;
            return Column(
              children: [
                SizeTransition(
                  sizeFactor: _animation,
                  axis: Axis.vertical,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: context.isDarkMode ? Colors.black54 : Colors.white,
                    ),
                    child: Column(
                      children: [
                        Column(
                          children: groups.map((group) {
                            return StreamBuilder<QuerySnapshot>(
                              stream: firestore
                                  .collection('Pairs')
                                  .doc(userEmail)
                                  .collection('pairs')
                                  .doc(group.id)
                                  .collection('members')
                                  .snapshots(),
                              builder: (context, membersSnapshot) {
                                if (membersSnapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${membersSnapshot.error}'));
                                }
                                if (!membersSnapshot.hasData) {
                                  return Center(child: PlatformCircularProgressIndicator());
                                }
                                final members = membersSnapshot.data!.docs;
                                return GestureDetector(
                                  onLongPress: () {
                                    showPlatformDialog(
                                      context: context,
                                      builder: (_) => PlatformAlertDialog(
                                        title: const Text('Leave group',
                                            style: TextStyle(color: Colors.red)),
                                        content: const Text(
                                            'This will remove your ability to see your pairs location and disable chatting'),
                                        actions: [
                                          PlatformDialogAction(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          PlatformDialogAction(
                                            child: const Text('Delete'),
                                            onPressed: () {
                                              firebaseGroupFunctions
                                                  .leaveGroup(group.id, group['created_by'], context)
                                                  .whenComplete(() {
                                                if (context.mounted) Navigator.pop(context);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                      color: group.id == pairManager.activePairName
                                          ? Colors.grey[200]
                                          : Colors.white,
                                    ),
                                    margin: const EdgeInsets.all(10),
                                    child: ListTile(
                                      leading: const Icon(Icons.group),
                                      onTap: () {
                                        if (expanded) {
                                          Provider.of<TrayExpanded>(context, listen: false)
                                              .toggleExpanded();
                                        }
                                        pairManager.updateActivePair(group.id);
                                      },
                                      title: Text(group.id, style: const TextStyle(color: Colors.black)),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          group['created_by'] != userEmail
                                              ? Text('Created by: ${group['created_by']}', style: const TextStyle(color: Colors.black))
                                              : const Text('You created this group', style: TextStyle(color: Colors.black)),
                                          const SizedBox(width: 10),
                                          Text('${members.length} member(s)', style: const TextStyle(color: Colors.black)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: PlatformElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    platformPageRoute(
                                      context: context,
                                      builder: (context) => const CreatePair(),
                                    ),
                                  );
                                },
                                child: const Text('Create Pair'),
                              ),
                            ),
                            Expanded(
                              child: PlatformElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    platformPageRoute(
                                      context: context,
                                      builder: (context) => const JoinPair(),
                                    ),
                                  );
                                },
                                child: const Text('Join Pair'),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Text('Loading...');
        });
  }
}