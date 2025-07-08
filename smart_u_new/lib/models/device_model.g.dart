// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeviceModelAdapter extends TypeAdapter<DeviceModel> {
  @override
  final int typeId = 3;

  @override
  DeviceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeviceModel(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as DeviceType,
      category: fields[3] as DeviceCategory,
      isOnline: fields[4] as bool,
      lastSeen: fields[5] as DateTime,
      description: fields[6] as String?,
      imageUrl: fields[7] as String?,
      videoUrl: fields[8] as String?,
      properties: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, DeviceModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isOnline)
      ..writeByte(5)
      ..write(obj.lastSeen)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.videoUrl)
      ..writeByte(9)
      ..write(obj.properties);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeviceTypeAdapter extends TypeAdapter<DeviceType> {
  @override
  final int typeId = 1;

  @override
  DeviceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeviceType.camera;
      case 1:
        return DeviceType.map;
      case 2:
        return DeviceType.petTracker;
      case 3:
        return DeviceType.smartSwitch;
      case 4:
        return DeviceType.router;
      case 5:
        return DeviceType.light;
      default:
        return DeviceType.camera;
    }
  }

  @override
  void write(BinaryWriter writer, DeviceType obj) {
    switch (obj) {
      case DeviceType.camera:
        writer.writeByte(0);
        break;
      case DeviceType.map:
        writer.writeByte(1);
        break;
      case DeviceType.petTracker:
        writer.writeByte(2);
        break;
      case DeviceType.smartSwitch:
        writer.writeByte(3);
        break;
      case DeviceType.router:
        writer.writeByte(4);
        break;
      case DeviceType.light:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeviceCategoryAdapter extends TypeAdapter<DeviceCategory> {
  @override
  final int typeId = 2;

  @override
  DeviceCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeviceCategory.pet;
      case 1:
        return DeviceCategory.living;
      case 2:
        return DeviceCategory.security;
      case 3:
        return DeviceCategory.navigation;
      default:
        return DeviceCategory.pet;
    }
  }

  @override
  void write(BinaryWriter writer, DeviceCategory obj) {
    switch (obj) {
      case DeviceCategory.pet:
        writer.writeByte(0);
        break;
      case DeviceCategory.living:
        writer.writeByte(1);
        break;
      case DeviceCategory.security:
        writer.writeByte(2);
        break;
      case DeviceCategory.navigation:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
