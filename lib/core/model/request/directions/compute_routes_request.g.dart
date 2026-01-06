// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compute_routes_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$ComputeRoutesRequestToJson(
  ComputeRoutesRequest instance,
) => <String, dynamic>{
  'origin': instance.origin,
  'destination': instance.destination,
  'travelMode': instance.travelMode,
  'routingPreference': instance.routingPreference,
  'computeAlternativeRoutes': instance.computeAlternativeRoutes,
  'units': instance.units,
};

Map<String, dynamic> _$RouteLocationToJson(RouteLocation instance) =>
    <String, dynamic>{'location': instance.location};

Map<String, dynamic> _$LocationWrapperToJson(LocationWrapper instance) =>
    <String, dynamic>{'latLng': instance.latLng};

Map<String, dynamic> _$LatLngToJson(LatLng instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
