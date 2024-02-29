import 'dart:io';

// import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../Controller/account_controller.dart';
import '../Controller/transaction_controller.dart';

class Transection extends StatefulWidget {
  int ac_name;

  Transection(this.ac_name);

  @override
  State<Transection> createState() => _TransectionState();
}

class _TransectionState extends State<Transection> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  // TODO: replace this test ad unit with your own ad unit.
  final adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  /// Loads a banner ad.
  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          debugPrint('BannerAd failed to load: $err');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAd();
  }

  TextEditingController amount_controller = TextEditingController();

  TextEditingController reason_controller = TextEditingController();

  account_controller ac = Get.put(account_controller());

  transaction_controller tc = Get.put(transaction_controller());

  Widget build(BuildContext context) {
    tc.GetTransactionDatabase().then((value) {
      return tc.GetData(widget.ac_name).then((value) => tc.SelectQuary());
    });
    return Scaffold(
      appBar: AppBar(
          title: Text("${ac.DataList[widget.ac_name]['acname']}"),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return TransectionDialog();
                    },
                  );
                },
                icon: Icon(Icons.add_circle_outlined)),
            SizedBox(
              width: 10,
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            SizedBox(
              width: 10,
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
          ]),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  color: Colors.black12,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Date",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Particular",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Credit(₹)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Debit(₹)",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(child: Obx(() => ListTransection()))
              ],
            ),
          ),
          Card(
            child: Container(
              height: 80,
              child: Row(
                children: [
                  Expanded(
                      child: Container(
                    color: Colors.green.shade200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Credit(↑)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                            "₹ ${tc.amount[widget.ac_name]['credit']}",
                            style: TextStyle(fontWeight: FontWeight.bold)))
                      ],
                    ),
                  )),
                  Expanded(
                      child: Container(
                    color: Colors.redAccent.shade200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Debit(↓)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                            "₹ ${tc.amount[widget.ac_name]['debit']}",
                            style: TextStyle(fontWeight: FontWeight.bold)))
                      ],
                    ),
                  )),
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    color: Colors.black26,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Balance",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Obx(() => Text(
                              "₹ ${tc.amount[widget.ac_name]['balance']}",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          (_bannerAd != null)
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                      child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  )))
              : Text("")
        ],
      ),
    );
  }

  Widget ListTransection() {
    return ListView.builder(
      itemCount: tc.Data.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTapDown: (details) {
            showMenu(
                context: context,
                position: RelativeRect.fromLTRB(
                    0, details.globalPosition.dy, details.globalPosition.dx, 0),
                items: [
                  PopupMenuItem(
                      onTap: () {
                        tc.date_controller.text = tc.Data[index]['date'];
                        tc.istransactiontype.value =
                            tc.Data[index]['transaction_type'];
                        amount_controller.text = tc.Data[index]['amount'];
                        reason_controller.text = tc.Data[index]['reason'];
                        showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => EditTransectionDialog(index));
                      },
                      child: Text("Edit")),
                  PopupMenuItem(
                      onTap: () {
                        tc.DeleteData(index: tc.Data[index]['id'])
                            .then((value) => tc.GetData(widget.ac_name))
                            .then((value) =>
                                tc.Totalall(tc.amount[widget.ac_name]['id']))
                            .then((value) => tc.SelectQuary());
                      },
                      child: Text("Delete"))
                ]);
          },
          child: Container(
            padding: EdgeInsets.all(10),
            color: (index % 2 == 1) ? Colors.black12 : Colors.white,
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Obx(() => Text(
                          tc.Data[index]['date'],
                          style: TextStyle(
                              fontSize: 15,
                              color: (tc.Data[index]['transaction_type'] ==
                                      "Credit")
                                  ? Colors.green
                                  : Colors.red),
                        ))),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                    child: Obx(() => Text(
                          tc.Data[index]['reason'],
                          style: TextStyle(
                              fontSize: 15,
                              color: (tc.Data[index]['transaction_type'] ==
                                      "Credit")
                                  ? Colors.green
                                  : Colors.red),
                          softWrap: true,
                        ))),
                Spacer(),
                Expanded(
                    child: Obx(
                        () => (tc.Data[index]['transaction_type'] == "Credit")
                            ? Text(
                                tc.Data[index]['amount'],
                                style: TextStyle(
                                    fontSize: 15,
                                    color: (tc.Data[index]
                                                ['transaction_type'] ==
                                            "Credit")
                                        ? Colors.green
                                        : Colors.red),
                                softWrap: true,
                              )
                            : Text(
                                "0",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: (tc.Data[index]
                                                ['transaction_type'] ==
                                            "Credit")
                                        ? Colors.green
                                        : Colors.red),
                              ))),
                Spacer(),
                Expanded(
                    child: Obx(
                        () => (tc.Data[index]['transaction_type'] == "Debit")
                            ? Text(
                                tc.Data[index]['amount'],
                                style: TextStyle(
                                    fontSize: 15,
                                    color: (tc.Data[index]
                                                ['transaction_type'] ==
                                            "Credit")
                                        ? Colors.green
                                        : Colors.red),
                                softWrap: true,
                              )
                            : Text(
                                "0",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: (tc.Data[index]
                                                ['transaction_type'] ==
                                            "Credit")
                                        ? Colors.green
                                        : Colors.red),
                              ))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget TransectionDialog() {
    return AlertDialog(
      content: SizedBox(
        height: 350,
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 300,
                color: Colors.purple,
                child: Text(
                  "Add transaction",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
            TextField(
              controller: tc.date_controller,
              onTap: () {
                tc.PickDate();
              },
              keyboardType: TextInputType.none,
              decoration: InputDecoration(labelText: "Transaction Date"),
            ),
            Expanded(
              child: Row(
                children: [
                  Text("Transaction type: "),
                  Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                activeColor: Colors.purple,
                                value: "Credit",
                                groupValue: tc.istransactiontype.value,
                                onChanged: (value) {
                                  tc.Transaction_Type(value: value);
                                },
                              ),
                            ),
                            Text("Credit(+)"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                value: "Debit",
                                groupValue: tc.istransactiontype.value,
                                onChanged: (value) {
                                  tc.Transaction_Type(value: value);
                                },
                              ),
                            ),
                            Text("Debit(-)"),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
              controller: amount_controller,
            ),
            TextField(
              controller: reason_controller,
              decoration: InputDecoration(labelText: "Particular"),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
            style: ButtonStyle(
                side: MaterialStatePropertyAll(
                    BorderSide(width: 2, color: Colors.purple))),
            onPressed: () {
              tc.GetData(widget.ac_name);
              tc.date_controller.text = "";
              tc.istransactiontype.value = "";
              amount_controller.clear();
              reason_controller.clear();
              Navigator.pop(Get.context!);
            },
            child: Text("CANCEL")),
        ElevatedButton(
            onPressed: () {
              if (tc.date_controller != "" &&
                  tc.istransactiontype.value != "" &&
                  amount_controller.text != "") {
                tc.InsertData(
                    index: widget.ac_name,
                    date: tc.date_controller.text,
                    type: tc.istransactiontype,
                    amount: amount_controller.text,
                    reson: (reason_controller.text != "")
                        ? reason_controller.text
                        : "No reason");
                tc.GetData(widget.ac_name)
                    .then(
                        (value) => tc.Totalall(tc.amount[widget.ac_name]['id']))
                    .then((value) => tc.SelectQuary());
                tc.date_controller.text = "";
                tc.istransactiontype.value = "";
                amount_controller.clear();
                reason_controller.clear();
                Get.back();
              } else {
                Get.snackbar("Error", "Fill all required field",
                    colorText: Colors.white,
                    backgroundColor: Colors.purple,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(milliseconds: 1000),
                    margin: EdgeInsets.all(50));
              }
            },
            child: Text(
              "ADD",
              style: TextStyle(color: Colors.black),
            ))
      ],
    );
  }

  Widget EditTransectionDialog(int index) {
    return AlertDialog(
      content: SizedBox(
        height: 350,
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: 50,
                width: 300,
                color: Colors.purple,
                child: Text(
                  "Edit transaction",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
            TextField(
              controller: tc.date_controller,
              onTap: () {
                tc.PickDate();
              },
              keyboardType: TextInputType.none,
              decoration: InputDecoration(labelText: "Transaction Date"),
            ),
            Expanded(
              child: Row(
                children: [
                  Text("Transaction type: "),
                  Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                activeColor: Colors.purple,
                                value: "Credit",
                                groupValue: tc.istransactiontype.value,
                                onChanged: (value) {
                                  tc.Transaction_Type(value: value);
                                },
                              ),
                            ),
                            Text("Credit(+)"),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                value: "Debit",
                                groupValue: tc.istransactiontype.value,
                                onChanged: (value) {
                                  tc.Transaction_Type(value: value);
                                },
                              ),
                            ),
                            Text("Debit(-)"),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
              controller: amount_controller,
            ),
            TextField(
              controller: reason_controller,
              decoration: InputDecoration(labelText: "Particular"),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
            style: ButtonStyle(
                side: MaterialStatePropertyAll(
                    BorderSide(width: 2, color: Colors.purple))),
            onPressed: () {
              tc.GetData(widget.ac_name);
              tc.date_controller.text = "";
              tc.istransactiontype.value = "";
              amount_controller.clear();
              reason_controller.clear();
              Navigator.pop(Get.context!);
            },
            child: Text("CANCEL")),
        ElevatedButton(
            onPressed: () {
              if (tc.date_controller != "" &&
                  tc.istransactiontype.value != "" &&
                  amount_controller.text != "") {
                tc.EditData(
                    index: tc.Data[index]['id'],
                    date: tc.date_controller.text,
                    type: tc.istransactiontype,
                    amount: amount_controller.text,
                    reson: (reason_controller.text != "")
                        ? reason_controller.text
                        : "No reason");
                tc.GetData(widget.ac_name)
                    .then(
                        (value) => tc.Totalall(tc.amount[widget.ac_name]['id']))
                    .then((value) => tc.SelectQuary());
                tc.date_controller.text = "";
                tc.istransactiontype.value = "";
                amount_controller.clear();
                reason_controller.clear();
                Get.back();
              } else {
                Get.snackbar("Error", "Fill all required field",
                    colorText: Colors.white,
                    backgroundColor: Colors.purple,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(milliseconds: 1000),
                    margin: EdgeInsets.all(50));
              }
            },
            child: Text(
              "SAVE",
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }
}
