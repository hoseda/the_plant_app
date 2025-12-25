import 'package:flutter/material.dart';
import 'package:the_plant_app/const/constants.dart';

Widget pageOne = Center(
  child: Padding(
    padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 15),
    child: Column(
      children: [
        Image.asset('assets/images/plant-one.png', scale: 2.69),
        const SizedBox(height: 21),
        Text(Constants.titleOne, style: Constants.titleStyle),
        const SizedBox(height: 11),
        Text(
          Constants.descriptionOne,
          style: Constants.descriptionStyle,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  ),
);
