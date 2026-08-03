import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF1D5C92); //Indigo- Primary brand · CTAs · Links
const kSecondaryColor = Color(0xFF6C5FE6); //Indigo light- Hover states · Icons
const kAccentColor = Color(0xFFFFFFFF);

// const Color kStrokeColor = Color(0xFF0D2A4D);
const kStrokeColor = Color(0xFF1E3C72); // thin borders

const Color kTertiary = Color(0xFFE8EAED);
const Color kBorder = Color(0xFFD8DADC);

//background colour — Figma `--drive-for-me/-neutral`
const Color kBackgroundColor = Color(0xFFF6F9F2);

//Common Colors
const Color kWhite = Color(0xFFFFFFFF);
const Color kGrey = Color.fromARGB(255, 200, 200, 200);

const Color kTextColor = Color(0xFF141414);

const Color kThirdTextColor = Color(0xFF0A39C4);
const kSecondaryTextColor = Color(0xFF5A5E60); // light cyan for subtitles

const Color kGreyLight = Color(0xFFCCCCCC);
final Color kShimmerBaseColor = Colors.grey[100]!;
const Color kGreyDark = Color.fromARGB(255, 118, 121, 124);
const Color kGreyDarker = Color(0xFF585858);
const Color kRed = Color(0xFFE52022);
const Color kRedDark = Color(0xFFC9300E);
const Color kBlack = Color.fromARGB(255, 5, 5, 5);
const Color kBlack54 = Color(0xff8a000000);
const Color kGreen = Color.fromARGB(255, 76, 175, 80);
const Color kOrange = Color(0xFFFF6900);
const Color kBlue = Color(0xFF2B74E1);
const Color kLightGreen = Color.fromARGB(255, 192, 252, 194);

// ── Main app screens (home, trips, nav) ───────────────────────────────────────

const Color kScreenBg = Color(0xFFF6F9F2);
/// Figma `--drive-for-me/primary`
const Color kBrandBlue = Color(0xFF1D5C92);
const Color kGold = Color(0xFFB77728);
/// Figma `--drive-for-me/accent`
const Color kGoldAccent = Color(0xFFCE9141);
/// Figma `--drive-for-me/-neutral`
const Color kFigmaNeutral = Color(0xFFF6F9F2);

const Color kActiveGreen = Color(0xFF17A34A);
const Color kActiveGreenBg = Color(0xFFE4F3E7);
const Color kDropBlue = Color(0xFF0B5EA8);

const Color kChipGreyBg = Color(0xFFF3F4EE);
const Color kSearchFieldBg = Color(0xFFF4F5EF);
const Color kDecorText = Color(0xFFD8D8DD);
const Color kLineGrey = Color(0xFFD8D8DE);
const Color kMutedText = Color(0xFF888888);
const Color kCardBorder = Color(0xFFE4E4EA);
const Color kChevronGrey = Color(0xFF8E8E93);

// ── Trip booking (create trip, booking confirmed) ─────────────────────────────

const Color kTripGold = Color(0xFFC18131);
const Color kTripCreamBg = Color(0xFFF5F5EF);
const Color kTripSelectedTint = Color(0xFFFFFDF9);
const Color kTripBorder = Color(0xFFE2E2EC);
const Color kTripMutedLabel = Color(0xFFA0A0A0);
const Color kTripBodyMuted = Color(0xFF6F6F6F);
const Color kTripIconMuted = Color(0xFFBDBDC7);
const Color kTripRadioMuted = Color(0xFFAFAFB8);
const Color kTripDestIconBg = Color(0xFFE7E7EF);
const Color kTripCtaBlue = Color(0xFF165A91);
const Color kTripPickerMuted = Color(0xFFC6C6CD);
const Color kTripCloseBtnBg = Color(0xFFE2EAED);
const Color kTripSecureBannerBg = Color(0xFFE6F3EA);
const Color kTripDarkText = Color(0xFF222222);
const Color kTripStayCounter = Color(0xFF0C242A);
const Color kTripRequestStatsBg = Color(0xFFEDF3F8);
const Color kTripRequestAvatarRing = Color(0xFFD4E3EF);

