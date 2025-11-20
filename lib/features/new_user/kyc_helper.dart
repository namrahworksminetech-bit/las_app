class KycHelper {
  static String extractDocumentId(String workflowResult) {
    // Extract KYC ID from complex result string
    if (workflowResult.contains('kyc_id:')) {
      final parts = workflowResult.split('kyc_id:');
      if (parts.length > 1) {
        final kycIdPart = parts[1].split(',')[0].trim();
        return kycIdPart;
      }
    }
    
    if (workflowResult.contains('documentId :')) {
      return workflowResult.split('documentId :').last.split(',')[0].trim();
    }
    
    // If it starts with KID, extract just the ID
    if (workflowResult.contains('KID')) {
      final regex = RegExp(r'KID[A-Z0-9]+');
      final match = regex.firstMatch(workflowResult);
      if (match != null) {
        return match.group(0)!;
      }
    }
    
    return workflowResult;
  }
}
