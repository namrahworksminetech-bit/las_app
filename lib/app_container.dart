import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppContainer extends StatelessWidget {
  final Widget child;

  const AppContainer({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;

          // Mobile width replica
          const double mobileWidth = 390; // adjust if needed

          // If Web → fixed mobile width
          // If Mobile → real width
          final double finalWidth = kIsWeb ? mobileWidth : screenWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: finalWidth,
              decoration: kIsWeb
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade700, width: 1),
                        right: BorderSide(color: Colors.grey.shade700, width: 1),
                      ),
                    )
                  : null, // No border on mobile

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? mobileWidth : (screenWidth > 450 ? 450 : screenWidth),
                ),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
