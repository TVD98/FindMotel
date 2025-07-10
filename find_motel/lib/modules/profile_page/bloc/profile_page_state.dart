class FutureInfo {
  String title;
  String description;
  String icon;

  FutureInfo({
    required this.title,
    required this.description,
    required this.icon,
  });
}

enum Future {
  customer,
  import;

  FutureInfo get info {
    switch (this) {
      case Future.customer:
        return FutureInfo(
          title: 'Danh sách Khách Hàng',
          description: 'Khách hàng tiềm năng có lịch hẹn',
          icon: 'assets/images/ic_check_list.png',
        );
      case Future.import:
        return FutureInfo(
          title: 'Nhập dữ liệu',
          description: 'Thêm danh sách khách hàng từ file excel',
          icon: 'assets/images/ic_import.png',
        );
    }
  }
}

class ProfileState {
  final String? name;
  final String? avatar;
  final String? email;
  final List<Future> futures;
  ProfileState({this.name, this.avatar, this.email, this.futures = const []});

  ProfileState copyWith({String? name, String? avatar, String? email, List<Future>? futures}) {
    return ProfileState(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      futures: futures ?? this.futures,
    );
  }
}
