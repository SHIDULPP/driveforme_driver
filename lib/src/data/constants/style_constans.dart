import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:flutter/material.dart';

// ================= FONT WEIGHTS =================

// Clash Grotesk works best with these mappings

const kExtraLight = FontWeight.w200;
const kUltraLight = FontWeight.w300;
const kLight = FontWeight.w400;
const kRegular = FontWeight.w500;
const kMedium = FontWeight.w600;
const kSemiBold = FontWeight.w700;
const kBold = FontWeight.w800;
const kExtraBold = FontWeight.w900;
const kBlackFont = FontWeight.w900;

// ================= LETTER SPACING =================

const double kShortClose = -1.2;
const double kShort = -0.3;

// ================= FONT SIZES =================

const double kDisplay = 44;
const double kExtraLarge = 40;
const double kLarge = 38;
const double kHeading = 36;
const double kSubHeading = 18;
const double kBody = 32;
const double kSize30 = 30;
const double kSize28 = 28;
const double kSize11 = 11;
const double kSize12 = 12;
const double kSize13 = 13;
const double kSize14 = 14;
const double kSize15 = 15;
const double kSize16 = 16;
const double kSize17 = 17;
const double kSize18 = 18;
const double kSize22 = 22;
const double kSize34 = 34;
const double kSize36 = 36;
const double kSize10 = 10;
const double kSize20 = 20;
const double kSize24 = 24;
const double kSize26 = 26;

// ================= BASE STYLE =================

TextStyle kStyle(
  FontWeight weight,
  double size, {
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'ClashGrotesk',
    fontWeight: weight,
    color: color ?? kTextColor,
    fontSize: size,
    letterSpacing: letterSpacing,
    height: height ?? 1.2,
  );
}

// ================= DISPLAY =================

final kDisplayTitleR = kStyle(kRegular, kDisplay);
final kDisplayTitleM = kStyle(kMedium, kDisplay);
final kDisplayTitleSB = kStyle(kSemiBold, kDisplay);
final kDisplayTitleB = kStyle(kBold, kDisplay);
final kDisplayTitleEB = kStyle(kExtraBold, kDisplay);

// ================= LARGE =================

final kLargeTitleR = kStyle(kRegular, kLarge);
final kLargeTitleM = kStyle(kMedium, kLarge);
final kExtraLargeTitleM = kStyle(kMedium, kExtraLarge);
final kLargeTitleSB = kStyle(kSemiBold, kLarge);
final kLargeTitleB = kStyle(kBold, kLarge);
final kLargeTitleEB = kStyle(kExtraBold, kLarge);

// ================= HEADING =================

final kHeadTitleR = kStyle(kRegular, kHeading);
final kHeadTitleM = kStyle(kMedium, kHeading);
final kHeadTitleSB = kStyle(kSemiBold, kHeading);
final kHeadTitleB = kStyle(kBold, kHeading);
final kHeadTitleEB = kStyle(kExtraBold, kHeading);

// ================= SUBHEADING =================

final kSubHeadingL = kStyle(kLight, kSubHeading);
final kSubHeadingR = kStyle(kRegular, kSubHeading);
final kSubHeadingM = kStyle(kMedium, kSubHeading);
final kSubHeadingSB = kStyle(kSemiBold, kSubHeading);
final kSubHeadingB = kStyle(kBold, kSubHeading);
final kSubHeadingEB = kStyle(kExtraBold, kSubHeading);

// ================= BODY =================

final kBodyTitleL = kStyle(kLight, kBody);
final kBodyTitleR = kStyle(kRegular, kBody);
final kBodyTitleM = kStyle(kMedium, kBody);
final kBodyTitleSB = kStyle(kSemiBold, kBody);
final kBodyTitleB = kStyle(kBold, kBody);
final kBodyTitleEB = kStyle(kExtraBold, kBody);

// ================= SMALL =================

final kSmallTitleUL = kStyle(kUltraLight, kSize30);
final kSmallTitleL = kStyle(kLight, kSize30);
final kSmallTitleR = kStyle(kRegular, kSize30);
final kSmallTitleM = kStyle(kMedium, kSize30);
final kSmallTitleSB = kStyle(kSemiBold, kSize30);
final kSmallTitleB = kStyle(kBold, kSize30);
final kSmallTitleEB = kStyle(kExtraBold, kSize30);

