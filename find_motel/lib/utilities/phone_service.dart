import 'package:find_motel/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_motel/theme/app_colors.dart';

class PhoneContact {
  final String name;
  final String phone;

  PhoneContact({required this.name, required this.phone});
}

class PhoneService {
  final List<PhoneContact> _hotlineNumbers;

  PhoneService({required List<PhoneContact> hotlineNumbers})
    : _hotlineNumbers = hotlineNumbers;

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Hiển thị thông báo nếu không thể thực hiện cuộc gọi
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể thực hiện cuộc gọi.')),
      );
    }
  }

  // Hàm hiển thị bottom sheet
  void showHotlineBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Danh sách hotline',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _hotlineNumbers.length,
                itemBuilder: (context, index) {
                  final contact = _hotlineNumbers[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.phone,
                      color: AppColors.elementPrimary,
                    ),
                    title: Text(
                      contact.phone.formatPhoneNumber(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.elementPrimary,
                      ),
                    ),
                    onTap: () {
                      _makePhoneCall(context, contact.phone);
                      Navigator.pop(context); // Đóng bottom sheet sau khi chọn
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
