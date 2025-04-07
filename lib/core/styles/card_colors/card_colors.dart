import 'package:flutter/material.dart';
import 'package:mini_games_alif/core/styles/card_colors/card_color_model.dart';
import 'package:mini_games_alif/core/styles/card_colors/hover_color_model.dart';

class CardColors {
  static const CardColorModel blue = CardColorModel(
    card: Color(0xFFD2E1F7),
    shadow: Color(0xFF3A6CC2),
    text: Color(0xFF2D5CA5),
    hover: HoverColorModel(
      card: Color(0xFFC2D1E7),
      shadow: Color(0xFF2A5CB2),
      text: Color(0xFF1D4C95),
    ),
  );

  static const CardColorModel lightBlue = CardColorModel(
    card: Color(0xFFE2F1FF),
    shadow: Color(0xFF4A7DD3),
    text: Color(0xFF3D6DB3),
    hover: HoverColorModel(
      card: Color(0xFFD2E1EF),
      shadow: Color(0xFF3A6DC3),
      text: Color(0xFF2D5DA3),
    ),
  );

  static const CardColorModel green = CardColorModel(
    card: Color(0xFFE0F5E0),
    shadow: Color(0xFF8FE686),
    text: Color(0xFF4CAF50),
    hover: HoverColorModel(
      card: Color(0xFFD0E5D0),
      shadow: Color(0xFF7FD676),
      text: Color(0xFF3C9F40),
    ),
  );

  static const CardColorModel pink = CardColorModel(
    card: Color(0xFFFEE6F6),
    shadow: Color(0xFFFF66C4),
    text: Color(0xFFE91E63),
    hover: HoverColorModel(
      card: Color(0xFFEED6E6),
      shadow: Color(0xFFEF56B4),
      text: Color(0xFFD90E53),
    ),
  );

  static const CardColorModel yellow = CardColorModel(
    card: Color(0xFFFFF9E0),
    shadow: Color(0xFFFFDD00),
    text: Color(0xFFFFC107),
    hover: HoverColorModel(
      card: Color(0xFFEFE9D0),
      shadow: Color(0xFFEFCD00),
      text: Color(0xFFEFB107),
    ),
  );

  static const CardColorModel orange = CardColorModel(
    card: Color(0xFFFFF1E0),
    shadow: Color(0xFFFF9933),
    text: Color(0xFFFF5722),
    hover: HoverColorModel(
      card: Color(0xFFEFE1D0),
      shadow: Color(0xFFEF8923),
      text: Color(0xFFEF4712),
    ),
  );

  static const CardColorModel gray = CardColorModel(
    card: Color(0xFFEEEEEE),
    shadow: Color(0xFF9E9E9E),
    text: Color(0xFF757575),
    hover: HoverColorModel(
      card: Color(0xFFDEDEDE),
      shadow: Color(0xFF8E8E8E),
      text: Color(0xFF656565),
    ),
  );
}