// ================= SMALLER =================

final kSmallerTitleEL = kStyle(kExtraLight, kSize28);
final kSmallerTitleUL = kStyle(kUltraLight, kSize28);
final kSmallerTitleL = kStyle(kLight, kSize28);
final kSmallerTitleR = kStyle(kRegular, kSize28);
final kSmallerTitleRWithGradient = kStyle(kRegular, kSize28);
final kSmallerTitleM = kStyle(kMedium, kSize28);
final kSmallerTitleSB = kStyle(kSemiBold, kSize28);
final kSmallerTitleB = kStyle(kBold, kSize28);
final kSmallerTitleEB = kStyle(kExtraBold, kSize28);

// ── Compact UI (home, trips, bottom nav) ──────────────────────────────────────

final kCaption11R = kStyle(kRegular, kSize11);
final kCaption12R = kStyle(kRegular, kSize12, color: kMutedText);
final kCaption13R = kStyle(kRegular, kSize13, color: kMutedText);
final kCaption13SB = kStyle(kSemiBold, kSize13, color: kTextColor);
final kCaption14R = kStyle(kRegular, kSize14);
final kCaption14M = kStyle(kMedium, kSize14);
final kCaption14B = kStyle(kSemiBold, kSize14, color: kTextColor);
final kCaption15M = kStyle(kMedium, kSize15, color: kMutedText);

final kLabel15M = kStyle(kMedium, kSize15, color: kTextColor, height: 1.25);
final kLabel17B = kStyle(kSemiBold, kSize17, height: 1.1);
final kLabel17BGold = kStyle(kSemiBold, kSize17, color: kGold, height: 1.1);
final kLabel22B = kStyle(kSemiBold, kSize22, color: kBrandBlue, height: 1.1);
final kLabel22White = kStyle(kSemiBold, kSize22, color: kWhite, height: 1.15);

final kTabLabelR = kStyle(kRegular, kSize14, color: kTextColor);
final kTabLabelM = kStyle(kMedium, kSize14, color: kGoldAccent);

final kNavLabelR = kStyle(kRegular, kSize12, color: kMutedText);
final kNavLabelM = kStyle(kMedium, kSize12, color: kBrandBlue);

final kTripBadgeSB = kStyle(kSemiBold, kSize13, color: kActiveGreen);
final kTripChipR = kStyle(kRegular, kSize13);
final kTrackTripSB = kStyle(kSemiBold, kSize14, color: kWhite, height: 1.1);

final kSupportTitleB = kStyle(kSemiBold, kSize17, color: kWhite, height: 1.2);
final kSupportSubtitleR = kStyle(kRegular, kSize12, color: kWhite, height: 1.3);
final kPhoneNumberB = kStyle(
  kSemiBold,
  kSize14,
  color: kTextColor,
  height: 1.15,
);
final kPhoneSupportR = kStyle(kRegular, kSize11, height: 1.15);

final kDecorTitleEB = kStyle(
  kExtraBold,
  kSize36,
  color: kDecorText,
  height: 1.05,
  letterSpacing: -0.3,
);
final kFooterCaptionR = kStyle(kRegular, kSize13, height: 1.35);
final kFooterBrandB = kStyle(kSemiBold, kSize13, color: kBrandBlue);

final kEmptyStateM = kStyle(kMedium, kSize15, color: kMutedText);

// ── Profile ───────────────────────────────────────────────────────────────────

final kProfileNameB = kStyle(
  kSemiBold,
  kSize16,
  color: kTextColor,
  height: 1.15,
);
final kProfilePhoneR = kStyle(
  kRegular,
  kSize13,
  color: kMutedText,
  height: 1.2,
);
final kMenuItemM = kStyle(kMedium, kSize16, color: kTextColor);
final kMenuItemDangerM = kStyle(kMedium, kSize16, color: kRed);
final kSectionLabelR = kStyle(kRegular, kSize13, color: kMutedText);
final kQuickActionM = kStyle(kMedium, kSize13, color: kTextColor);
final kVersionR = kStyle(kRegular, kSize12, color: kMutedText);
final kEditProfileM = kStyle(kMedium, kSize14, color: kBrandBlue);
final kTripNotificationBodyR = kStyle(
  kRegular,
  kSize14,
  color: kTripBodyMuted,
  height: 1.45,
);
final kTripNotificationTimeM = kStyle(
  kMedium,
  kSize12,
  color: kTripCtaBlue,
  height: 1.2,
);

