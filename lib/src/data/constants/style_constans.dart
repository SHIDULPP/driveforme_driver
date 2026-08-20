import 'package:driveforme_driver/src/data/constants/color_constants.dart';
import 'package:flutter/material.dart';

// Clash Grotesk (Figma: Regular 400 / Medium 500 / Semibold 600 / Bold 700).
// Line-height is 120%. Headings paint as Medium — legacy weight names alias
// so existing `kStyle(kSemiBold, …)` call sites stay unchanged.

const String kFontFamily = 'ClashGrotesk';

const kRegular = FontWeight.w400;
const kMedium = FontWeight.w500;

const kLight = kRegular;
const kUltraLight = kRegular;
const kExtraLight = kRegular;
const kSemiBold = kMedium;
const kBold = kMedium;
const kExtraBold = kMedium;
const kBlackFont = kMedium;

const double kShortClose = -1.2;
const double kShort = -0.3;

// Figma type scale: Clash Grotesk/{size}/{weight}
// 10 · 12 · 14 · 16 · 18 · 20 · 24 · 30 · 36
const double kDisplay = 36;
const double kExtraLarge = 30;
const double kLarge = 24;
const double kHeading = 20;
const double kSubHeading = 18;
const double kBody = 16;

const double kSize10 = 10;
const double kSize11 = 11;
const double kSize12 = 12;
const double kSize13 = 13;
const double kSize14 = 14;
const double kSize15 = 15;
const double kSize16 = 16;
const double kSize17 = 17;
const double kSize18 = 18;
const double kSize20 = 20;
const double kSize22 = 22;
const double kSize24 = 24;
const double kSize25 = 25;
const double kSize26 = 26;
const double kSize28 = 28;
const double kSize30 = 30;
const double kSize32 = 32;
const double kSize34 = 34;
const double kSize36 = 36;

TextStyle kStyle(
  FontWeight weight,
  double size, {
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontWeight: weight,
    color: color ?? kTextColor,
    fontSize: size,
    letterSpacing: letterSpacing,
    height: height ?? 1.2,
  );
}

// ================= SCALE (Figma sizes × Regular / Medium) =================

final kDisplayTitleR = kStyle(kRegular, kDisplay);
final kDisplayTitleM = kStyle(kMedium, kDisplay);
final kDisplayTitleSB = kDisplayTitleM;
final kDisplayTitleB = kDisplayTitleM;
final kDisplayTitleEB = kDisplayTitleM;

final kExtraLargeTitleM = kStyle(kMedium, kExtraLarge);
final kExtraLargeTitleR = kStyle(kRegular, kExtraLarge);
final kExtraLargeTitleSB = kExtraLargeTitleM;
final kExtraLargeTitleB = kExtraLargeTitleM;

final kLargeTitleR = kStyle(kRegular, kLarge);
final kLargeTitleM = kStyle(kMedium, kLarge);
final kLargeTitleSB = kLargeTitleM;
final kLargeTitleB = kLargeTitleM;
final kLargeTitleEB = kLargeTitleM;

final kHeadTitleM = kStyle(kMedium, kHeading);
final kHeadTitleSB = kHeadTitleM;
final kHeadTitleB = kHeadTitleM;
final kHeadTitleEB = kHeadTitleM;
final kHeadTitleR = kDisplayTitleR;

final kSubHeadingR = kStyle(kRegular, kSubHeading);
final kSubHeadingM = kStyle(kMedium, kSubHeading);
final kSubHeadingL = kSubHeadingR;
final kSubHeadingSB = kSubHeadingM;
final kSubHeadingB = kSubHeadingM;
final kSubHeadingEB = kSubHeadingM;

final kBodyTitleR = kStyle(kRegular, kBody);
final kBodyTitleM = kStyle(kMedium, kBody);
final kBodyTitleL = kStyle(kRegular, kSize32);
final kBodyTitleSB = kBodyTitleM;
final kBodyTitleB = kBodyTitleM;
final kBodyTitleEB = kBodyTitleM;

final kSmallTitleR = kStyle(kRegular, kSize14);
final kSmallTitleM = kStyle(kMedium, kSize14);
final kSmallTitleL = kSmallTitleR;
final kSmallTitleUL = kSmallTitleR;
final kSmallTitleSB = kSmallTitleM;
final kSmallTitleB = kSmallTitleM;
final kSmallTitleEB = kSmallTitleM;

final kSmallerTitleR = kStyle(kRegular, kSize12);
final kSmallerTitleM = kStyle(kMedium, kSize12);
final kSmallerTitleL = kSmallerTitleR;
final kSmallerTitleEL = kSmallerTitleR;
final kSmallerTitleUL = kSmallerTitleR;
final kSmallerTitleSB = kSmallerTitleM;
final kSmallerTitleB = kSmallerTitleM;
final kSmallerTitleEB = kSmallerTitleM;
final kSmallerTitleRWithGradient = kSmallerTitleR;

