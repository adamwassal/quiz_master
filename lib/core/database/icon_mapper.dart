import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';

IconData getIconFromString(String iconName) {
  final iconMap = <String, IconData>{
    'code': MdiIcons.codeBraces,
    'movie': MdiIcons.movieOpen,
    'sports': MdiIcons.soccer,
    'design': MdiIcons.draw,
    'science': MdiIcons.atom,
    'book': MdiIcons.bookOpenPageVariant,
    'history': MdiIcons.history,
    'music': MdiIcons.music,
    'math': MdiIcons.functionVariant,
    'geography': MdiIcons.mapMarkerRadius,
    // Add more mappings here
  };

  // Default icon fallback if not found
  return iconMap[iconName.toLowerCase()] ?? Icons.help_outline;
}
