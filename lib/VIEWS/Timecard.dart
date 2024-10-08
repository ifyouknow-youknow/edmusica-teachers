import 'package:edm_teachers_app/COMPONENTS/border_view.dart';
import 'package:edm_teachers_app/COMPONENTS/button_view.dart';
import 'package:edm_teachers_app/COMPONENTS/calendar_view.dart';
import 'package:edm_teachers_app/COMPONENTS/future_view.dart';
import 'package:edm_teachers_app/COMPONENTS/main_view.dart';
import 'package:edm_teachers_app/COMPONENTS/map_view.dart';
import 'package:edm_teachers_app/COMPONENTS/padding_view.dart';
import 'package:edm_teachers_app/COMPONENTS/roundedcorners_view.dart';
import 'package:edm_teachers_app/COMPONENTS/text_view.dart';
import 'package:edm_teachers_app/FUNCTIONS/colors.dart';
import 'package:edm_teachers_app/FUNCTIONS/date.dart';
import 'package:edm_teachers_app/FUNCTIONS/nav.dart';
import 'package:edm_teachers_app/MODELS/DATAMASTER/datamaster.dart';
import 'package:edm_teachers_app/MODELS/constants.dart';
import 'package:edm_teachers_app/MODELS/firebase.dart';
import 'package:edm_teachers_app/MODELS/screen.dart';
import 'package:edm_teachers_app/VIEWS/Navigation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Timecard extends StatefulWidget {
  final DataMaster dm;
  const Timecard({super.key, required this.dm});

  @override
  State<Timecard> createState() => _TimecardState();
}

class _TimecardState extends State<Timecard> {
  //
  Future<List<dynamic>> _fetchPunches() async {
    final docs = await firebase_GetAllDocumentsOrderedQueriedLimited(
        '${appName}_Punches',
        [
          {'field': 'userId', 'operator': '==', 'value': widget.dm.user['id']}
        ],
        'date',
        'desc',
        120);
    return docs;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPunches();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(dm: widget.dm, children: [
      // TOP
      PaddingView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TextView(
              text: "Timecard",
              size: 20,
            ),
            ButtonView(
                child: const Icon(
                  Icons.menu,
                  size: 36,
                ),
                onPress: () {
                  nav_Push(context, Navigation(dm: widget.dm));
                })
          ],
        ),
      ),
      // MAIN
      Flexible(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureView(
                  future: _fetchPunches(),
                  childBuilder: (data) {
                    return Column(
                      children: [
                        for (var punch in data)
                          BorderView(
                            bottom: true,
                            bottomColor: Colors.black26,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: getWidth(context) * 0.3,
                                  child: MapView(
                                    locations: [
                                      LatLng(punch['location']['latitude'],
                                          punch['location']['longitude'])
                                    ],
                                    height: getWidth(context) * 0.3,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                PaddingView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextView(
                                        text: 'Clock ${punch['status']}',
                                        color: punch['status'] == "In"
                                            ? hexToColor("#3490F3")
                                            : hexToColor("#FF1F54"),
                                        size: 18,
                                        weight: FontWeight.w600,
                                      ),
                                      TextView(
                                        text: formatDate(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                punch['date'])),
                                      ),
                                      TextView(
                                        text: formatTime(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              punch['date']),
                                        ),
                                        size: 40,
                                        weight: FontWeight.w700,
                                        spacing: -2,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                      ],
                    );
                  },
                  emptyWidget: PaddingView(
                      child: Center(
                    child: TextView(
                      text: 'No punches yet.',
                      size: 20,
                    ),
                  ))),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 30,
      )
    ]);
  }
}
