import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/double_extensions.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

class ShareService {
  static Future<void> shareMotelInfo(Motel motel, BuildContext context) async {
    // Hiển thị dialog cho user chọn
    final shareOption = await _showShareOptionsDialog(context);

    if (shareOption == null) return; // User cancel

    try {
      final String shareText = shareOption == 'facebook'
          ? _buildShareTextForFacebook(motel)
          : _buildShareTextStandard(motel);

      final result = await Share.shareWithResult(
        shareText,
        subject: 'Phòng trọ ${motel.displayName}',
      );

      print('Share result: ${result.status}');
    } catch (e) {
      print('Share error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chia sẻ: $e')));
      }
    }
  }

  // Dialog để user chọn kiểu share - UI cải thiện
  static Future<String?> _showShareOptionsDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Chọn cách chia sẻ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chọn định dạng phù hợp:',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Facebook Option
              _buildShareOptionCard(
                icon: Icons.facebook,
                iconColor: Color(0xFF1877F2),
                title: 'Tạo bài post Facebook',
                subtitle: 'Link có dấu cách (tối ưu hiển thị)',
                onTap: () => Navigator.of(context).pop('facebook'),
              ),

              SizedBox(height: 12),

              // Standard Option
              _buildShareOptionCard(
                icon: Icons.share,
                iconColor: Color(0xFF4CAF50),
                title: 'Chia sẻ khác',
                subtitle: 'Zalo, Messenger, Email... (link chuẩn)',
                onTap: () => Navigator.of(context).pop('standard'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  // Widget tạo card option đẹp
  static Widget _buildShareOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Helper function để break link cho Facebook
  static String _breakLinkForFacebook(String url) {
    return url
        .replaceAll('https://', 'https:// ')
        .replaceAll('http://', 'http:// ')
        .replaceAll('.com', ' .com')
        .replaceAll('.google', ' .google')
        .replaceAll('/', ' / ');
  }

  // Build text cho Facebook (broken links)
  static String _buildShareTextForFacebook(Motel motel) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('🏠 PHÒNG TRỌ ${motel.displayName.toUpperCase()}');
    buffer.writeln('');

    buffer.writeln('💰 Giá: ${motel.price.toVND()}/tháng');
    buffer.writeln('🤝 Hoa hồng: ${motel.commission}');
    buffer.writeln('🏗️ Loại: ${motel.texture} - ${motel.type}');
    buffer.writeln('');

    buffer.writeln('📍 Địa chỉ: ${motel.address}');
    buffer.writeln('');

    // Tiện ích
    if (motel.extensions.isNotEmpty) {
      buffer.writeln('⭐ Tiện ích:');
      for (String extension in motel.extensions.take(5)) {
        buffer.writeln('  • $extension');
      }
      if (motel.extensions.length > 5) {
        buffer.writeln(
          '  • ... và ${motel.extensions.length - 5} tiện ích khác',
        );
      }
      buffer.writeln('');
    }

    // Xe
    if (motel.car.isNotEmpty) {
      buffer.writeln('🚗 Chỗ để xe: ${motel.car}');
      buffer.writeln('');
    }

    // Chi phí khác
    if (motel.fees.isNotEmpty) {
      buffer.writeln('💸 Chi phí khác:');
      for (var fee in motel.fees.take(3)) {
        buffer.writeln('  • ${fee.name}: ${fee.price.toVND()}/${fee.unit}');
      }
      if (motel.fees.length > 3) {
        buffer.writeln('  • ... và ${motel.fees.length - 3} khoản khác');
      }
      buffer.writeln('');
    }

    // Ghi chú
    if (motel.note.isNotEmpty) {
      buffer.writeln('📝 Lưu ý:');
      for (String note in motel.note.take(3)) {
        buffer.writeln('  • $note');
      }
      if (motel.note.length > 3) {
        buffer.writeln('  • ... và ${motel.note.length - 3} lưu ý khác');
      }
      buffer.writeln('');
    }

    // Liên hệ
    if (motel.phoneNumbers.isNotEmpty) {
      buffer.writeln('📞 Liên hệ: ${motel.phoneNumbers.join(', ')}');
      buffer.writeln('');
    }

    // Links ảnh với broken format cho Facebook
    if (motel.images.isNotEmpty) {
      buffer.writeln('📸 Hình ảnh phòng trọ:');

      int displayCount = 0;
      for (int i = 0; i < motel.images.length && displayCount < 3; i++) {
        final imageUrl = motel.images[i];

        if (imageUrl.contains('/folders/')) {
          final brokenLink = _breakLinkForFacebook(imageUrl);
          buffer.writeln('📁 Album ảnh: $brokenLink');
          displayCount++;
          break;
        } else if (imageUrl.startsWith('http')) {
          final brokenLink = _breakLinkForFacebook(imageUrl);
          buffer.writeln('🖼️ Ảnh ${displayCount + 1}: $brokenLink');
          displayCount++;
        }
      }

      if (motel.images.length > displayCount) {
        buffer.writeln('... và ${motel.images.length - displayCount} ảnh khác');
      }

      buffer.writeln('💡 Xóa dấu cách trong link để xem ảnh');
      buffer.writeln('');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📱 Từ ứng dụng FindMotel');

    return buffer.toString();
  }

  // Build text chuẩn (links bình thường)
  static String _buildShareTextStandard(Motel motel) {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('🏠 PHÒNG TRỌ ${motel.displayName.toUpperCase()}');
    buffer.writeln('');

    buffer.writeln('💰 Giá: ${motel.price.toVND()}/tháng');
    buffer.writeln('🤝 Hoa hồng: ${motel.commission}');
    buffer.writeln('🏗️ Loại: ${motel.texture} - ${motel.type}');
    buffer.writeln('');

    buffer.writeln('📍 Địa chỉ: ${motel.address}');
    buffer.writeln('');

    // Tiện ích
    if (motel.extensions.isNotEmpty) {
      buffer.writeln('⭐ Tiện ích:');
      for (String extension in motel.extensions.take(5)) {
        buffer.writeln('  • $extension');
      }
      if (motel.extensions.length > 5) {
        buffer.writeln(
          '  • ... và ${motel.extensions.length - 5} tiện ích khác',
        );
      }
      buffer.writeln('');
    }

    // Xe
    if (motel.car.isNotEmpty) {
      buffer.writeln('🚗 Chỗ để xe: ${motel.car}');
      buffer.writeln('');
    }

    // Chi phí khác
    if (motel.fees.isNotEmpty) {
      buffer.writeln('💸 Chi phí khác:');
      for (var fee in motel.fees.take(3)) {
        buffer.writeln('  • ${fee.name}: ${fee.price.toVND()}/${fee.unit}');
      }
      if (motel.fees.length > 3) {
        buffer.writeln('  • ... và ${motel.fees.length - 3} khoản khác');
      }
      buffer.writeln('');
    }

    // Ghi chú
    if (motel.note.isNotEmpty) {
      buffer.writeln('📝 Lưu ý:');
      for (String note in motel.note.take(3)) {
        buffer.writeln('  • $note');
      }
      if (motel.note.length > 3) {
        buffer.writeln('  • ... và ${motel.note.length - 3} lưu ý khác');
      }
      buffer.writeln('');
    }

    // Liên hệ
    if (motel.phoneNumbers.isNotEmpty) {
      buffer.writeln('📞 Liên hệ: ${motel.phoneNumbers.join(', ')}');
      buffer.writeln('');
    }

    // Links ảnh chuẩn
    if (motel.images.isNotEmpty) {
      buffer.writeln('📸 Hình ảnh phòng trọ:');

      int displayCount = 0;
      for (int i = 0; i < motel.images.length && displayCount < 3; i++) {
        final imageUrl = motel.images[i];

        if (imageUrl.contains('/folders/')) {
          buffer.writeln('📁 Album ảnh: $imageUrl');
          displayCount++;
          break;
        } else if (imageUrl.startsWith('http')) {
          buffer.writeln('🖼️ Ảnh ${displayCount + 1}: $imageUrl');
          displayCount++;
        }
      }

      if (motel.images.length > displayCount) {
        buffer.writeln('... và ${motel.images.length - displayCount} ảnh khác');
      }
      buffer.writeln('');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📱 Từ ứng dụng FindMotel');

    return buffer.toString();
  }
}
