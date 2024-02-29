import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../Controller/account_controller.dart';
import '../Controller/transaction_controller.dart';
import 'Transection.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  TextEditingController ac_nameController = TextEditingController();

  var controller = Get.put(account_controller());

  transaction_controller tc = Get.put(transaction_controller());

  Widget build(BuildContext context) {
    controller.GetDatabase()
        .then((value) => tc.GetTotaldb())
        .then((value) => controller.GetData())
        .then((value) => tc.SelectQuary());
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard"), actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(child: Text("save as PDF")),
            const PopupMenuItem(child: Text("save as Excel"))
          ],
        )
      ]),
      body: Obx(() {
        return ListOfAccount();
      }),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            AddAccountDialog();
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget ListOfAccount() {
    return ListView.builder(
      itemCount: controller.DataList.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Get.to(Transection(index));
          },
          child: Card(
            child: Container(
              margin: const EdgeInsets.all(10),
              height: 150,
              width: Get.width * 0.9,
              child: Column(children: [
                Row(
                  children: [
                    Text(
                      "${controller.DataList[index]['acname']}",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          ac_nameController.text =
                              controller.DataList[index]['acname'];
                          UpdateDialog(index);
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.purple,
                        )),
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                actions: [
                                  ElevatedButton(style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.redAccent)),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel",style: TextStyle(color: Colors.white),)),
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Colors.green)),
                                      onPressed: () {
                                        controller.DeleteData(
                                                index: controller.DataList[index]
                                                    ['id'])
                                            .then((value) => tc.DeleteTable(
                                                    index: index)
                                                .then((value) =>
                                                    controller.GetData().then(
                                                        (value) => tc.DeleteAmount(
                                                            tc.amount[index]
                                                                ['id']))))
                                            .then((value) => tc.SelectQuary());
                                        Navigator.pop(context);
                                      },
                                      child: Text("Ok",style: TextStyle(color: Colors.white),))
                                ],
                                title: Text(
                                    "Are you sure your recode is deleted.."),
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.purple,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green.shade200,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Credit(↑)",
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Obx(() => Text(
                                    "₹ ${tc.amount[index]['credit']}",
                                    style: const TextStyle(fontSize: 15),
                                  ))
                            ],
                          ),
                        ),
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.redAccent.shade200,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Debit(↓)",
                                style: TextStyle(fontSize: 18),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Obx(() => Text(
                                    "₹ ${tc.amount[index]['debit']}",
                                    style: const TextStyle(fontSize: 15),
                                  ))
                            ],
                          ),
                        ),
                      )),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              "Balance",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() => Text(
                                  "₹ ${tc.amount[index]['balance']}",
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ))
                          ],
                        ),
                      ))
                    ],
                  ),
                )
              ]),
            ),
          ),
        );
      },
    );
  }

  Future AddAccountDialog() {
    return Get.defaultDialog(
        barrierDismissible: false,
        title: "",
        titleStyle: const TextStyle(fontSize: 0),
        onConfirm: () {
          controller.Datainsert(name: ac_nameController.text).then((value) =>
              controller.GetData()
                  .then((value) => tc.GetTotaldb())
                  .then((value) => tc.InsertAmountData())
                  .then((value) => tc.SelectQuary()));
          ac_nameController.clear();
          Get.back();
        },
        textConfirm: "ADD",
        confirmTextColor: Colors.white,
        onCancel: () {
          ac_nameController.clear();
        },
        content: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 50,
              width: 300,
              color: Colors.purple,
              child: const Text("Add new account",
                  style: TextStyle(fontSize: 25, color: Colors.white)),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 280,
              child: TextField(
                controller: ac_nameController,
                decoration: const InputDecoration(
                  labelText: "Account name",
                ),
              ),
            ),
          ],
        ));
  }

  Future UpdateDialog(int index) {
    return Get.defaultDialog(
        barrierDismissible: false,
        title: "",
        titleStyle: const TextStyle(fontSize: 0),
        onConfirm: () {
          controller.UpdateData(
              updateName: '${ac_nameController.text}',
              index: controller.DataList[index]['id']);
          ac_nameController.clear();
          Get.back();
        },
        textConfirm: "SAVE",
        confirmTextColor: Colors.white,
        onCancel: () {
          ac_nameController.clear();
        },
        content: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 50,
              width: 300,
              color: Colors.purple,
              child: const Text("Update account",
                  style: TextStyle(fontSize: 25, color: Colors.white)),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 280,
              child: TextField(
                controller: ac_nameController,
                decoration: const InputDecoration(labelText: "Account name"),
              ),
            ),
          ],
        ));
  }
}
