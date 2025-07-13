// ignore_for_file: unused_import

import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/modules/detail/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/services/motel/motels_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 600;
            final crossAxisCount = isDesktop ? 4 : 2;
            final padding = isDesktop ? 24.0 : 18.0;

            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : 430),
                margin: EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: isDesktop ? 16 : 0,
                ),
                color: Colors.white,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: padding,
                        vertical: padding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Header section
                          Text(
                            "Hello Name's account",
                            style: GoogleFonts.quicksand(
                              color: const Color(0xFF3B7268),
                              fontWeight: FontWeight.w600,
                              fontSize: isDesktop ? 24 : 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Search bar section
                          _SearchBar(),
                          const SizedBox(height: 16),
                          // Filter section - Make it always visible
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _FilterChip(
                                  label: 'Giá phòng',
                                  selected: true,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 10),
                                _FilterChip(
                                  label: 'Khu vực',
                                  selected: false,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 10),
                                _FilterChip(
                                  label: 'Loại phòng',
                                  selected: false,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: const Color(0xFFE0E0E0),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.tune,
                                    color: const Color(0xFF3B7268),
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      sliver: BlocBuilder<HomePageBloc, HomePageState>(
                        builder: (context, state) {
                          if (state is HomePageLoading) {
                            return const SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (state is HomePageError) {
                            return SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'Error: ${state.message}',
                                  style: GoogleFonts.quicksand(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (state is HomePageLoaded) {
                            return SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                idx,
                              ) {
                                final motel = state.motels[idx];
                                return _MotelCard(
                                  imageUrl: motel.thumbnail,
                                  title: motel.name,
                                  address: motel.address,
                                  price: '${motel.price.toStringAsFixed(0)}đ',
                                );
                              }, childCount: state.motels.length),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    mainAxisExtent: 185,
                                  ),
                            );
                          }

                          return const SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: const Color(0xFFBDBDBD), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập vào tên hoặc địa chỉ…',
                hintStyle: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFBDBDBD),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(label: 'Giá phòng', selected: true, onTap: () {}),
        const SizedBox(width: 10),
        _FilterChip(label: 'Khu vực', selected: false, onTap: () {}),
        const SizedBox(width: 10),
        _FilterChip(label: 'Loại phòng', selected: false, onTap: () {}),
        const SizedBox(width: 10),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.tune, color: const Color(0xFF3B7268), size: 22),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF3B7268) : Colors.white,
      borderRadius: BorderRadius.circular(44),
      child: InkWell(
        borderRadius: BorderRadius.circular(44),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(44),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  color: selected ? Colors.white : const Color(0xFF3B7268),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: selected ? Colors.white : const Color(0xFF3B7268),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Điều chỉnh _MotelCard
class _MotelCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String address;
  final String price;

  const _MotelCard({
    required this.imageUrl,
    required this.title,
    required this.address,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
                      decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Image.network(
                      imageUrl,
                      height: 93,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 93,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0E0E0),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 40,
                            color: Colors.white,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 2), // Reduced from 8
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
    );
  }
}