// ── Trip booking (Ride Now / create trip flow) ────────────────────────────────

final kTripPageTitleSB = kStyle(
  kSemiBold,
  kSize22,
  color: kTextColor,
  height: 1.15,
);
final kTripForPillM = kStyle(kMedium, kSize14, color: kTextColor);
final kTripSectionTitleSB = kStyle(
  kSemiBold,
  kSubHeading,
  color: kTextColor,
  height: 1.2,
);
final kTripSubSectionSB = kStyle(kSemiBold, kSize14, color: kTextColor);
final kTripLocationLabelR = kStyle(kRegular, kSize12, color: kTripMutedLabel);
final kTripLocationValueM = kStyle(kMedium, kSize16, color: kTextColor);
final kTripTimePillM = kStyle(kMedium, kSize14, color: kTextColor);
final kTripSegmentActiveM = kStyle(kMedium, kSize14, color: kWhite);
final kTripSegmentInactiveM = kStyle(kMedium, kSize14, color: kTextColor);
final kTripVehicleAddM = kStyle(kMedium, kSize16, color: kTextColor);
final kTripTypeChipM = kStyle(kMedium, kSize15, color: kTextColor);
final kTripDurationPriceB = kStyle(kSemiBold, kSize16, color: kBrandBlue);
final kTripDurationMetaR = kStyle(kRegular, kSize13, color: kTripBodyMuted);
final kTripChipDurationSB = kStyle(kSemiBold, kSize14, color: kTextColor);
final kTripChipHourB = kStyle(kSemiBold, kSize16, color: kTextColor);
final kTripChipHourMutedB = kStyle(kSemiBold, kSize16, color: kTripDarkText);
final kTripChipUnitM = kStyle(kMedium, kSize12, color: kBrandBlue);
final kTripChipCustomM = kStyle(kMedium, kSize12, color: kBrandBlue);
final kTripOvernightTitleSB = kStyle(
  kSemiBold,
  kSize13,
  color: kTextColor,
  height: 1.1,
);
final kTripOvernightSubR = kStyle(
  kRegular,
  kSize11,
  color: kTripMutedLabel,
  height: 1.2,
);
final kTripWaitingNoteM = kStyle(kMedium, kSize12, color: kTripGold);
final kTripProtectionTitleSB = kStyle(kSemiBold, kSize18, color: kTextColor);
final kTripProtectionAddonB = kStyle(kSemiBold, kSize14, color: kBrandBlue);
final kTripProtectionDescR = kStyle(kRegular, kSize13, color: kTripMutedLabel);
final kTripPaymentTitleSB = kStyle(kSemiBold, kSize16, color: kTextColor);
final kTripPaymentSubtitleR = kStyle(kRegular, kSize13, color: kTripMutedLabel);
final kTripPaymentPriceB = kStyle(kSemiBold, kSize18, color: kBrandBlue);
final kTripPaymentTrailingR = kStyle(kRegular, kSize13, color: kTripMutedLabel);
final kTripSecureBannerR = kStyle(kRegular, kSize12, color: kActiveGreen);
final kTripSecureBannerB = kStyle(kSemiBold, kSize12, color: kActiveGreen);
final kTripTotalLabelR = kStyle(kRegular, kSize13, color: kTripMutedLabel);
final kTripTotalPriceB = kStyle(
  kSemiBold,
  kSize26,
  color: kBrandBlue,
  height: 1.1,
);
final kTripModalTitleSB = kStyle(kSemiBold, kSize22, color: kTextColor);
final kTripModalSummaryR = kStyle(kRegular, kSize14, color: kTextColor);
final kTripModalSummaryB = kStyle(kSemiBold, kSize14, color: kTextColor);
final kTripPickerSelectedM = kStyle(kMedium, kSize18, color: kBrandBlue);
final kTripPickerUnselectedM = kStyle(
  kMedium,
  kSize18,
  color: kTripPickerMuted,
);
final kTripModalButtonM = kStyle(kMedium, kSize16, color: kWhite);
final kTripStaySheetTitleSB = kStyle(kSemiBold, kSize18, color: kTextColor);
final kTripStayCounterB = kStyle(
  kSemiBold,
  kSize28,
  color: kTripStayCounter,
  height: 1.1,
);

