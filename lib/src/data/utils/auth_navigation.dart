import 'package:driveforme_driver/src/data/models/user_model.dart';

String routeForOnboardingStatus(String status) {
  switch (status) {
    case 'approved':
      return 'navBar';
    case 'profile_pending':
      return 'GetStarted';
    case 'documents_pending':
      return 'documentsUpload';
    case 'under_review':
    case 'pending':
      return 'applicationUnderReview';
    case 'rejected':
      return 'applicationRejected';
    default:
      return 'Phone';
  }
}

String routeForUser(UserModel user) =>
    routeForOnboardingStatus(user.onboardingStatus);
