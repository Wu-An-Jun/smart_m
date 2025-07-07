import 'package:flutter/material.dart';
import '../models/condition_model.dart';
import '../widgets/smart_home_layout.dart';

/// 环境条件设置页面
class EnvironmentConditionPage extends StatefulWidget {
  final Function(ConditionModel) onConditionSet;

  const EnvironmentConditionPage({
    super.key, 
    required this.onConditionSet
  });

  @override
  State<EnvironmentConditionPage> createState() => _EnvironmentConditionPageState();
}

class _EnvironmentConditionPageState extends State<EnvironmentConditionPage> {
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();

  String _temperatureComparison = '当温度到达';
  String _humidityComparison = '当湿度到达';
  String _selectedWeather = '晴天';
  String _selectedCity = '北京';

  @override
  Widget build(BuildContext context) {
    return SmartHomeLayout(
      title: '设置环境条件',
      showBackButton: true,
      child: Container(
        color: const Color(0xFFE9D5FF),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                const Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      color: Color(0xFF7C3AED),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '自动化设置',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 温度变化
                _buildSectionTitle('温度变化'),
                const SizedBox(height: 10),
                _buildTemperatureOption('当温度到达', true),
                const SizedBox(height: 6),
                _buildTemperatureOption('当温度低于', false),

                const SizedBox(height: 16),

                // 湿度变化
                _buildSectionTitle('湿度变化'),
                const SizedBox(height: 10),
                _buildHumidityOption('当湿度到达', true),
                const SizedBox(height: 6),
                _buildHumidityOption('当湿度低于', false),

                const SizedBox(height: 16),

                // 天气变化
                _buildSectionTitle('天气变化'),
                const SizedBox(height: 10),
                _buildWeatherOption(),

                const SizedBox(height: 24),

                // 按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C3AED),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '确定',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.edit, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFF9CA3AF)),
                        ),
                        child: const Text(
                          '取消',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    );
  }

  /// 构建温度选项
  Widget _buildTemperatureOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: _temperatureComparison,
            onChanged: (value) {
              setState(() {
                _temperatureComparison = value!;
              });
            },
            activeColor: const Color(0xFF7C3AED),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: TextField(
              controller: _temperatureController,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onTap: () {
                setState(() {
                  _temperatureComparison = label;
                });
              },
            ),
          ),
          const Text(
            '℃',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  /// 构建湿度选项
  Widget _buildHumidityOption(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: _humidityComparison,
            onChanged: (value) {
              setState(() {
                _humidityComparison = value!;
              });
            },
            activeColor: const Color(0xFF7C3AED),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: TextField(
              controller: _humidityController,
              decoration: InputDecoration(
                hintText: label,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onTap: () {
                setState(() {
                  _humidityComparison = label;
                });
              },
            ),
          ),
          const Text(
            '%',
            style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  /// 构建天气选项
  Widget _buildWeatherOption() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Radio<String>(
            value: '天气',
            groupValue: '天气',
            onChanged: null,
            activeColor: Color(0xFF7C3AED),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.wb_sunny, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 10),
          const Text(
            '当城市天气为',
            style: TextStyle(fontSize: 14, color: Color(0xFF111827)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedWeather,
              onChanged: (value) {
                setState(() {
                  _selectedWeather = value!;
                });
              },
              items: ['晴天', '下雨', '下雪', '多云'].map((weather) {
                return DropdownMenuItem(value: weather, child: Text(weather));
              }).toList(),
              underline: Container(),
              isExpanded: true,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  /// 处理确认操作
  void _handleConfirm() {
    final environmentSettings = EnvironmentSettings(
      targetTemperature: double.tryParse(_temperatureController.text),
      temperatureComparison: _temperatureComparison,
      targetHumidity: double.tryParse(_humidityController.text),
      humidityComparison: _humidityComparison,
      weather: _selectedWeather,
      city: _selectedCity,
    );

    final condition = ConditionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ConditionType.environment,
      title: '环境条件',
      description: _buildConditionDescription(environmentSettings),
      settings: environmentSettings.toMap(),
    );

    widget.onConditionSet(condition);
    Navigator.pop(context);
  }

  /// 构建条件描述
  String _buildConditionDescription(EnvironmentSettings settings) {
    List<String> parts = [];

    if (settings.targetTemperature != null) {
      parts.add(
        '${settings.temperatureComparison} ${settings.targetTemperature}℃',
      );
    }

    if (settings.targetHumidity != null) {
      parts.add(
        '${settings.humidityComparison} ${settings.targetHumidity}%',
      );
    }

    if (settings.weather != null) {
      parts.add('天气: ${settings.weather}');
    }

    return parts.isEmpty ? '环境条件' : parts.join(', ');
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _humidityController.dispose();
    super.dispose();
  }
} 