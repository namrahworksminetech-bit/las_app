import 'package:flutter/material.dart';

class OnboardingPageContent extends StatelessWidget {
  final String imagePath;
  final String iconAssetPath;
  final String subtitle;
  final String title;

  const OnboardingPageContent({
    super.key,
    required this.imagePath,
    required this.iconAssetPath,
    required this.subtitle,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Color(0xFFFF6600);
    const Color kSubtitleTextColor = Color(0x80E5E7EB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Expanded(
          flex: 4, 
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        SizedBox(height: 15),

        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    iconAssetPath,
                    color: kPrimaryColor,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: kSubtitleTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
