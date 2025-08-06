import 'package:flutter/material.dart';
import 'package:onboard_screen_alarm_app/features/alarms/alarmHome.dart';
import 'package:onboard_screen_alarm_app/features/location/LocationScreen.dart';
import 'package:onboard_screen_alarm_app/features/onboarding/Onboarding_Screen.dart';

Map<String, WidgetBuilder> applicationRoutes() {
  return <String, WidgetBuilder>{
    '/location': (BuildContext context) => LocationScreen(),
    '/onboarding': (BuildContext context) => OnboardingScreen(),
    '/home': (BuildContext context) => alarmHome(),
  };
}
