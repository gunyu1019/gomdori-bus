import 'package:flutter/material.dart';
import 'package:gomdori_bus/core/constant/text_style.dart';
import 'package:gomdori_bus/domain/entity/bus_state.dart';
import 'package:gomdori_bus/domain/entity/station.dart';
import 'package:gomdori_bus/presentation/widget/bus_info.dart';
import 'package:gomdori_bus/presentation/widget/station_detail_title.dart';

class StationDetailItem extends StatelessWidget {
  const StationDetailItem({
    super.key,
    required this.size,
    required this.station,
    this.simple = true,
    this.previousName,
    this.nextName,
    this.onPreviousClick,
    this.onCurrentClick,
    this.onNextClick,
    this.currentStation,
  });

  /// 하나의 페이지를 구성하는 크기입니다.
  final Size size;

  /// 정류장 정보를 담고 있는 객체입니다.
  final Station station;

  final bool simple;

  /// 이전 정류장 이름입니다.
  final String? previousName;

  /// 다음 정류장 이름입니다.
  final String? nextName;

  /// 현재 버스의 위치를 나타냅니다.
  final String? currentStation;
  
  final void Function()? onPreviousClick;
  final void Function()? onCurrentClick;
  final void Function()? onNextClick;

  Widget timetable() {
    final children = <Widget>[
      Text(
        '시간표',
        style: StationDetailTextStyle.title,
        textAlign: TextAlign.start,
      ),
      SizedBox(height: 8)
    ];
    final now = DateTime.now();
    final currentInfo = station.nearTimetable(now);

    station.time.entries
        .map(
          (timetable) => BusInfo(
            dateTime: timetable.value,
            isLast: timetable.key == station.time.keys.last,
            busState:
                currentInfo?.key == timetable.key
                    ? BusState.current
                    : (timetable.value.isBefore(now) || currentInfo == null
                        ? BusState.previous
                        : BusState.next),
            simple: simple,
            index: int.parse(timetable.key),
          ),
        )
        .forEach(children.add);
    if (currentInfo == null) {
      // 운행이 종료된 경우 (출발 전 배차는 05:00 이후로 간주함.)
      children.add(
        BusInfo(
          index: -1,
          dateTime: now,
          busState: BusState.closed,
          simple: simple,
          descriptionFomrat: "운행이 종료되었습니다.",
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            StationDetailTitle(
              station: station,
              previousName: previousName,
              nextName: nextName,
              size: size,
              onPreviousClick: onPreviousClick,
              onCurrentClick: onCurrentClick,
              onNextClick: onNextClick,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(children: [timetable()]),
            ),
          ],
        ),
      ),
    );
  }
}
