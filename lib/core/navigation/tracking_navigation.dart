import 'package:flutter/material.dart';

import '../../features/tracking/pages/tracking_hub_page.dart';

/// Navigation helpers for personal tracking.
class TrackingNavigation {
  TrackingNavigation._();

  static void openHub(BuildContext context, {int initialTab = 0}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrackingHubPage(initialTab: initialTab),
      ),
    );
  }

  static void openBookmarks(BuildContext context) => openHub(context);

  static void openNotes(BuildContext context) => openHub(context, initialTab: 1);

  static void openReflections(BuildContext context) =>
      openHub(context, initialTab: 2);
}
