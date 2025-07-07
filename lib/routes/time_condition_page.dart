import 'package:flutter/material.dart';
import '../widgets/smart_home_layout.dart';
import '../models/condition_model.dart';

/// 时间条件设置页面
class TimeConditionPage extends StatefulWidget {
  final Function(ConditionModel) onConditionSet;

  const TimeConditionPage({
    super.key,
    required this.onConditionSet,
  });

  @override
  State<TimeConditionPage> createState() => _TimeConditionPageState();
}

class _TimeConditionPageState extends State<TimeConditionPage> {
  String _selectedPeriod = '每天';
  String _startTime = '10:00';
  String _endTime = '11:00';

  @override
  Widget build(BuildContext context) {
    return SmartHomeLayout(
      title: '设置时间条件',
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
                
                // 时间周期
                _buildSectionTitle('时间周期'),
                const SizedBox(height: 12),
                _buildPeriodSelector(),
                
                const SizedBox(height: 20),
                
                // 选择时间
                _buildSectionTitle('选择时间'),
                const SizedBox(height: 12),
                _buildTimeSelector(),
                
                const SizedBox(height: 32),
                
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

  /// 构建周期选择器
  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            '选择周期',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _selectedPeriod,
            onChanged: (value) {
              setState(() {
                _selectedPeriod = value!;
              });
            },
            items: ['每天', '工作日', '周末'].map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            underline: Container(),
          ),
        ],
      ),
    );
  }

  /// 构建时间选择器
  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time,
            color: Color(0xFF3B82F6),
            size: 20,
          ),
          const SizedBox(width: 12),
          const Text(
            '选择时间',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _selectTime(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _startTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('—'),
          ),
          GestureDetector(
            onTap: () => _selectTime(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _endTime,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 选择时间
  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isStartTime) {
          _startTime = timeString;
        } else {
          _endTime = timeString;
        }
      });
    }
  }

  /// 处理确认操作
  void _handleConfirm() {
    final timeSettings = TimeSettings(
      period: _selectedPeriod,
      startTime: _startTime,
      endTime: _endTime,
    );

    final condition = ConditionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: ConditionType.time,
      title: '时间条件',
      description: '$_selectedPeriod $_startTime-$_endTime',
      settings: timeSettings.toMap(),
    );

    widget.onConditionSet(condition);
    Navigator.pop(context);
  }
} 