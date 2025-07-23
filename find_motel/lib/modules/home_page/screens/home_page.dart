import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/common/widgets/common_list_view.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/modules/filter/quickly_filter.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_state.dart';
import 'package:find_motel/modules/detail/detail_screen.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/common/models/motel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    context.read<HomePageBloc>().add(
      LoadMotels(filter: AppDataManager().filterMotels, isRefresh: true),
    );
  }

  Future<void> _fetchMotels({bool isRefresh = false}) async {
    if (isRefresh) {
      context.read<HomePageBloc>().add(
        LoadMotels(filter: AppDataManager().filterMotels, isRefresh: true),
      );
    } else {
      context.read<HomePageBloc>().add(
        LoadMotels(filter: AppDataManager().filterMotels, isRefresh: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<MotelsFilterCubit, MotelsFilter>(
      listener: (context, filter) => {
        context.read<HomePageBloc>().add(
          LoadMotels(filter: filter, isRefresh: true),
        ),
      },
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<UserProfileCubit, UserProfile>(
                        builder: (context, userProfile) {
                          String greeting = "Xin chào";
                          if (userProfile.name != null) {
                            greeting = "Xin chào ${userProfile.name!}";
                          }
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              greeting,
                              style: GoogleFonts.quicksand(
                                color: const Color(0xFF3B7268),
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const QuicklyFilter(),
                      ),
                      const SizedBox(height: 8),
                      _listView,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget get _listView => BlocBuilder<HomePageBloc, HomePageState>(
    builder: (context, state) => Expanded(
      child: Stack(
        children: [
          CommonListView(
            onLoadData: _fetchMotels,
            isLoading: state.isLoadingMore,
            isHaveData: state.hasMotels || state.isLoading,
            hasMoreData: state.hasMoreData,
            emptyWidget: const Center(
              child: Text('Không có dữ liệu phòng trọ nào.'),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: state.hasMotels
                    ? SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, idx) {
                          final motel = state.motels![idx];
                          return _MotelCard(
                            imageUrl: motel.thumbnail,
                            title: motel.name,
                            address: motel.address,
                            price: motel.price.toVND(),
                            motel: motel, // Pass the full motel object
                          );
                        }, childCount: state.motels!.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 185,
                        ),
                      )
                    : const SliverToBoxAdapter(child: SizedBox.shrink()),
              ),
            ],
          ),
          if (state.isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
        ],
      ),
    ),
  );
}

// Điều chỉnh _MotelCard
class _MotelCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String address;
  final String price;
  final Motel motel; // Add this field

  const _MotelCard({
    required this.imageUrl,
    required this.title,
    required this.address,
    required this.price,
    required this.motel, // Add this required parameter
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Wrap with InkWell for tap effect
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RoomDetailScreen(detail: motel, isBottomSheet: false),
            ),
          );
        },
        borderRadius: BorderRadius.circular(
          16,
        ), // Match container border radius
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: imageUrl.isEmpty
                    ? Container(
                        height: 93,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 93,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (c, e, s) => Container(
                          height: 93,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Text(e.toString()),
                                Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 18, // Reduced from 20
                      child: Text(
                        title,
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFF3B7268),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: const Color(0xFFFFB84C),
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              address,
                              style: GoogleFonts.quicksand(
                                color: const Color(0xFF757575),
                                fontSize: 11,
                                height: 1.2,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced from 8
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // Added this
                        children: [
                          Icon(
                            Icons.monetization_on,
                            color: const Color(0xFFFFB84C),
                            size: 13,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            price,
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFF757575),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
