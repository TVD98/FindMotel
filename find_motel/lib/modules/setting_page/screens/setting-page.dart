import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/setting_page_bloc.dart';
import '../bloc/setting_page_event.dart';
import '../bloc/setting_page_state.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SettingBloc>().add(const LoadSettingEvent());
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    // Nếu không có file nào được chọn, thoát hàm
    if (pickedFile == null) return;
    context.read<SettingBloc>().add(AvatarChanged(pickedFile.path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SettingBloc(),
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          return Scaffold(
            appBar: CommonAppBar(
              title: 'Cài đặt',
              leadingAsset: 'assets/images/ic_back.svg',
              onLeadingPressed: () => Navigator.pop(context),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: state.avatar != null && state.avatar!.isNotEmpty
                            ? Image.network(
                                state.avatar!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/avatarDefaut.png',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.strokeLight,
                              width: 1,
                              strokeAlign: BorderSide.strokeAlignInside,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.onPrimary,
                              size: 24,
                            ),
                            onPressed: () => _pickImage(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 24.0,
                              height: 24.0,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _divider(),
                  TextField(
                    onChanged: (value) =>
                        context.read<SettingBloc>().add(UsernameChanged(value)),
                    decoration: InputDecoration(
                      hintText: (state.name?.isEmpty ?? true)
                          ? 'Nhập tên người dùng'
                          : state.name ?? '',
                      hintStyle: const TextStyle(
                        color: AppColors.tertiary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                          color: AppColors.strokeLight,
                          width: 1.0,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.onSurface1,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  _divider(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: CustomButton(
                      title: state.isSaving ? 'Đang lưu...' : 'Lưu cài đặt',
                      radius: 10.0,
                      onPressed: state.isSaving
                          ? null
                          : () {
                              context.read<SettingBloc>().add(SaveSetting());
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cài đặt đã được lưu!'),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

_divider() =>
    const Divider(height: 80.0, thickness: 1.0, color: AppColors.strokeLight);
