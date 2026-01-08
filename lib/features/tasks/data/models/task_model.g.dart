// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaskModelImpl _$$TaskModelImplFromJson(Map<String, dynamic> json) =>
    _$TaskModelImpl(
      id: _readId(json, 'id') as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$TaskModelImplToJson(_$TaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'completed': instance.completed,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$CreateTaskDtoImpl _$$CreateTaskDtoImplFromJson(Map<String, dynamic> json) =>
    _$CreateTaskDtoImpl(
      title: json['title'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$CreateTaskDtoImplToJson(_$CreateTaskDtoImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
    };

_$UpdateTaskDtoImpl _$$UpdateTaskDtoImplFromJson(Map<String, dynamic> json) =>
    _$UpdateTaskDtoImpl(completed: json['completed'] as bool?);

Map<String, dynamic> _$$UpdateTaskDtoImplToJson(_$UpdateTaskDtoImpl instance) =>
    <String, dynamic>{'completed': instance.completed};
