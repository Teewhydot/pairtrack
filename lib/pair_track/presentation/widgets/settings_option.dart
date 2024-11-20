import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';

class SettingsOption extends StatelessWidget {
  final Icon leadingIcon;
  final String label;
  final  onTap;
  const SettingsOption({
    super.key,
    required this.leadingIcon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.black54 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: leadingIcon,
      ),
      title: Text(label),
      trailing: Icon(context.platformIcons.rightChevron),
      onTap: onTap,
    );
  }
}
