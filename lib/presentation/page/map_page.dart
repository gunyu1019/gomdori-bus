import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:gomdori_bus/core/constant/color.dart';
import 'package:gomdori_bus/domain/entity/station.dart';
import 'package:gomdori_bus/presentation/widget/floating_button.dart';
import 'package:gomdori_bus/presentation/widget/station_summary_item.dart';
import 'package:gomdori_bus/presentation/widget/station_detail_item.dart';
import 'package:gomdori_bus/presentation/widget/station_pager.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<StatefulWidget> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late KakaoMapController? controller;

  final GlobalKey<StationPagerState> summaryPagerKey =
      GlobalKey<StationPagerState>();

  Offset _dragStartOffset = Offset.zero;
  String _currentStationName = "";
  late Poi _busPoi;
  Timer? _updateTimer;

  @override
  void dispose() {
    super.dispose();
    _updateTimer?.cancel();
  }

  Widget pagerItemBuilder(
    int index,
    Station station,
    Size overlaySize,
    bool isMobile,
  ) {
    // final nextStation = route!.station.elementAtOrNull(index + 1)?.name;
    // final previousStation =
    //     index > 0 ? route!.station.elementAtOrNull(index - 1)?.name : null;
    if (isMobile) {
      return StationSummaryItem(
        station: station,
        // nextStation: nextStation,
        currentStation: _currentStationName,
        onDirectionTap: summaryPagerKey.currentState?.directionTap
      );
    }
    return StationDetailItem(
      station: station,
      size: overlaySize,
      simple: false,
      // nextName: nextStation,
      // previousName: previousStation,
      currentStation: _currentStationName,
      onCurrentClick: () {
        controller?.moveCamera(
          CameraUpdate.newCenterPosition(station.position, zoomLevel: 14),
          animation: CameraAnimation(3000),
        );
      },
      onPreviousClick: () {
        summaryPagerKey.currentState?.scrollToPage(index - 1);
      },
      onNextClick: () {
        summaryPagerKey.currentState?.scrollToPage(index + 1);
      },
    );
  }

  void onVerticalDragStart(details) {
    _dragStartOffset = details.localPosition;
  }

  void onVerticalDragEnd(details) {
    final relativeOffset = (_dragStartOffset - details.localPosition);
    if (relativeOffset.dx.abs() > relativeOffset.dy.abs()) {
      // 수직으로 드래그가 이루어진 경우 무시합니다.
      return;
    }

    if (relativeOffset.dy > 100) {
      // TODO()
      // context.push("/detail");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    /// PC, Tablet과 Mobile Device에서 화면 구성은 상이합니다.
    final ratio = media.size.width / media.size.height;
    final isMobile = ratio < 1.0;

    double sideOverlayWidth = 500;
    if (!isMobile && media.size.width / 2 < 500) {
      sideOverlayWidth = max(300, media.size.width / 2);
    }

    final mapSize =
        isMobile
            ? Size(media.size.width, media.size.height - 300)
            : Size(media.size.width - sideOverlayWidth, media.size.height);
    final overlaySize =
        isMobile
            ? Size(media.size.width, 300)
            : Size(sideOverlayWidth, media.size.height);
    final overlayPositioned =
        isMobile
            ? (Widget child) =>
                Positioned(left: 0, right: 0, bottom: 0, child: child)
            : (Widget child) => Positioned(right: 0, top: 0, child: child);

    late Widget containerChild;
    // if (route == null) {
    //   containerChild = const SizedBox.shrink();
    // } else {
      containerChild = StationPager(
        key: summaryPagerKey,
        size: overlaySize,
        elements: [
          Station.mock(),
          Station.mock(),
          Station.mock(),
        ],
        onItemBuilder:
            (e1, e2) => pagerItemBuilder(e1, e2, overlaySize, isMobile),
        onVerticalDragStart: isMobile ? onVerticalDragStart : null,
        onVerticalDragEnd: isMobile ? onVerticalDragEnd : null,
      );
    // }

    final containerShadow = [
      BoxShadow(color: ThemeColor.grey, blurRadius: 4, offset: Offset(0, 4)),
    ];
    final containerDecoration = BoxDecoration(
      color: Colors.white,
      boxShadow: containerShadow,
    );

    final container = Container(
      decoration: containerDecoration,
      height: overlaySize.height,
      width: overlaySize.width,
      child: containerChild,
    );

    final option = KakaoMapOption(
      position: LatLng(37.868471010792305, 127.74478109028253),
    );
    
    final children = <Widget>[
        SizedBox(
          height: mapSize.height,
          width: mapSize.width,
          child: KakaoMap(option: option, onMapReady: onMapReady),
        ),
        overlayPositioned(container),
    ];
    if (isMobile) {
      children.add(
        Positioned(
          bottom: 320,
          right: 20,
          child: FloatingButton(
            icon: FaIcon(FontAwesomeIcons.mapLocationDot, color: Colors.white),
            onPressed: () {
              // TODO()
            },
          ),
        )
      );
    }
    return Stack(
      children: children,
    );
  }

  Future<void> onMapReady(KakaoMapController controller) async {
    this.controller = controller;

    /* await controller.moveCamera(CameraUpdate.fitMapPoints([
      LatLng(37.87369656276904, 127.74234032102943),
      LatLng(37.86069708242608, 127.74420063715208),
    ], padding: 10)); */
  }
}
