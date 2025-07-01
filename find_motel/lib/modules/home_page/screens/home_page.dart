import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:find_motel/modules/detail/detail_screen.dart';
import 'package:find_motel/modules/detail/detail_motel_model.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomePageBloc, HomePageState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.message,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const Text(
                'This is the main page of the app.',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showRoomDetailBottomSheet(context);
                  // FirebaseAuth.instance.signOut();
                  // context.read<HomePageBloc>().add(HomePageEvent.updateMessage);
                },
                child: const Text('Update Message'),
              ),
            ],
          ),
        );
      },
    );
  }
}

void showRoomDetailBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Cho phép bottom sheet chiếm gần hết màn hình
    backgroundColor: Colors.transparent, // Nền trong suốt để bo góc
    builder: (context) => RoomDetailScreen(
      detail: RoomDetail(
        address: "9/6 Đào Duy Từ, Phú Nhuận",
        commission: "40-70",
        extensions: ["Xe"],
        fees: [
          {"name": "Điện", "price": 4000, "unit": "số"},
          {"name": "Nước", "price": 100000, "unit": "người"},
          {"name": "Phí dịch vụ", "price": 150000, "unit": "người"},
        ],
        geoPoint: [10.793552547999306, 106.670685567481],
        name: "Midori",
        note: ["Xe thứ 2 mang đi gửi 250k/xe"],
        price: 6500000,
        id: "L3",
        typeRoom: "S2",
        images: [
          "https://images.unsplash.com/photo-1607712617949-8c993d290809?q=80&w=1035&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "https://images.unsplash.com/photo-1591825729269-caeb344f6df2?q=80&w=2340&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80",
          "",
          "1",
          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80",
          "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1470&q=80",
        ],
        mainImage: "",
      ),
    ),
  );
}
