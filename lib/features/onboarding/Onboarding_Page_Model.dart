import 'package:onboard_screen_alarm_app/constants/DirStrings.dart';

class OnbordingContent {
  String? image;
  String? title;
  String? discription;

  OnbordingContent({this.image, this.title, this.discription});
}

List<OnbordingContent> contents = [
  OnbordingContent(
    image: DirStrings.onBoarding_img_1,
    title: 'Sync with Nature’s Rhythm',
    discription:
        "Experience a peaceful transition into the evening with an alarm that aligns with the sunset. Your perfect reminder, always 15 minutes before sundown",
  ),
  OnbordingContent(
    image: DirStrings.onBoarding_img_2,
    title: 'Effortless & Automatic',
    discription:
        "No need to set alarms manually. Wakey calculates the sunset time for your location and alerts you on time.",
  ),
  OnbordingContent(
    image: DirStrings.onBoarding_img_3,
    title: 'Relax & Unwind',
    discription: "hope to take the courage to pursue your dreams.",
  ),
];
