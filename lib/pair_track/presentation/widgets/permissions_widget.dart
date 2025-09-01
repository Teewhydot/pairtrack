import 'package:flutter/material.dart';

class PermissionDialog extends StatelessWidget {
  final String permission;
  final String explanation;
  final VoidCallback onGrant;
  final VoidCallback onDeny;

  const PermissionDialog({
    required this.permission,
    required this.explanation,
    required this.onGrant,
    required this.onDeny,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, size: 50, color: Colors.orange),
          SizedBox(height: 10),
          Text(
            "Permission Needed: $permission",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            explanation,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: onDeny,
                child: Text('Deny', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: onGrant,
                child: Text('Allow'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void showPermissionDialog(BuildContext context,
    {required String permission,
    required String explanation,
    required VoidCallback onGrant,
    required VoidCallback onDeny}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PermissionDialog(
      permission: permission,
      explanation: explanation,
      onGrant: onGrant,
      onDeny: onDeny,
    ),
  );
}
