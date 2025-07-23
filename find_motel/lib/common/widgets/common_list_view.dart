import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Đây là một widget chung để quản lý cuộn, tải thêm và làm mới
class CommonListView extends StatefulWidget {
  final List<Widget> slivers;
  final Future<void> Function({bool isRefresh}) onLoadData;
  final bool isLoading;
  final bool isHaveData;
  final bool hasMoreData;
  final Widget? emptyWidget;
  final Widget? noMoreDataWidget;

  const CommonListView({
    super.key,
    required this.slivers,
    required this.onLoadData,
    required this.isLoading,
    required this.isHaveData,
    required this.hasMoreData,
    this.emptyWidget,
    this.noMoreDataWidget,
  });

  @override
  State<CommonListView> createState() => _CommonListViewState();
}

class _CommonListViewState extends State<CommonListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 50 &&
        !widget.isLoading &&
        widget.hasMoreData) {
      widget.onLoadData();
    }
  }

  Future<void> _onRefresh() async {
    await widget.onLoadData(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hiển thị widget trống nếu không có dữ liệu và không đang tải
          if (!widget.isHaveData &&
              !widget.isLoading &&
              widget.emptyWidget != null)
            SliverFillRemaining(child: widget.emptyWidget!),
          ...widget.slivers, // Các sliver chính được truyền vào
          // Loading indicator cho "load more"
          if (widget.isLoading && widget.hasMoreData)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          // Widget "hết dữ liệu"
          if (!widget.hasMoreData && widget.noMoreDataWidget != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: widget.noMoreDataWidget!),
              ),
            ),
        ],
      ),
    );
  }
}
