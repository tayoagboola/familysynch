import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

Color eventAccentColor(String? colorStr) {
  switch (colorStr) {
    case 'teal':
      return AppColors.accent;
    case 'yellow':
      return AppColors.yellow;
    case 'purple':
      return AppColors.purple;
    case 'green':
      return AppColors.green;
    case 'blue':
      return AppColors.blue;
    case 'orange':
    default:
      return AppColors.primary;
  }
}

Color eventLightBgColor(String? colorStr) {
  switch (colorStr) {
    case 'teal':
      return AppColors.accentLight;
    case 'yellow':
      return AppColors.yellowLight;
    case 'purple':
      return AppColors.purpleLight;
    case 'green':
      return AppColors.greenLight;
    case 'blue':
      return AppColors.blueLight;
    case 'orange':
    default:
      return AppColors.primaryLight;
  }
}
