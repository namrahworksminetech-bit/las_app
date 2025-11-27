import 'package:flutter/material.dart';

class AppContainer extends StatelessWidget {
  final Widget child;

  const AppContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
    
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
      
          // Set a max width (like mobile width)
          final double maxWidth = 345;
      
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}