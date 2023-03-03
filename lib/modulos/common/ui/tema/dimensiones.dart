import 'package:flutter/material.dart';

/// Tamaños constantes para espaciados en la app (paddings, gaps, rounded corners etc.)
/// basado en TailWind https://tailwindcss.com/docs/customizing-spacing
class Sizes {
  static const infinito = double.infinity;
  static const p0 = 0.0;
  static const p0_5 = 0.5;
  static const px = 1.0;
  static const px_5 = 1.5;
  static const p2_0 = 2.0;
  static const p1 = 4.0;
  static const p1_5 = 6.0;

  /// 8px
  static const p2 = 8.0;

  /// 10px
  static const p2_5 = 10.0;

  /// 12px
  static const p3 = 12.0;

  /// 14px
  static const p3_5 = 14.0;

  /// 16px
  static const p4 = 16.0;
  static const p5 = 20.0;
  static const p6 = 24.0;
  static const p7 = 28.0;
  static const p8 = 32.0;
  static const p9 = 36.0;
  static const p10 = 40.0;
  static const p11 = 44.0;
  static const p12 = 48.0;
  static const p14 = 56.0;

  /// 64px
  static const p16 = 64.0;
  static const p20 = 80.0;
  static const p24 = 96.0;
  static const p28 = 112.0;
  static const p32 = 128.0;
  static const p36 = 144.0;
  static const p40 = 160.0;
  static const p44 = 176.0;
  static const p48 = 192.0;
  static const p52 = 208.0;
  static const p56 = 224.0;
  static const p60 = 240.0;
  static const p64 = 256.0;
  static const p72 = 288.0;
  static const p80 = 320.0;
  static const p96 = 384.0;
}

/// Anchos fijos para espaciados
const gapW4 = SizedBox(width: Sizes.p1);
const gapW8 = SizedBox(width: Sizes.p2);
const gapW12 = SizedBox(width: Sizes.p3);
const gapW16 = SizedBox(width: Sizes.p4);
const gapW20 = SizedBox(width: Sizes.p5);
const gapW24 = SizedBox(width: Sizes.p6);
const gapW32 = SizedBox(width: Sizes.p8);
const gapW48 = SizedBox(width: Sizes.p12);
const gapW64 = SizedBox(width: Sizes.p64);

/// Altos fijos para espaciados
const gapH4 = SizedBox(height: Sizes.p1);
const gapH8 = SizedBox(height: Sizes.p2);
const gapH12 = SizedBox(height: Sizes.p3);
const gapH16 = SizedBox(height: Sizes.p4);
const gapH20 = SizedBox(height: Sizes.p5);
const gapH24 = SizedBox(height: Sizes.p6);
const gapH32 = SizedBox(height: Sizes.p8);
const gapH48 = SizedBox(height: Sizes.p12);
const gapH64 = SizedBox(height: Sizes.p64);

class TextSizes {
  static const textXxs = 10.0; // 12px
  static const textXs = 12.0; // 12px
  static const textSm = 14.0; // 14px
  static const textBase = 16.0; // 16px
  static const textLg = 18.0; // 18px
  static const textXl = 20.0; // 20px
  static const text2xl = 24.0; // 24px
  static const text3xl = 30.0; // 30px
  static const text4xl = 36.0; // 36px
  static const text5xl = 40.0; // 40px
  static const text6xl = 48.0; // 48px
  static const text7xl = 60.0; // 60px
  static const text8xl = 72.0; // 72px
  static const text9xl = 96.0; // 96px
}
