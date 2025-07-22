import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Đây là một widget chung để quản lý cuộn, tải thêm và làm mới
class CommonListView extends StatefulWidget {
  final List<Widget>
  slivers; // Các slivers mà bạn muốn hiển thị (ví dụ: SliverGrid, SliverList)
  final Future<void> Function({bool isRefresh}) onLoadData; // Hàm tải dữ liệu
  final bool isLoading; // Trạng thái loading từ bên ngoài
  final bool hasMoreData; // Trạng thái còn dữ liệu để tải từ bên ngoài
  final Widget? emptyWidget; // Widget hiển thị khi không có dữ liệu
  final Widget? noMoreDataWidget; // Widget hiển thị khi hết dữ liệu

  const CommonListView({
    super.key,
    required this.slivers,
    required this.onLoadData,
    required this.isLoading,
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
      widget.onLoadData(); // Gọi hàm tải dữ liệu được truyền vào
    }
  }

  Future<void> _onRefresh() async {
    await widget.onLoadData(
      isRefresh: true,
    ); // Gọi hàm tải dữ liệu với cờ làm mới
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
          if (!widget.isLoading &&
              widget.emptyWidget != null)
            SliverFillRemaining(child: widget.emptyWidget!),
          ...widget.slivers, // Các sliver chính được truyền vào
          // Loading indicator cho "load more"
          if (widget.isLoading && widget.hasMoreData)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary,)),
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
