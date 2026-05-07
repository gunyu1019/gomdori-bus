import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gomdori_bus/core/constant/color.dart';
import 'package:gomdori_bus/core/constant/text_style.dart';
import 'package:gomdori_bus/domain/entity/bus_state.dart';
import 'package:gomdori_bus/domain/entity/station.dart';
import 'package:gomdori_bus/presentation/widget/bus_info.dart';


/// 정류장 요약 정보를 표시하는 위젯입니다.
/// 정류장 이름과 방향, 그리고 현재 시간에 따른 버스 예상 도착 정보를 표시합니다.
class StationSummaryItem extends StatelessWidget {
  const StationSummaryItem({
    super.key,
    required this.station,
    this.nextStation,
    this.onDirectionTap,
    this.currentStation,
  });

  /// 정류장 정보를 담고 있는 객체입니다.
  final Station station;

  /// 다음 정류장 이름입니다.
  /// 이 값이 null이면 종점으로 간주합니다.
  final String? nextStation;

  /// 방향을 눌렀을 때 호출되는 콜백 함수입니다.
  /// 이 콜백은 방향을 눌렀을 때, 다른 방향에 있는 정류장으로 이동할 때 사용됩니다.
  final void Function()? onDirectionTap;

  /// 현재 버스의 위치를 나타냅니다.
  final String? currentStation;

  /// 정류장 이름을 표시하는 위젯입니다.
  Widget titleText() => Text(station.name, style: KakaoMapTextStyle.title);

  /// 다음 정류장 방향을 표시하는 위젯입니다.
  Widget directionText() => InkWell(
    onTap: onDirectionTap,
    child: Row(children: [
      Text(
        nextStation == null ? "종점" : "$nextStation 방향",
        style: KakaoMapTextStyle.direction,
      ),
      const SizedBox(width: 4),
      FaIcon(
        FontAwesomeIcons.arrowRotateLeft,
        size: 14,
        color: ThemeColor.secondaryTextColor,
      ),
    ])
  );

  @override
  Widget build(BuildContext context) {
    final title = Padding(
      padding: EdgeInsets.only(left: 4, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 1.0,
        children: [titleText(), directionText()],
      ),
    );
    final now = DateTime.now();
    final currentInfo = station.nearTimetable(now);
    final children = <Widget>[title];

    if (currentInfo == null ||
        now.isBefore(DateTime(now.year, now.month, now.day, 5))) {
      // 운행이 종료된 경우 (출발 전 배차는 05:00 이후로 간주함.)
      station.time.entries
          .skip(station.time.length - 2)
          .map(
            (timetable) => BusInfo(
              busState: BusState.previous,
              dateTime: timetable.value,
              isLast: timetable.key == station.time.keys.last,
              index: int.parse(timetable.key),
            ),
          )
          .forEach(children.add);
      children.add(
        BusInfo(
          index: -1,
          dateTime: now,
          busState: BusState.closed,
          descriptionFomrat: "운행이 종료되었습니다.",
        ),
      );
    } else if (currentInfo.key == station.time.keys.first) {
      // 첫 차
      children.add(
        BusInfo(
          busState: BusState.current,
          dateTime: currentInfo.value,
          index: int.parse(currentInfo.key),
          currentStation: station.name,
          isLast: currentInfo.key == station.time.keys.last,
          descriptionFomrat: "{MM}분 후 {INDEX}회차 출발 예정",
        ),
      );
      station.time.entries
          .skip(1)
          .take(2)
          .map(
            (timetable) => BusInfo(
              busState: BusState.next,
              dateTime: timetable.value,
              isLast: timetable.key == station.time.keys.last,
              index: int.parse(timetable.key),
            ),
          )
          .forEach(children.add);
    } else {
      // final previousInfo =
      //     station.time.entries
      //         .takeWhile((timetable) => timetable.key != currentInfo.key)
      //         .last;
      // final nextInfo =
      //     station.time.entries
      //         .skipWhile((timetable) => timetable.key != currentInfo.key)
      //         .skip(1)
      //         .first;

      children.addAll([
        // BusInfo(
        //   busState: BusState.previous,
        //   dateTime: previousInfo.value,
        //   index: int.parse(previousInfo.key),
        // ),
        BusInfo(
          busState: BusState.current,
          dateTime: currentInfo.value,
          index: int.parse(currentInfo.key),
          currentStation: station.name,
        ),
        // BusInfo(
        //   busState: BusState.next,
        //   dateTime: nextInfo.value,
        //   index: int.parse(nextInfo.key),
        // ),
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2.0,
        children: children,
      ),
    );
  }
}