// ── Compact UI (home, trips, bottom nav) ──────────────────────────────────────

final kCaption11R = kStyle(kRegular, kSize11);
final kCaption12R = kStyle(kRegular, kSize12, color: kMutedText);
final kCaption13R = kStyle(kRegular, kSize13, color: kMutedText);
final kCaption13SB = kStyle(kMedium, kSize13);
final kCaption14R = kSmallTitleR;
final kCaption14M = kSmallTitleM;
final kCaption14B = kSmallTitleM;
final kCaption15M = kStyle(kMedium, kSize15, color: kMutedText);

final kLabel15M = kStyle(kMedium, kSize15, height: 1.25);
final kLabel17B = kStyle(kMedium, kSize17, height: 1.1);
final kLabel17BGold = kStyle(kMedium, kSize17, color: kGold, height: 1.1);
final kLabel22B = kStyle(kMedium, kSize22, color: kBrandBlue, height: 1.1);
final kLabel22White = kStyle(kMedium, kSize22, color: kWhite, height: 1.15);

final kTabLabelR = kCaption14R;
final kTabLabelM = kStyle(kMedium, kSize14, color: kGoldAccent);

final kNavLabelR = kCaption12R;
final kNavLabelM = kStyle(kMedium, kSize12, color: kBrandBlue);

final kTripBadgeSB = kStyle(kMedium, kSize13, color: kActiveGreen);
final kTripChipR = kStyle(kRegular, kSize13);
final kTrackTripSB = kStyle(kMedium, kSize14, color: kWhite, height: 1.1);

final kSupportTitleB = kStyle(kMedium, kSize17, color: kWhite);
final kSupportSubtitleR = kStyle(
  kRegular,
  kSize13,
  color: kWhite,
  height: 1.35,
);
final kPhoneNumberB = kStyle(kMedium, kSize14, height: 1.0);
final kPhoneSupportR = kStyle(kRegular, kSize11, height: 1.0);

final kDecorTitleEB = kStyle(
  FontWeight.w700,
  kSize36,
  color: kDecorText,
  height: 1.02,
  letterSpacing: -0.8,
);
final kFooterCaptionR = kStyle(kRegular, kSize13, height: 1.35);
final kFooterBrandB = kStyle(kMedium, kSize13, color: kBrandBlue);

final kEmptyStateM = kStyle(kMedium, kSize15, color: kMutedText);

// ── Earnings / Wallet page ────────────────────────────────────────────────────

final kEarningsBalanceLabelR = kStyle(
  kRegular,
  kSize13,
  color: kWhite,
  height: 1.2,
);
final kEarningsBalanceAmountB = kStyle(
  kMedium,
  kSize32,
  color: kWhite,
  height: 1.05,
);
final kEarningsSectionTitleSB = kStyle(
  kSemiBold,
  kSize15,
  color: kTextColor,
  height: 1.2,
);
final kEarningsStatValueSB = kStyle(
  kSemiBold,
  kSize16,
  color: kEarningsStatValueBlue,
  height: 1.1,
);
final kEarningsViewAllM = kStyle(
  kMedium,
  kSize14,
  color: kBrandBlue,
  height: 1.2,
);
final kEarningsTabActiveM = kStyle(
  kMedium,
  kSize14,
  color: kEarningsHeaderBlue,
  height: 1.1,
);
final kEarningsTabInactiveM = kStyle(
  kMedium,
  kSize14,
  color: kSecondaryTextColor,
  height: 1.1,
);
final kEarningsChartTotalSB = kStyle(
  kSemiBold,
  kSize22,
  color: kEarningsStatValueBlue,
  height: 1.1,
);
final kEarningsTrendR = kStyle(
  kRegular,
  kSize12,
  color: kActiveGreen,
  height: 1.2,
);

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
final kTripNotificationTimeM = kNavLabelM;

// ── Login ─────────────────────────────────────────────────────────────────────

final kLoginSubtitleR = kStyle(
  kMedium,
  kSize14,
  color: kMutedText,
  height: 1.5,
);
final kLoginSubtitleAccentSB = kStyle(
  kMedium,
  kSize14,
  color: kBrandBlue,
  height: 1.5,
);
final kLoginPhoneFieldR = kStyle(kRegular, kSize25, color: kGreyDark);
final kLoginResendPromptM = kStyle(kMedium, kSize14, color: kMutedText);
final kLoginResendTimerSB = kEditProfileM;
final kLoginResendActionSB = kEditProfileM;

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
