import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/managers/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/setting_page_bloc.dart';
import '../bloc/setting_page_event.dart';
import '../bloc/setting_page_state.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/services/image_picker/image_picker_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late ImagePickerService _imagePickerService;

  // Danh sách tạm thời để giữ các URL ảnh đã chọn
  // Bạn sẽ cần tích hợp danh sách này với Bloc/Cubit của SettingBloc sau
  final List<String> _selectedImageUrls = [];

  @override
  void initState() {
    super.initState();
    context.read<SettingBloc>().add(const LoadSettingEvent());
    // Khởi tạo ImagePickerService trong initState
    _imagePickerService = ImagePickerService(
      context: context, // Truyền context hiện tại
      options: AppDataManager().importImagesOptions?.imageSourceOptions() ?? [],
      addImagesToList: (urls) {
        // Callback này sẽ được gọi khi ảnh được chọn
        if (mounted) {
          setState(() {
            _selectedImageUrls.addAll(urls);
          });
          // Hoặc một Event khác để xử lý danh sách ảnh
          if (urls.isNotEmpty) {
            context.read<SettingBloc>().add(AvatarChanged(urls.first));
            print(urls);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingBloc, SettingState>(
      listener: (context, state) {
        if (state.isSaved) {
          context.read<UserProfileCubit>().updateUserProfile(
            AppDataManager().currentUserProfile!.copyWith(
              name: state.name,
              avatar: state.avatar,
            ),
          );
          Navigator.pop(context);
        }
      },
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
                      radius: 51,
                      backgroundColor: AppColors.strokeHighLight,
                      child: state.avatar != null && state.avatar!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: state.avatar!,
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipOval(
                              child: Image.asset(
                                'assets/images/avatarDefaut.png',
                                width: 100,
                                height: 100,
                                alignment: Alignment.center,
                                fit: BoxFit.cover,
                              ),
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
                          onPressed: () =>
                              _imagePickerService.showAddImageOptions(),
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
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

_divider() =>
    const Divider(height: 80.0, thickness: 1.0, color: AppColors.strokeLight);
