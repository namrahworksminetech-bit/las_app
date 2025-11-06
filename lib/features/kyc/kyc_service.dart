import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/location_service.dart';
import 'bloc/kyc_bloc.dart';
import 'bloc/kyc_event.dart';
import 'bloc/kyc_state.dart';
import 'repository/kyc_repository.dart';

class KycService {
  static void startKyc(
    BuildContext context, {
    required String lenderCode,
    required String reqId,
    VoidCallback? onSuccess,
  }) async {
    final kycRepository = KycRepository(GetIt.instance<ApiClient>());
    final kycBloc = KycBloc(kycRepository);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: kycBloc,
        child: BlocConsumer<KycBloc, KycState>(
          listener: (context, state) {
            if (state is KycSuccess) {
              Navigator.of(context).pop();
              onSuccess?.call();
            } else if (state is KycError) {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  content: Text(
                    state.message,
                    style: const TextStyle(color: AppColors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: AppColors.bPrimaryColor),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is KycLoading) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.bPrimaryColor.withOpacity(0.3)),
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
                      const Text(
                        'Starting KYC Process...',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait while we prepare your verification',
                        style: TextStyle(
                          color: AppColors.bSecondaryColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
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

    kycBloc.add(
      StartKycEvent(
        reqId: reqId,
        lenderCode: lenderCode,
        latitude: latitude,
        longitude: longitude,
      ),
    );
  }
}
