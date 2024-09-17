import 'package:edm_teachers_app/COMPONENTS/accordion_view.dart';
import 'package:edm_teachers_app/COMPONENTS/border_view.dart';
import 'package:edm_teachers_app/COMPONENTS/button_view.dart';
import 'package:edm_teachers_app/COMPONENTS/main_view.dart';
import 'package:edm_teachers_app/COMPONENTS/padding_view.dart';
import 'package:edm_teachers_app/COMPONENTS/text_view.dart';
import 'package:edm_teachers_app/FUNCTIONS/array.dart';
import 'package:edm_teachers_app/FUNCTIONS/colors.dart';
import 'package:edm_teachers_app/FUNCTIONS/nav.dart';
import 'package:edm_teachers_app/FUNCTIONS/recorder.dart';
import 'package:edm_teachers_app/MODELS/DATAMASTER/datamaster.dart';
import 'package:edm_teachers_app/MODELS/constants.dart';
import 'package:edm_teachers_app/MODELS/firebase.dart';
import 'package:edm_teachers_app/VIEWS/Navigation.dart';
import 'package:flutter/material.dart';

class Tracks extends StatefulWidget {
  final DataMaster dm;
  const Tracks({super.key, required this.dm});

  @override
  State<Tracks> createState() => _TracksState();
}

class _TracksState extends State<Tracks> {
  List<Map<String, dynamic>> _trackObjs = [];
  Sound _mediaPlayer = Sound();
  bool _isPlaying = false;

  void _fetchTracks() async {
    setState(() {
      widget.dm.setToggleLoading(true);
    });
    final tracks = await firebase_GetAllDocuments('${appName}_Tracks');
    final tempTracks = [];
    for (var track in tracks) {
      final audio = await storage_DownloadMedia(track['audioPath']);
      final obj = {...track, 'audioUrl': audio};
      tempTracks.add(obj);
    }
    setState(() {
      widget.dm.setToggleLoading(false);
      _trackObjs = tempTracks.cast<Map<String, dynamic>>();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTracks();
  }

  @override
  Widget build(BuildContext context) {
    return MainView(
      dm: widget.dm,
      children: [
        // TOP
        PaddingView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextView(
                text: 'Tracks',
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_trackObjs.isNotEmpty)
                  ...removeDupes(
                          _trackObjs.map((ting) => ting['category']).toList())
                      .map(
                    (categ) {
                      return BorderView(
                        bottom: true,
                        bottomColor: Colors.black26,
                        child: AccordionView(
                          topWidget: PaddingView(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.video_library,
                                  size: 32,
                                  color: hexToColor("#3490F3"),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                TextView(
                                  text: categ,
                                  size: 22,
                                  weight: FontWeight.w600,
                                )
                              ],
                            ),
                          ),
                          bottomWidget: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sortArrayByProperty(
                                      _trackObjs
                                          .where((ting) =>
                                              ting['category'] == categ)
                                          .toList(),
                                      'order')
                                  .map((track) {
                                return PaddingView(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextView(
                                        text: track['title'],
                                        size: 18,
                                        wrap: true,
                                      ),
                                      Row(
                                        children: [
                                          if (_mediaPlayer.audioPath !=
                                              track['audioUrl'])
                                            ButtonView(
                                              child: Icon(
                                                Icons.play_arrow_rounded,
                                                size: 32,
                                                color: hexToColor("#1985C6"),
                                              ),
                                              onPress: () async {
                                                await _mediaPlayer
                                                    .stopPlaying();
                                                setState(() {
                                                  _isPlaying = true;
                                                  _mediaPlayer.audioPath =
                                                      track['audioUrl'];
                                                });
                                                await _mediaPlayer
                                                    .playRecording();
                                              },
                                            ),
                                          if (_isPlaying &&
                                              _mediaPlayer.audioPath ==
                                                  track['audioUrl'])
                                            ButtonView(
                                              child: Icon(
                                                Icons.stop_rounded,
                                                size: 32,
                                                color: hexToColor("#FF1F54"),
                                              ),
                                              onPress: () {
                                                setState(() {
                                                  _isPlaying = false;
                                                  _mediaPlayer.audioPath = "";
                                                });
                                                _mediaPlayer.stopPlaying();
                                              },
                                            )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
