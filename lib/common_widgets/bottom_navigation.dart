import 'package:flutter/material.dart';
import 'package:las_app/features/home/bloc/bloc_home.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/assets.dart';
import '../core/utils/enums.dart';

class BottomNavigation extends StatelessWidget {
  final HomeBloc? bloc;

  const BottomNavigation(this.bloc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: Color(0x59FFFFFF),
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(1.0),
            offset: const Offset(0, -5.73),
            blurRadius: 27.52,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          color: Colors.black,
          notchMargin: 0,
          child: Row(
            children: [
              itemBtn(
                name: 'Home',
                icon: Ast.svg.ic_bn_home,
                selectedIcon: Ast.svg.ic_bn_home_fill,
                page: EmPage.dashboard,
              ),
              itemBtn(
                name: 'Portfolio',
                icon: Ast.svg.ic_bn_portfolio,
                selectedIcon: Ast.svg.ic_bn_portfolio_fill,
                page: EmPage.portfolio,
              ),
              itemBtn(
                name: 'Transactions',
                icon: Ast.svg.ic_bn_transaction,
                selectedIcon: Ast.svg.ic_bn_transaction_fill,
                page: EmPage.transaction,
              ),
              itemBtn(
                name: 'Profile',
                icon: Ast.svg.ic_bn_profile,
                selectedIcon: Ast.svg.ic_bn_profile_fill,
                page: EmPage.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemBtn({
    required String name,
    required AssetsSvg icon,
    required AssetsSvg selectedIcon,
    required EmPage page,
  }) {
    bool isSelected = page == bloc?.state.page;
    return Expanded(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 4,
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.bPrimaryColor : Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
          ),
          TextButton(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isSelected
                    ? selectedIcon.load(height: 20)
                    : icon.load(height: 20),
                Gaps.hXxs,
                Text(
                  name,
                  style: AppTypography.caption.copyWith(
                    color: isSelected ? AppColors.bPrimaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
            onPressed: () => bloc?.add(OnClickTab(page: page)),
          ),
        ],
      ),
    );
  }
}