// ── Booking confirmed ─────────────────────────────────────────────────────────

final kBookingConfirmedTitleSB = kStyle(
  kSemiBold,
  kSize30,
  color: kTextColor,
  height: 1.15,
);
final kBookingConfirmedAccentSB = kStyle(
  kSemiBold,
  kSize30,
  color: kBrandBlue,
  height: 1.15,
);
final kBookingConfirmedSubtitleR = kStyle(
  kRegular,
  kSize16,
  color: kTripMutedLabel,
  height: 1.4,
);

// ── Trip scheduled ────────────────────────────────────────────────────────────

final kTripScheduledAccentSB = kStyle(
  kSemiBold,
  kSize30,
  color: kTripCtaBlue,
  height: 1.15,
);
final kTripScheduledDateB = kStyle(
  kSemiBold,
  kSize16,
  color: kTripCtaBlue,
  height: 1.2,
);
final kTripScheduledBodyR = kStyle(
  kRegular,
  kSize15,
  color: kTripBodyMuted,
  height: 1.45,
);
final kTripScheduledLinkSB = kStyle(
  kSemiBold,
  kSize16,
  color: kTripCtaBlue,
  height: 1.1,
);

// ── Scheduled trip details ────────────────────────────────────────────────────

final kScheduledTripDateR = kStyle(
  kRegular,
  kSize14,
  color: kTripBodyMuted,
  height: 1.2,
);
final kScheduledTripCountdownSB = kStyle(
  kSemiBold,
  kSize15,
  color: kActiveGreen,
  height: 1.2,
);
final kScheduledTripStatLabelR = kStyle(
  kRegular,
  kSize12,
  color: kTripMutedLabel,
  height: 1.1,
);
final kScheduledTripStatValueSB = kStyle(
  kSemiBold,
  kSize16,
  color: kTextColor,
  height: 1.1,
);
final kScheduledTripRouteTitleSB = kStyle(
  kSemiBold,
  kSize15,
  color: kTextColor,
  height: 1.2,
);
final kScheduledTripRouteSubtitleR = kStyle(
  kRegular,
  kSize12,
  color: kTripMutedLabel,
  height: 1.15,
);
final kScheduledTripSectionSB = kStyle(
  kSemiBold,
  kSize16,
  color: kTextColor,
  height: 1.15,
);
final kScheduledTripPaymentLabelR = kStyle(
  kRegular,
  kSize14,
  color: kTripBodyMuted,
  height: 1.2,
);
final kScheduledTripPaymentValueSB = kStyle(
  kSemiBold,
  kSize14,
  color: kTextColor,
  height: 1.2,
);
final kScheduledTripPaidSB = kStyle(
  kSemiBold,
  kSize14,
  color: kActiveGreen,
  height: 1.2,
);

// ── Completed trip details ────────────────────────────────────────────────────

final kCompletedTripTotalLabelSB = kStyle(
  kSemiBold,
  kSize15,
  color: kTripCtaBlue,
  height: 1.2,
);
final kCompletedTripTotalValueSB = kStyle(
  kSemiBold,
  kSize16,
  color: kTripCtaBlue,
  height: 1.2,
);

// ── Cancelled trip details ────────────────────────────────────────────────────

final kCancelledRefundAmountSB = kStyle(
  kSemiBold,
  kSize16,
  color: kActiveGreen,
  height: 1.2,
);
final kCancelledRefundDateSB = kStyle(
  kSemiBold,
  kSize13,
  color: kActiveGreen,
  height: 1.2,
);

// ── Waiting for driver ────────────────────────────────────────────────────────

