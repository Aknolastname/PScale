import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SLider extends StatelessWidget {
  const SLider({Key? key, required this.scaleLevel, required this.imageUrl})
      : super(key: key);

  final String imageUrl;
  final String scaleLevel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Image.network(imageUrl),
      subtitle: Center(
        child: Text(scaleLevel,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
            )),
      ),
    );
  }
}
