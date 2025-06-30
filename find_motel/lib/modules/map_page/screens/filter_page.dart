// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/modules/map_page/bloc/map_page_bloc.dart';
import 'package:find_motel/modules/map_page/bloc/map_page_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final List<String> _roomCodes = [
    'PH001',
    'PH002',
    'PH003',
  ]; // Danh sách mã phòng mẫu
  final List<String> _provinces = [
    'Hà Nội',
    'Hồ Chí Minh',
    'Đà Nẵng',
  ]; // Danh sách tỉnh mẫu
  final Map<String, List<String>> _wards = {
    'Hà Nội': ['Hoàn Kiếm', 'Ba Đình', 'Đống Đa'],
    'Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Quận 5'],
    'Đà Nẵng': ['Hải Châu', 'Thanh Khê', 'Sơn Trà'],
  }; // Danh sách phường mẫu
  final List<String> _amenities = ['elevator', 'parking']; // Danh sách tiện ích
  final List<String> _statuses = [
    'trống',
    'đặt cọc',
    'đã thuê',
  ]; // Danh sách tình trạng

  String? _selectedRoomCode;
  String? _selectedProvince;
  String? _selectedWard;
  final Map<String, bool> _selectedAmenities = {
    'elevator': false,
    'parking': false,
  };
  String? _selectedStatus;
  double _priceValue = 0; // 0: 0-3tr, 1: 3-5tr, 2: 5-8tr, 3: >8tr
  double _distanceValue = 0; // 0: <1km, 1: 1-5km, 2: 5-10km, 3: >10km

  @override
  void initState() {
    super.initState();
    _selectedProvince = _provinces.first; // Mặc định chọn tỉnh đầu tiên
    _selectedWard =
        _wards[_selectedProvince]!.first; // Mặc định chọn phường đầu tiên
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lọc nhà trọ', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mã phòng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRoomCode,
                hint: const Text('Chọn mã phòng'),
                items: _roomCodes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRoomCode = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Divider(height: 32),
              const Text(
                'Khu vực',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedProvince,
                      hint: const Text('Chọn tỉnh'),
                      items: _provinces.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProvince = value;
                          _selectedWard =
                              _wards[value]!.first; // Reset phường khi đổi tỉnh
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedWard,
                      hint: const Text('Chọn phường'),
                      items: _wards[_selectedProvince]?.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWard = value;
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Tiện ích',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._amenities.map((amenity) {
                return CheckboxListTile(
                  title: Text(_getAmenityName(amenity)),
                  value: _selectedAmenities[amenity],
                  onChanged: (value) {
                    setState(() {
                      _selectedAmenities[amenity] = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const Divider(height: 32),
              const Text(
                'Tình trạng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._statuses.map((status) {
                return RadioListTile<String>(
                  title: Text(status),
                  value: status,
                  groupValue: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                );
              }),
              const Divider(height: 32),
              const Text(
                'Giá thuê (triệu VND)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _priceValue,
                min: 0,
                max: 3,
                divisions: 3,
                label: _getPriceLabel(_priceValue),
                onChanged: (value) {
                  setState(() {
                    _priceValue = value;
                  });
                },
              ),
              const Divider(height: 32),
              const Text(
                'Phạm vi (km)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Slider(
                value: _distanceValue,
                min: 0,
                max: 3,
                divisions: 3,
                label: _getDistanceLabel(_distanceValue),
                onChanged: (value) {
                  setState(() {
                    _distanceValue = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      final selectedAmenities = _selectedAmenities.entries
                          .where((entry) => entry.value)
                          .map((entry) => entry.key)
                          .toList();
                      context.read<MapBloc>().add(
                        FilterMarkersEvent(
                          roomCode: _selectedRoomCode,
                          province: _selectedProvince,
                          ward: _selectedWard,
                          amenities: selectedAmenities.isEmpty
                              ? null
                              : selectedAmenities,
                          status: _selectedStatus,
                          priceRange: _getPriceRange(_priceValue),
                          distanceRange: _getDistanceRange(_distanceValue),
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAmenityName(String key) {
    switch (key) {
      case 'elevator':
        return 'Thang Máy';
      case 'parking':
        return 'Chỗ để xe';
      default:
        return key;
    }
  }

  String _getPriceLabel(double value) {
    switch (value.toInt()) {
      case 0:
        return '0-3 triệu';
      case 1:
        return '3-5 triệu';
      case 2:
        return '5-8 triệu';
      case 3:
        return '>8 triệu';
      default:
        return '';
    }
  }

  String _getDistanceLabel(double value) {
    switch (value.toInt()) {
      case 0:
        return '<1 km';
      case 1:
        return '1-5 km';
      case 2:
        return '5-10 km';
      case 3:
        return '>10 km';
      default:
        return '';
    }
  }

  String _getPriceRange(double value) {
    switch (value.toInt()) {
      case 0:
        return '0-3';
      case 1:
        return '3-5';
      case 2:
        return '5-8';
      case 3:
        return '>8';
      default:
        return '';
    }
  }

  String _getDistanceRange(double value) {
    switch (value.toInt()) {
      case 0:
        return '<1';
      case 1:
        return '1-5';
      case 2:
        return '5-10';
      case 3:
        return '>10';
      default:
        return '';
    }
  }
}
