import 'package:flutter/material.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/core/theme/app_spacing.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  void _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        title: Text("Contact Us", style: AppTypography.bodyWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("We're here to help!", style: AppTypography.h2),
            Gaps.hMd,

            _contactTile(
              title: "Contact Number",
              value: "9136542858",
              icon: Icons.phone,
              onTap: () => _launch("tel:9136542858"),
            ),

            _contactTile(
              title: "Email",
              value: "las@valuenable.in",
              icon: Icons.email,
              onTap: () => _launch("mailto:las@valuenable.in"),
            ),

            _contactTile(
              title: "WhatsApp",
              value: "Chat on WhatsApp",
              icon: Icons.chat_bubble,
              onTap: () => _launch("https://wa.me/message/QR76B75VQGA4D1"),
            ),

            _contactTile(
              title: "Website",
              value: "https://sliqfin.com",
              icon: Icons.language,
              onTap: () => _launch("https://sliqfin.com"),
            ),

            _contactTile(
              title: "LinkedIn",
              value: "SliqFin LinkedIn",
              icon: Icons.business_center,
              onTap: () => _launch("https://www.linkedin.com/company/sliqfin/"),
            ),

            _contactTile(
              title: "Instagram",
              value: "@sliq.valuenable",
              icon: Icons.camera_alt,
              onTap: () => _launch(
                "https://www.instagram.com/sliq.valuenable?igsh=MTRwcTgxYzB2NTYydw==",
              ),
            ),
          ],
        ),
      ),
    );
  }

  //---------------------------------------------------------------------------
  // 📌 IMPROVED CONTACT TILE WIDGET — Flutter Icons Only
  //---------------------------------------------------------------------------
  Widget _contactTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      radius: 20,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 🌟 Circular Icon (Bigger + Better Styling)
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bPrimaryColor.withOpacity(0.18),
              ),
              child: Icon(
                icon,
                size: 28,
                color: AppColors.bPrimaryColor,
              ),
            ),

            Gaps.wLg,

            // Text Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.caption),
                Gaps.hXxs,
                Text(value, style: AppTypography.bodyWhite),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
