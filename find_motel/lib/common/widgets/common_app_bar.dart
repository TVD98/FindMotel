import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable navigation header (AppBar) for the app.
///
/// Usage:
/// ```dart
/// Scaffold(
///   appBar: const CommonAppBar(title: 'Home'),
///   body: ...,
/// )
/// ```
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Header title text.
  final String title;

  /// Provide an asset path to display a custom leading icon. When set, this overrides the default back arrow.
  final String? leadingAsset;

  /// Optional callback to handle leading icon press.
  final VoidCallback? onLeadingPressed;

  /// Optional list of widgets to display in the AppBar actions.
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leadingAsset = 'assets/images/ic_back.svg',
    this.onLeadingPressed,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: leadingAsset != null
          ? IconButton(
              onPressed: () {
                if (onLeadingPressed == null) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                } else {
                  onLeadingPressed!();
                }
              },
              icon: SvgPicture.asset(leadingAsset!, height: 24, width: 24),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.headerLineOnPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      titleSpacing: leadingAsset == null ? 16 : 0,
      backgroundColor: AppColors.headerLinePrimary,
      elevation: 0,
      actions: actions,
    );
  }
}
