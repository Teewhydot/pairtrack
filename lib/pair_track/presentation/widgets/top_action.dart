
import 'package:flutter/material.dart';
import 'package:pairtrack/pair_track/domain/constants/helpers.dart';

class TopAction extends StatelessWidget {

  final Icon icon;
  final Function onClick;

  const TopAction({super.key,required this.icon,required this.onClick});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: context.isDarkMode ? Colors.black54 : Colors.white,
          shape: BoxShape.circle,),
        child: icon,
      ),
    );
  }
}
