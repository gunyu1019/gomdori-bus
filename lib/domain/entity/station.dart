import 'dart:convert';
import 'dart:math' as math;
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

/// 정차하는 정류장의 정보를 담고 있는 개체입니다.
class Station {
  /// 정류장 고유번호입니다.
  /// 고유번호를 통해 다른 방향의 정류장을 식별합니다.
  final int id;

  /// 정류장 이름입니다.
  final String name;

  /// 정류장의 좌표입니다.
  final LatLng position;

  /// 前정류장부터 現정류장까지의 경로를 WGS84로 나타냅니다.
  final List<LatLng> route;

  /// 정류장의 시간표입니다.
  /// 키: 정류장에 정차하는 회차 (ex. 9회차에 정차하지 않으면 작성하지 않습니다.)
  /// 값: 정류장에 정차하는 시간
  final Map<String, DateTime> time;

  /// 상행, 하행을 구분합니다.
  final bool direction;

  /// 前정류장부터 現정류장의 직선 거리입니다.
  late final double distance;

  /// 前정류장부터 現정류장의 실제 거리입니다.
  late final double actualDistance;

  /// 前정류장부터 現정류장까지 실제 거리를 배열에 담습니다.
  /// 한 노드를 이동하는 데, 소요되는 거리를 담는 비공개 필드입니다.
  late final List<double> _actualRouteDistance;

  Station(
    this.id,
    this.name,
    this.position,
    this.direction,
    this.route,
    this.time,
  ) {
    distance = route.isEmpty ? 0 : route.first.distance(position);
    _actualRouteDistance =
        route.length > 1
            ? route
                .sublist(0, route.length - 1)
                .asMap()
                .entries
                .map(
                  (element) => element.value.distance(route[element.key + 1]),
                )
                .toList()
            : [0, 0];
    actualDistance = _actualRouteDistance.reduce(
      (element1, element2) => element1 + element2,
    );
  }

  /// 남은 거리를 기준으로 현재 버스가 어디있는지 나타냅니다.
  /// [percent]는 前정류장부터 現정류장까지 소요시간 / (소요시간-현재시간)을 나타냅니다.
  LatLng currentPoint(double percent) {
    // 남은 거리
    double remainingDistance = actualDistance * percent;

    for (final node in _actualRouteDistance.asMap().entries) {
      if (remainingDistance - node.value < 0) {
        // 방위각 계산
        final radian = math.pi / 180;
        final latitude1 = (route[node.key].latitude) * radian;
        final latitude2 = (route[node.key + 1].latitude) * radian;
        final relativeLongtitude =
            (route[node.key].longitude - route[node.key + 1].longitude).abs() *
            radian;

        final x = math.sin(relativeLongtitude) * math.cos(latitude2);
        final y =
            math.cos(latitude1) * math.sin(latitude2) -
            (math.sin(latitude1) *
                math.cos(latitude2) *
                math.cos(relativeLongtitude));
        final initialBearing = math.atan2(x, y) * (180 / math.pi);
        final compassBearing = (initialBearing + 360) % 360;

        return route[node.key].offset(remainingDistance, compassBearing);
      }
      remainingDistance -= node.value;
    }
    return position;
  }

  @override
  String toString() {
    return 'Station(name: $name, position: $position, direction: $direction, actualDistance: $actualDistance, distance: $distance)';
  }

  /// [compareTime] 이후에 정차하는 시간표 중 가장 가까운 시간을 반환합니다.
  /// 만약 운행 시간을 경과하여 운행이 종료된 경우 null을 반환합니다.
  MapEntry<String, DateTime>? nearTimetable([DateTime? compareTime]) {
    final rawCompareTime = compareTime ?? DateTime.now();
    if (rawCompareTime.hour < 5) {
      // 05:00 이전에는 운행이 종료된 것으로 간주합니다.
      return null;
    }

    final entries = time.entries.where(
      (element) => element.value.compareTo(rawCompareTime) >= 0,
    );
    if (entries.isEmpty) {
      return null;
    }
    return entries.reduce((a, b) => a.value.compareTo(b.value) <= 0 ? a : b);
  }

  @override
  bool operator ==(covariant Station other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.position == position &&
        other.direction == direction;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        position.hashCode ^
        direction.hashCode ^
        distance.hashCode ^
        actualDistance.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'position': position.toMessageable(),
      'direction': direction,
      'route': route.map((x) => x.toMessageable()).toList(),
      'time': time.map((k, v) => MapEntry(k, v.hour * 60 + v.minute)),
    };
  }

  factory Station.fromMap(Map<String, dynamic> payload) => Station(
    payload["id"] as int,
    payload['name'] as String,
    LatLng.fromMessageable(payload['position']),
    payload['direction'] as bool,
    payload['route'].map<LatLng>(LatLng.fromMessageable).toList(),
    Map<String, dynamic>.from(payload['time']).map(
      (key, value) => MapEntry(
        key,
        DateTime.now().copyWith(
          hour: (value / 60).toInt(),
          minute: value % 60,
          second: 0,
          microsecond: 0,
          millisecond: 0,
        ),
      ),
    ),
  );

  String toJson() => json.encode(toMap());

  factory Station.fromJson(String source) =>
      Station.fromMap(json.decode(source) as Map<String, dynamic>);
  
  factory Station.mock() => Station(
    0,
    "백록관",
    LatLng(37.86865989290835, 127.74130606935618),
    true,
    [LatLng(37.86865989290835, 127.74130606935618)],
    Map<String, DateTime>.from({
      "0": DateTime.now(),
      "1": DateTime.now().add(Duration(hours: 1)),
      "2": DateTime.now().add(Duration(hours: 2)),
      "3": DateTime.now().add(Duration(hours: 3)),
    }),
  );
}
