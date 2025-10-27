import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:las_app/common_widgets/c_button.dart'; 
import 'package:las_app/core/theme/app_colors.dart';
import 'package:las_app/features/new_user/bloc/eligibility_bloc.dart';
import 'package:las_app/features/new_user/view/widgets/two_lender_selection/lender_selection.dart'; 

class EligibilityResultOverlay extends StatelessWidget {
  const EligibilityResultOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.white, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'You are eligible to unlock up to',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.success, 
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flash_on,
              color: AppColors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          
          RichText(
            text: const TextSpan(
              style: TextStyle(
                color: AppColors.success, 
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: '₹ '),
                TextSpan(text: '4,85,800'), 
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'from your investments',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 40),
          
     CButton(
  text: 'See Loan Offers',
 onPressed: () {
  final eligibilityBloc = context.read<EligibilityBloc>();
  eligibilityBloc.add(FetchStep2Data()); 
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlocProvider.value(
        value: eligibilityBloc,
        child: const LenderSelectionScreen(),
      ),
    ),
  );
},

  type: ButtonType.secondaryBlack,
  suffixIcon: const Icon(Icons.arrow_forward, color: AppColors.black, size: 18),
),

          const SizedBox(height: 16), 
        ],
      ),
    );
  }
}

