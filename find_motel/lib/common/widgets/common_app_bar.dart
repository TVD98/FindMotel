import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable navigation header (AppBar) with full layout control.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? leadingAsset;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final Color? leadingIconColor;
  final Color? backgroundColor;
  final TabBar? tabBar;

  const CommonAppBar({
    super.key,
    required this.title,
    this.leadingAsset = 'assets/images/ic_back.svg',
    this.onLeadingPressed,
    this.actions,
    this.leadingIconColor = Colors.white,
    this.backgroundColor = AppColors.headerLinePrimary,
    this.tabBar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Phần trên của AppBar (tiêu đề và nút)
            SizedBox(
              height: kToolbarHeight,
              child: Row(
                children: [
                  // Nút Leading (quay lại)
                  if (leadingAsset != null)
                    IconButton(
                      onPressed: () {
                        if (onLeadingPressed == null) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        } else {
                          onLeadingPressed!();
                        }
                      },
                      icon: SvgPicture.asset(
                        leadingAsset!,
                        height: 24,
                        width: 24,
                        colorFilter: leadingIconColor != null
                            ? ColorFilter.mode(
                                leadingIconColor!,
                                BlendMode.srcIn,
                              )
                            : null,
                      ),
                    ),
                  // Tiêu đề
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: leadingAsset == null ? 16 : 0,
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.headerLineOnPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  // Các widget actions
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            // Phần dưới của AppBar (TabBar)
            if (tabBar != null)
              tabBar!,
          ],
        ),
      ),
    );
  }

  // Cập nhật chiều cao của AppBar tùy thuộc vào việc có TabBar hay không
  @override
  Size get preferredSize {
    // Chiều cao mặc định của AppBar + chiều cao của TabBar (nếu có)
    return Size.fromHeight(
      kToolbarHeight + (tabBar?.preferredSize.height ?? 0),
    );
  }
}
