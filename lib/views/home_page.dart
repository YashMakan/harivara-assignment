import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:harivara/models/char_text_fields.dart';
import 'package:harivara/utils/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Database db = Database();
  CharTextFields charTextFields = CharTextFields(0, 0);
  TextEditingController leftValueController = TextEditingController();
  TextEditingController rightValueController = TextEditingController();
  bool threadBusyWithDB = false;

  setCharTextFields() async {
    if (threadBusyWithDB) {
      Timer.periodic(const Duration(milliseconds: 50), (timer) {
        if (!threadBusyWithDB) {
          setCharTextFields();
          timer.cancel();
        }
      });
    }
    if (!threadBusyWithDB) {
      threadBusyWithDB = true;
      String? referenceId = await db.addCharTextFields(CharTextFields(
          leftValueController.text.length, rightValueController.text.length,
          referenceId: charTextFields.referenceId));
      threadBusyWithDB = false;
      if (referenceId != null) {
        charTextFields = CharTextFields(
            leftValueController.text.length, rightValueController.text.length,
            referenceId: referenceId);
      }
    }
  }

  @override
  void initState() {
    db.pruneDB();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'TEST APP',
            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: Row(
              children: [
                Flexible(
                    child: Container(
                  height: double.maxFinite,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: TextField(
                    controller: leftValueController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700),
                    onChanged: (_) => setCharTextFields(),
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                )),
                Flexible(
                    child: Container(
                  height: double.maxFinite,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: TextField(
                    controller: rightValueController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700),
                    maxLines: 10,
                    onChanged: (_) => setCharTextFields(),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                )),
              ],
            )),
            Expanded(
              child: Container(
                  width: double.maxFinite,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: db.getStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      String leftResult =
                          leftValueController.text.length.toString();
                      String rightResult =
                          rightValueController.text.length.toString();
                      if (snapshot.data?.docs.isNotEmpty ?? false) {
                        leftResult = snapshot.data?.docs.first
                                .get(CharTextFields.leftValueKey)
                                .toString() ??
                            "0";
                        rightResult = snapshot.data?.docs.first
                                .get(CharTextFields.rightValueKey)
                                .toString() ??
                            "0";
                      }
                      double calculatedAngle = 0.01745 *
                          (int.parse(rightResult) - int.parse(leftResult));

                      if ((!calculatedAngle.isNegative &&
                              calculatedAngle >= 1.58) ||
                          (calculatedAngle.isNegative &&
                              calculatedAngle <= -1.58)) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          leftValueController.clear();
                          rightValueController.clear();
                          charTextFields = CharTextFields(0, 0);
                          db.pruneDB();
                        });
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: calculatedAngle,
                            child: Container(
                              height: 40,
                              width: size.width * 0.7,
                              color: Colors.blue,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    color: Colors.white,
                                    height: double.maxFinite,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    alignment: Alignment.center,
                                    child: Text(
                                      leftResult,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    height: double.maxFinite,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    alignment: Alignment.center,
                                    child: Text(
                                      rightResult,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          letterSpacing: 1.2,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  )),
            ),
          ],
        ));
  }
}
