// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_place_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$SearchPlaceRequestToJson(SearchPlaceRequest instance) =>
    <String, dynamic>{
      'textQuery': instance.textQuery,
      'locationBias': instance.locationBias,
    };

Map<String, dynamic> _$LocationBiasToJson(LocationBias instance) =>
    <String, dynamic>{'circle': instance.circle};

Map<String, dynamic> _$CircleToJson(Circle instance) => <String, dynamic>{
  'center': instance.center,
  'radius': instance.radius,
};

Map<String, dynamic> _$CenterToJson(Center instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