final kWaitingDriverTripTitleSB = kStyle(
  kSemiBold,
  kSize18,
  color: kTextColor,
  height: 1.15,
);
final kWaitingDriverTripIdR = kStyle(
  kRegular,
  kSize14,
  color: kTripMutedLabel,
  height: 1.15,
);
final kWaitingDriverHelpM = kStyle(
  kMedium,
  kSize15,
  color: kTextColor,
  height: 1.1,
);
final kWaitingDriverHeadlineSB = kStyle(
  kSemiBold,
  kSize22,
  color: kTextColor,
  height: 1.25,
);
final kWaitingDriverHeadlineAccentSB = kStyle(
  kSemiBold,
  kSize22,
  color: kBrandBlue,
  height: 1.25,
);
final kWaitingDriverStatusBlueSB = kStyle(
  kSemiBold,
  kSize20,
  color: kBrandBlue,
  height: 1.2,
);
final kWaitingDriverStatusBlackSB = kStyle(
  kSemiBold,
  kSize24,
  color: kTextColor,
  height: 1.15,
);
final kWaitingDriverDescriptionR = kStyle(
  kRegular,
  kSize15,
  color: kTextColor,
  height: 1.4,
);

// ── Driver found ──────────────────────────────────────────────────────────────

final kDriverFoundTitleSB = kStyle(
  kSemiBold,
  kSize24,
  color: kTextColor,
  height: 1.15,
);
final kDriverFoundSubtitleR = kStyle(
  kRegular,
  kSize14,
  color: kMutedText,
  height: 1.3,
);
final kDriverFoundNameSB = kStyle(
  kSemiBold,
  kSize16,
  color: kTextColor,
  height: 1.15,
);
final kDriverFoundRatingM = kStyle(
  kMedium,
  kSize13,
  color: kTextColor,
  height: 1.1,
);
final kDriverFoundMetaR = kStyle(
  kRegular,
  kSize12,
  color: kMutedText,
  height: 1.2,
);
final kDriverFoundOtpTitleSB = kStyle(
  kSemiBold,
  kSize16,
  color: kTextColor,
  height: 1.15,
);
final kDriverFoundOtpDigitSB = kStyle(
  kSemiBold,
  kSize22,
  color: kTextColor,
  height: 1.0,
);
final kDriverFoundOtpHintR = kStyle(
  kRegular,
  kSize12,
  color: kMutedText,
  height: 1.3,
);
final kDriverFoundRouteSB = kStyle(
  kSemiBold,
  kSize14,
  color: kTextColor,
  height: 1.15,
);
final kDriverFoundPriceSB = kStyle(
  kSemiBold,
  kSize18,
  color: kTripCtaBlue,
  height: 1.1,
);
final kDriverFoundTripMetaR = kStyle(
  kRegular,
  kSize13,
  color: kTripBodyMuted,
  height: 1.2,
);
final kDriverFoundSectionTitleSB = kStyle(
  kSemiBold,
  kSize15,
  color: kTextColor,
  height: 1.2,
);
final kDriverFoundPolicyR = kStyle(
  kRegular,
  kSize13,
  color: kMutedText,
  height: 1.45,
);
final kDriverFoundPolicyTimerSB = kStyle(
  kSemiBold,
  kSize13,
  color: kTripCtaBlue,
  height: 1.45,
);
final kDriverFoundLearnMoreM = kStyle(
  kMedium,
  kSize13,
  color: kTripCtaBlue,
  height: 1.2,
);

// ── Driver rating ─────────────────────────────────────────────────────────────

final kDriverRatingAppBarSB = kStyle(
  kSemiBold,
  kSize20,
  color: kTextColor,
  height: 1.15,
);
final kDriverRatingNameSB = kStyle(
  kSemiBold,
  kSize24,
  color: kTextColor,
  height: 1.1,
);
final kDriverRatingQuestionSB = kStyle(
  kSemiBold,
  kSize20,
  color: kTextColor,
  height: 1.2,
);
final kDriverRatingStatR = kStyle(
  kRegular,
  kSize14,
  color: kTextColor,
  height: 1.15,
);
final kDriverRatingStatMutedR = kStyle(
  kRegular,
  kSize14,
  color: kMutedText,
  height: 1.15,
);
final kDriverRatingVehicleR = kStyle(
  kRegular,
  kSize13,
  color: kMutedText,
  height: 1.2,
);
final kDriverRatingChipR = kStyle(
  kRegular,
  kSize15,
  color: kTextColor,
  height: 1.1,
);
final kDriverRatingCommentR = kStyle(
  kRegular,
  kSize15,
  color: kTextColor,
  height: 1.2,
);
final kDriverRatingCommentHintR = kStyle(
  kRegular,
  kSize15,
  color: kTripMutedLabel,
  height: 1.2,
);
