import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/core/app_state_provider.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';
import 'package:las_app/features/login/view/login_screen.dart';
import 'package:las_app/features/profile/contact_us_page.dart';
import 'package:las_app/features/profile/faq_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/assets.dart';
import 'bloc/bloc_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProfileBloc? bloc;

  
  Future<void> _logoutUser(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();




  // Clear SharedPreferences
  await prefs.remove("api_token");
  await prefs.remove("api_refresh_token");
  await prefs.remove("req_id");


  // Clear global state
  GetIt.instance<AppStateProvider>().clear();

  // Navigate using pushReplacement
  if (context.mounted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(), // <-- your login screen widget
      ),
    );
  }
}
String? savedName;
String? savedEmail;
String? savedMobile;
String? savedPan;

@override
void initState() {
  super.initState();
  _loadStoredProfile();
}

Future<void> _loadStoredProfile() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    savedName   = prefs.getString("pan_full_name");
    savedEmail  = prefs.getString("pan_email");
    savedMobile = prefs.getString("mobile_number");
    savedPan = prefs.getString("pan_number");

  });
}



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(),
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          bloc = context.read<ProfileBloc>();
          return bodyLayout();
        },
      ),
    );
  }

  Widget bodyLayout() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.hXxl,
              headerLayout(),
              Divider(),
              SizedBox(height: 24),
              Text(
                'Personal Information',
                style: AppTypography.regularTxt.copyWith(fontSize: 14),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Color(0xFF1A1A1A)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Full Name', style: AppTypography.regularTxt),
                       Text(
  GetIt.instance<AppStateProvider>().name 
      ?? savedName 
      ?? "-",
  style: AppTypography.regularTxt,
),

                      ],
                    ),
                    SizedBox(height: 6),
                    Container(height: 1, color: Color(0x75565656)),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Email', style: AppTypography.regularTxt),
                       Text(
  GetIt.instance<AppStateProvider>().email 
      ?? savedEmail 
      ?? "-",
  style: AppTypography.regularTxt,
),

                      ],
                    ),
                    SizedBox(height: 6),
                    Container(height: 1, color: Color(0x75565656)),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mobile', style: AppTypography.regularTxt),
                       Text(
  GetIt.instance<AppStateProvider>().mobileNumber 
      ?? savedMobile 
      ?? "-",
  style: AppTypography.regularTxt,
),

                      ],
                    ),
                    SizedBox(height: 6),
                    Container(height: 1, color: Color(0x75565656)),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('PAN', style: AppTypography.regularTxt),
                       Text(
  GetIt.instance<AppStateProvider>().pan 
      ?? savedPan 
      ?? "-",
  style: AppTypography.regularTxt,
),

                      ],
                    ),
                    SizedBox(height: 6),
                    Container(height: 1, color: Color(0x75565656)),
                    // SizedBox(height: 6),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text('Aadhar', style: AppTypography.regularTxt),
                    //     Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       children: [
                    //         Text('Verified', style: AppTypography.regularTxt),
                    //         SizedBox(width: 8),
                    //         Ast.svg.ic_verify.load(),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 6),
                    // Container(height: 1, color: Color(0x75565656)),
                    // SizedBox(height: 6),
                  ],
                ),
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 16),
              //   decoration: BoxDecoration(
              //     border: Border(bottom: BorderSide(color: Color(0x75565656))),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text('Your Loan Accounts', style: AppTypography.regularTxt),
              //       Ast.svg.ic_next.load(),
              //     ],
              //   ),
              // ),
              GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>  FAQPage()),
    );
  },
  child: Container(
    padding: EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x75565656))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Help & FAQs', style: AppTypography.regularTxt),
        Ast.svg.ic_next.load(),
      ],
    ),
  ),
),

            GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactUsPage()),
    );
  },
  child: Container(
    padding: EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x75565656))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Contact Support', style: AppTypography.regularTxt),
        Ast.svg.ic_next.load(),
      ],
    ),
  ),
),

              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 16),
              //   decoration: BoxDecoration(
              //     border: Border(bottom: BorderSide(color: Color(0x75565656))),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text('Terms & Conditions', style: AppTypography.regularTxt),
              //       Ast.svg.ic_link.load(),
              //     ],
              //   ),
              // ),
             GestureDetector(
  onTap: () async {
    await _logoutUser(context);
  },
  child: Container(
    padding: EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Color(0x75565656))),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Logout', style: AppTypography.regularTxt),
        Ast.svg.ic_logout.load(),
      ],
    ),
  ),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget headerLayout() {
    return Row(
      children: [
        profileIcon(),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Profile',
                style: AppTypography.regularTxt.copyWith(fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'All your details in one secure place',
                style: AppTypography.regularTxt.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
Widget profileIcon() {
  // 1️⃣ Get name from state OR saved profile
  String? name = GetIt.instance<AppStateProvider>().name ?? savedName;

  // 2️⃣ Extract first letter or fallback to 'G'
  String firstLetter = (name != null && name.isNotEmpty)
      ? name.trim()[0].toUpperCase()
      : 'G';

  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: AppColors.kPrimaryColor,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      firstLetter,
      style: AppTypography.regularTxt.copyWith(fontSize: 20),
    ),
  );
}

}
