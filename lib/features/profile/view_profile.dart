import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/core/theme/app_typography.dart';

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
                          'Himanshu Pandey',
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
                          'himanshpandey99@gmail.com',
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
                          '+91 89388 23026',
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
                        Text('XXXXX1234X', style: AppTypography.regularTxt),
                      ],
                    ),
                    SizedBox(height: 6),
                    Container(height: 1, color: Color(0x75565656)),
                    SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Aadhar', style: AppTypography.regularTxt),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Verified', style: AppTypography.regularTxt),
                            SizedBox(width: 8),
                            Ast.svg.ic_verify.load(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Container(height: 1, color: Color(0x75565656)),
                    SizedBox(height: 6),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x75565656))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Loan Accounts', style: AppTypography.regularTxt),
                    Ast.svg.ic_next.load(),
                  ],
                ),
              ),
              Container(
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
              Container(
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
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0x75565656))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Terms & Conditions', style: AppTypography.regularTxt),
                    Ast.svg.ic_link.load(),
                  ],
                ),
              ),
              Container(
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
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text('H', style: AppTypography.regularTxt.copyWith(fontSize: 14)),
    );
  }
}
