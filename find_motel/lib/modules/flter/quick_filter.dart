import 'package:find_motel/common/widgets/common_container.dart';
import 'package:find_motel/common/widgets/common_search.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:find_motel/modules/flter/filter_page.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class QuickFilter extends StatefulWidget {
  const QuickFilter({super.key});

  @override
  State<QuickFilter> createState() => _QuickFilterState();
}

class _QuickFilterState extends State<QuickFilter> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MotelsFilterCubit, MotelsFilter>(
      builder: (context, state) {
        return Column(
          children: [
            SearchBarWithCallback(
              initialText: state.keywords ?? '',
              hintText: 'Nhập vào tên hoặc địa chỉ…',
              onSearchPressed: (value) {
                context.read<MotelsFilterCubit>().search(value);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _iconFilter(context),
                  const SizedBox(width: 10),
                  _FilterChip(label: 'Giá phòng', selected: true, onTap: () {}),
                  const SizedBox(width: 10),
                  _FilterChip(label: 'Khu vực', selected: false, onTap: () {}),
                  const SizedBox(width: 10),
                  _FilterChip(
                    label: 'Loại phòng',
                    selected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _iconFilter(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<MotelsFilterCubit>(),
              child: const FilterPage(),
            ),
          ),
        );
      },
      child: CommonContainer(
        child: SvgPicture.asset(
          'assets/images/ic_filter.svg',
          width: 20,
          height: 20,
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
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
                style: TextStyle(
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
