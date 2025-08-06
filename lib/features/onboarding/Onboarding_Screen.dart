import 'dart:async';
import 'package:flutter/material.dart';
import 'package:onboard_screen_alarm_app/constants/colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'Onboarding_Page_Model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnbordingState createState() => _OnbordingState();
}

class _OnbordingState extends State<OnboardingScreen> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // save onboarding preference
  _storeOnboardInfo() async {
    int isViewed = 1;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('onBoard', isViewed);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: contents.length,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (_, i) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: Image.asset(
                            contents[i].image!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 0.54,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contents[i].title!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: 'Oxygen',
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                contents[i].discription!,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontFamily: 'Oxygen',
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Smooth Page Indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: SmoothPageIndicator(
                controller: _controller,
                count: contents.length,
                effect: WormEffect(
                  dotWidth: 12,
                  dotHeight: 12,
                  activeDotColor: Color(
                    colors.color_purple_deep_dot,
                  ), // Color of active dot
                  dotColor: Colors.grey, // Color of inactive dot
                  spacing: 10,
                ),
              ),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.all(40),
              width: double.infinity,
              child: TextButton(
                child: Text("Next", style: TextStyle(fontSize: 20)),
                onPressed: () {
                  if (currentIndex == contents.length - 1) {
                    _storeOnboardInfo();
                    Future.delayed(const Duration(milliseconds: 200)).then((
                      value,
                    ) {
                      Navigator.pushReplacementNamed(context, '/location');
                    });
                  }
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 1),
                    curve: Curves.easeInOut,
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(colors.color_purple_btn),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: () {
              _storeOnboardInfo();
              Navigator.pushReplacementNamed(context, '/location');
            },
            child: const Text(
              "Skip",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