// ── Earnings / Wallet page ────────────────────────────────────────────────────

/// Figma `--drive-for-me/primary` — matches [kBrandBlue]
const Color kEarningsHeaderBlue = Color(0xFF1D5C92);
/// Figma `--drive-for-me/accent` — matches [kGoldAccent]
const Color kEarningsGold = Color(0xFFCE9141);
const Color kEarningsStatValueBlue = Color(0xFF1D5C92);
const Color kEarningsChartBarInactive = Color(0xFFE8EFF8);
const Color kEarningsChartBarActive = Color(0xFF1D5C92);
const Color kEarningsChartAmountMuted = Color(0xFF8BA4BE);
const Color kEarningsTabSelectedBg = Color(0xFFEBEEFF);
const Color kEarningsTabContainerBorder = Color(0xFFE4E8EE);
const Color kEarningsTabShadow = Color(0x0F000000);
const Color kEarningsStatCardBorder = Color(0xFFE6E8EC);
const Color kEarningsCardPurpleBg = Color(0xFFF7F9FE);
const Color kEarningsCardPurpleValue = Color(0xFF4B3FD8);
const Color kEarningsCardBlueBg = Color(0xFFE8F0F8);
const Color kEarningsCardGreenBg = Color(0xFFF5FDFA);
const Color kEarningsCardGreenValue = Color(0xFF17A34A);
const Color kEarningsCardYellowBg = Color(0xFFFFFDF9);
const Color kEarningsCardOrangeValue = Color(0xFFF59E0B);
const Color kEarningsWithdrawIconBg = Color(0xFFE4F3E7);
const Color kEarningsTransactionIconBg = Color(0xFFE4F3E7);
const Color kEarningsPlatformFeeIconBg = Color(0xFFFCE8E8);

// ── Bank & Withdraw flow ──────────────────────────────────────────────────────

const Color kWithdrawCardBg = Color(0xFFFEFAF2);
const Color kWithdrawSecureBadgeBg = Color(0xFFE4F3E7);
const Color kWithdrawInputBorder = Color(0xFF04599C);
const Color kWithdrawBankCardBg = Color(0xFFFEFAF2);
const Color kWithdrawSelectedBankBorder = Color(0xFFC6934B);
const Color kWithdrawSelectedBankBg = Color(0xFFFFF8E8);
const Color kWithdrawDashedBorder = Color(0xFF04599C);
const Color kWithdrawFieldBg = Color(0xFFF4F5F9);

// ── SOS emergency ─────────────────────────────────────────────────────────────

const Color kSosRed = Color(0xFFE32626);
const Color kSosRedDark = Color(0xFF9B1F1F);
const Color kSosCardBg = Color(0xFFF9E6E6);
const Color kSosScreenBg = Color(0xFFF6F9F2);
const Color kSosRefCardBg = Color(0xFFFCE8E8);
const Color kSosSupportIconBg = Color(0xFFE8F0F8);

// ── Trip status chips (Figma NOW / SCHEDULED / COMPLETED / CANCELLED) ─────────

const Color kStatusNowBg = Color(0xFFE4F3E7);
const Color kStatusNowText = Color(0xFF17A34A);
const Color kStatusScheduledBg = Color(0xFFFFF3E8);
const Color kStatusScheduledText = Color(0xFFCE9141);
const Color kStatusCompletedBg = Color(0xFFE8F2FA);
const Color kStatusCompletedText = Color(0xFF1D5C92);
const Color kStatusCancelledBg = Color(0xFFFEECEC);
const Color kStatusCancelledText = Color(0xFFE32626);

// ── Shared chrome ─────────────────────────────────────────────────────────────

const Color kBackButtonBg = Color(0xFFE7E7F1);
const Color kDarkText = Color(0xFF0E0D1A);
const double kFigmaCtaHeight = 56;

// ── Profile ───────────────────────────────────────────────────────────────────

/// Figma `semantic/danger` — profile Logout / Delete Account.
const Color kDangerRed = Color(0xFFDC2626);
