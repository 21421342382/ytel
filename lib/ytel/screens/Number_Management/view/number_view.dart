import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ytel/ytel/helper/constants/colors.dart';
import 'package:ytel/ytel/screens/Number_Management/view/edit_number.dart';
import 'package:ytel/ytel/services/interceptors.dart';
import 'package:ytel/ytel/utils/storage_utils.dart';

import '../../../helper/constants/strings.dart';

class NumberScreen extends StatefulWidget {
  const NumberScreen({Key? key}) : super(key: key);

  @override
  State<NumberScreen> createState() => _NumberScreenState();
}

class _NumberScreenState extends State<NumberScreen> {
  // List<GetNumbersAPI>? apiList;

  var apiList;

  //Generate random number int

  bool search_pressed = false;
  List<String> number_list = [];
  List<String> number_list2 = [];
  String query = '';
  //Make a map of list of numbers
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getNumbersFromAPI();
  }

  @override
  Widget build(BuildContext context) {
    getNumbersFromAPI();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorHelper.primaryTextColor,
          title: Text('Numbers', style: TextStyle(color: Colors.white)),
          //Search icon in the end of appbar
          actions: [
            IconButton(
              onPressed: () async {},
              icon: Icon(Icons.download),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  search_pressed = !search_pressed;
                });
              },
              icon: Icon(Icons.search),
            ),
            //Download icon
          ],
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back),
          ),
        
        ),
        body: apiList==null? Center(child: CircularProgressIndicator()): _body());
  }

  Widget __numBody() {
    return TabBarView(
      children: [
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              // if (apiList != null) getNumbers(),
              //Show Loading icon and text "Loading.."while fetching data
              if (apiList == null)
                Center(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text('Loading..'),
                      ],
                    ),
                  ),
                ),

              //Table heading
              if (apiList != null)
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Number",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text("Actions   ",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              
            ],
          ),
        ),
        Center(
          child: Column(
            children: [
              //title of the table: "Phone Numbers", "Status", "Action"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'AgentId',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Action',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              
            ],
          ),
        ),
      ],
    );
  }

  // Widget to get Numbers from API
  Widget getNumbers() {
    return Expanded(
      child: ListView.builder(
          itemCount: number_list.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            // mapTheNumber();
            return Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(number_list[index],
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                            )),

                        //Arrao icon to show the status of the number
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // NumberDetalis(apiList: apiList, index: index);

                                // print(index);
                              },
                              icon: Icon(Icons.edit,
                                  color: Colors.grey, size: 20),
                            ),
                            IconButton(
                              onPressed: () {
                                // NumberDetalis(apiList: apiList, index: index);

                                // Get.to(NumberDetalis(
                                //   phoneNo: number_list[index],
                                // ));

                                // print(index);
                              },
                              icon: Icon(Icons.info,
                                  color: Colors.grey, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget getNumShortCode() {
    /* Display "AgentId", Status(Cupertino Switch) and "action" which has 3 functinalities "copy"," edit" and "Delete" from API*/
    // try and catch loading

    return Expanded(
      child: ListView.builder(
          itemCount:
              apiList['payload'].length == null ? 0 : apiList['payload'].length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              shadowColor: Colors.white,
              child: ListTile(
                leading: //text from Payload list

                    Text(apiList['payload'][index]['phoneNumber']),
                subtitle: Switch(
                  value: true,
                  onChanged: (value) {
                    print(value);
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 15,
                      onPressed: () {},
                      icon: Icon(Icons.copy),
                    ),
                    IconButton(
                      iconSize: 15,
                      onPressed: () {},
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      iconSize: 15,
                      onPressed: () {},
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  //API Call to get Numbers
  Future<void> getNumbersFromAPI() async {
    String url = 'https://api.ytel.com/api/v4/number/?offset=0';
    String accessToken = StorageUtil.getString(StringHelper.ACCESS_TOKEN);

    try {
      print("Inside Try");
      var result = await http.get(
          Uri.parse(
            url,
          ),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken',
          });

      if (result.statusCode == 200) {
        print("OK");
        /* 
      Example Response
{
  "status": true,
  "count": 576,
  "page": 1,
  "payload": [
    {
      "accountSid": "173c6f7f-c911-f823-fb2d-a13e4780c300",
      "phoneSid": "25431e50-6866-11ea-9ea9-d1464f98b813",
      "phoneNumber": "+15552283797",
      "voiceUrl": "https://testdomain.com",
      "voiceMethod": "GET",
      "voiceFallbackUrl": "",
      "voiceFallbackMethod": "POST",
      "renewalDate": 1611101028432,
      "purchaseDate": 1584459850921,
      "region": "US-NJ",
      "timezone": -20,
      "smsUrl": "",
      "smsMethod": "POST",
      "smsFallbackUrl": "",
      "smsFallbackMethod": "POST",
      "heartbeatUrl": "",
      "heartbeatMethod": "POST",
      "hangupCallbackUrl": "",
      "hangupCallbackMethod": "POST",
      "attributes": [
        "voice-enabled"
      ],
      "numberType": 1
    },
    {
      "accountSid": "173c6f7f-c911-f823-fb2d-a13e4780c300",
      "phoneSid": "8567a510-6886-11ea-9b6f-e6478104197e",
      "phoneNumber": "+15552283811",
      "voiceUrl": "https://testdomain.com",
      "voiceMethod": "GET",
      "voiceFallbackUrl": "",
      "voiceFallbackMethod": "POST",
      "renewalDate": 1611360251655,
      "purchaseDate": 1584473756124,
      "region": "US-NJ",
      "timezone": -20,
      "smsUrl": "",
      "smsMethod": "POST",
      "smsFallbackUrl": "",
      "smsFallbackMethod": "POST",
      "heartbeatUrl": "",
      "heartbeatMethod": "POST",
      "hangupCallbackUrl": "",
      "hangupCallbackMethod": "POST",
      "attributes": [
        "voice-enabled"
      ],
      "numberType": 1
    }
  ]
}
      */
        var data = json.decode(result.body);

        // print(data);

        if (data['status'] == false) {
          // print(data);

          /*{status: false, count: 0, page: 0, error: [{code: 401, message: Permission denied, moreInfo: null}]} */

          //Display Dialog Box of error message with "Logout" button

          //go to catch throw error
          throw Exception(data['error'][0]['message']);
        }

        setState(() {
          apiList = data;

          for (Map i in apiList['payload']) {
            number_list2.add(i['phoneNumber']);
          }
          number_list = number_list2;
        });
      }
    } catch (e) {
      print("Inside Catch");
      //Display Dialog Box of error message with "Logout" button
      logger.e(e);
    }
  }

  Widget _body() => ListView.builder(
        itemCount: number_list.length,
        itemBuilder: (context, index) => ExpansionTile(
          
          tilePadding: const EdgeInsets.only(left: 15, right: 0),
          title: Text(apiList['payload'][index]['phoneNumber']),
          children: [
            // Name
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children:  [
                  Text(
                    "Phone Sid: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['phoneSid']==null?"":apiList['payload'][index]['phoneSid'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // First Name
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children:  [
                  Text(
                    "voiceUrl: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      apiList['payload'][index]['voiceUrl']==null?"null":apiList['payload'][index]['voiceUrl'],
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Created Date
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  const Text(
                    "voiceMethod: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['voiceMethod']==null?"null":apiList['payload'][index]['voiceMethod'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  const Text(
                    "renewalDate ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['renewalDate']==null?"null":apiList['payload'][index]['renewalDate'].toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  const Text(
                    "purchaseDate ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['purchaseDate']==null?"null":apiList['payload'][index]['purchaseDate'].toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  const Text(
                    "heartbeatMethod: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['heartbeatMethod']==null?"null":apiList['payload'][index]['heartbeatMethod'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  const Text(
                    "smsMethod: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['smsMethod']==null?"null":apiList['payload'][index]['smsMethod'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                children: [
                  const Text(
                    "hangupCallbackMethod: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    apiList['payload'][index]['hangupCallbackMethod']==null?"null":apiList['payload'][index]['hangupCallbackMethod'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            //Edit button to edit number
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Display a button with a icon

                  CupertinoButton(
                    child: Row(
                      children: const [
                        Icon(
                          Icons.edit,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Edit",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      print("Edit button pressed");
                      Get.to(EditPhoneNumber(phoneId: apiList['payload'][index]['phoneNumber'],));
                      
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      );
}
