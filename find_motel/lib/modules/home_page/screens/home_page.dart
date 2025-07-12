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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Thay đổi số lượng items và thêm nhiều ảnh hơn
    final motels = List.generate(
      10,
      (i) => {
        'title': 'Căn hộ số 1',
        'address':
            'Ung Văn Khiêm, Bình Thạnh, Tp. Hồ Chí Minh Ung Văn Khiêm, Bình Thạnh, Tp. Hồ Chí Minh Ung Văn Khiêm, Bình Thạnh, Tp. Hồ Chí Minh',
        'price': '2,500,000đ',
        'image': [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
          'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6',
          'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
          'https://images.unsplash.com/photo-1507089947368-19c1da9775ae',
          'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
        ][i % 5],
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      16,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello Name's account",
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFF3B7268),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SearchBar(),
                      const SizedBox(height: 16),
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
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: motels.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              mainAxisExtent: 180, // Increased to fit content
                            ),
                        itemBuilder: (context, idx) {
                          final motel = motels[idx];
                          return _MotelCard(
                            imageUrl: motel['image']!,
                            title: motel['title']!,
                            address: motel['address']!,
                            price: motel['price']!,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
              child: Image.network(
                imageUrl,
                height: 93,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  height: 93,
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.image, size: 40, color: Colors.white),
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
