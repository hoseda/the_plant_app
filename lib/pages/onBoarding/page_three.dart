import 'package:flutter/material.dart';
import 'package:the_plant_app/const/constants.dart';

Widget pageThree = Center(
  child: Padding(
    padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30.0),
          child: Image.asset('assets/images/plant-three.png', scale: 3.9412),
        ),
        const SizedBox(height: 21),
        Text(Constants.titleThree, style: Constants.titleStyle),
        const SizedBox(height: 11),
        Text(
          Constants.descriptionThree,
          style: Constants.descriptionStyle,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);
