import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:get_it/get_it.dart';
import 'package:las_app/common_widgets/c_text.dart';
import 'package:las_app/core/theme/app_typography.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/location_service.dart';
import 'bloc/eligibility_bloc.dart';
import 'repository/lenders_data_repo.dart';
import 'repository/pan_veirfy_repo.dart';

class KycService {
  static void startKyc(
    BuildContext context, {
    required String lenderCode,
    required String reqId,
    String? stepName,
    VoidCallback? onSuccess,
  }) async {
    final apiClient = GetIt.instance<ApiClient>();

    final eligibilityBloc = EligibilityBloc(
      repository: PanRepository(apiClient),
      lenderRepository: LenderRepository(apiClient),
      apiClient: apiClient,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: eligibilityBloc,
        child: BlocConsumer<EligibilityBloc, EligibilityState>(
          listener: (context, state) {
            if (state.kycUrl != null && !state.kycLoading) {
              Navigator.of(context).pop();
              onSuccess?.call();
            } else if (state.kycError != null) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.kycError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.kycLoading) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.bPrimaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.bPrimaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          color: AppColors.bPrimaryColor,
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CText(
                        stepName ?? 'startKycProcess'.tr,
                        style: AppTypography.bodyWhite.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CText(
                        'pleaseWaitWhileWePrepare'.tr,
                        style: AppTypography.bodyWhite.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.bSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    // Get current location
    final position = await LocationService.getCurrentLocation();
    final latitude = position?.latitude ?? 28.6139;
    final longitude = position?.longitude ?? 77.2090;

    eligibilityBloc.add(
      StartKycEvent(
        reqId: reqId,
        lenderCode: lenderCode,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }
}
