import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:school_driver/Homepages/Homepage.dart';
import 'package:school_driver/Homepages/Scanner/QR_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:school_driver/Utils/Appurls/appurl.dart';
import 'package:school_driver/Utils/Utils.dart';
import '../../Login and Signup/Profile.dart';
import '../../Widgets/buttons.dart';
import '../../Widgets/text_field.dart';
import '../../constents.dart';

class MyTrips extends StatefulWidget {
  const MyTrips({Key? key}) : super(key: key);

  @override
  State<MyTrips> createState() => _MyTripsState();
}

class _MyTripsState extends State<MyTrips> {
  final schoolName = TextEditingController();
  final schoolNameController =  TextEditingController();
  final stopNameController = TextEditingController();
  List<dynamic> tripEntrieses = [];
  List<TextEditingController>stopControllers = [];
  List<dynamic> drivertrips = [];

  String? stop_latitude;
  String? stop_longitude;

  ///api functions
  Future<void> addstop(List<dynamic> trips) async {
    print('add stop function called.....');
    print(trips);

    // Assuming the first stop is in the list of stops
    // Map<String, dynamic> firstStop = {
    //   "name": trips[0],
    //   "latitude": "454554",
    //   "longitude": "54545",
    // };

    // Map<String, dynamic> stopData = {
    //   "first": firstStop,
    //   "second_stop": trips.length > 1 ? trips[1] : null,
    //   "third_stop": trips.length > 2 ? trips[2] : null,
    // };

    Map<String, dynamic> data = {
      'driver_id': Utils.userLoggedId,
      'school_name': schoolNameController.text,
      'stop': stopControllers,
    };

    try {
      final response = await http.post(
        Uri.parse(AppUrl.addingNewStopsBydriver),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Adding stops successful');
        var responseData = jsonDecode(response.body);
        Utils.flushBarErrorMessage(responseData['message'], context, Colors.green);
      } else {
        print('Failed to add stops. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error during adding stops: $error');
    }
  }


  Future<void> getstops() async {
    Map<String, dynamic> data = {
      'driver_id': Utils.userLoggedId,
    };
    try {
      print('its tryed....');
      print('body is::${jsonEncode(data)}');
      final response = await http.post(
        Uri.parse(AppUrl.getNewStop),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );
      print('status code :${response.statusCode}');
      if (response.statusCode == 200) {
        print('gggggg');
        print('Response: ${response.body}');
        var responseData = jsonDecode(response.body);
        drivertrips.clear();
        drivertrips.addAll(responseData['data']);

        for (var trip in drivertrips) {
          var stopList = trip['stop'] as List<dynamic>;
          var formattedStops = stopList.map((stop) => stop['name']).toList();
          print('Trip ID: ${trip['id']}, School Name: ${trip['school_name']}, Stops: $formattedStops');
        }

        print('ssssssssss');
      } else {
        print('Failed to make POST request. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (error) {
      print('Error during POST request: $error');
    }
  }


  ///StartTrip
  Future<void> startTrip(String stopName, BuildContext context) async {
    // Your request payload
    Map<String, dynamic> requestBody = {
      "starting_stop": stopName,
      "status": "started",
      "driver_id": Utils.userLoggedId,
    };

    try {
      final response = await http.post(
        Uri.parse(AppUrl.master_Trip),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        Fluttertoast.showToast(msg: 'Your Trip Started!');
        Utils.flushBarErrorMessage(jsonResponse['message'], context, Colors.green);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scanpage()),
        );
        print('API call success: ${response.body}');
      } else {
        // Handle error response
        print('API call failed with status ${response.statusCode}');
        print('Response body: ${response.body}');

        // Optionally, handle different error scenarios based on status codes
        if (response.statusCode == 404) {
          // Handle 404 Not Found
        } else {
          // Handle other error scenarios
        }
      }
    } catch (error) {
      // Handle exceptions
      print('Error during API call: $error');

      // Optionally, show an error message to the user
      Utils.flushBarErrorMessage('An error occurred', context, Colors.red);
    }
  }

  //delete trip
  Future<void> deleteTrip(int tripID) async {
    print('delete trip called....');
    // Your request payload
    Map<String, dynamic> requestBody = {
      "driver_tripid":tripID
    };

    try {
      final response = await http.delete(
        Uri.parse(AppUrl.deleteTrip),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('delete api win....s');
        var jsonResponse = jsonDecode(response.body);
        Fluttertoast.showToast(msg: 'Trip Deleted!');
        Utils.flushBarErrorMessage(jsonResponse['message'], context, Colors.green);

        print('API call success: ${response.body}');
      } else {
        // Handle error response
        print('API call failed with status ${response.statusCode}');
        print('Response body: ${response.body}');

      }
    } catch (error) {
      // Handle exceptions
      print('Error during API call: $error');

      // Optionally, show an error message to the user
      Utils.flushBarErrorMessage('An error occurred', context, Colors.red);
    }
  }








  ///end of api functions
  @override
  void initState() {
    // TODO: implement initState
    getstops();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Icon(Icons.menu,color:textColor1),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(),));
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(Utils.photURL == null ? 'https://images.unsplash.com/photo-1480455624313-e'
                    '29b44bbfde1?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid='
                    'M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWFsZSUyMHByb2ZpbGV8ZW58MHx8MHx8fDA%3D': Utils.photURL.toString()),

              ),
            ),
          )
        ],
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(onPressed: (){
                  Navigator.pop(context);
                }, icon: Icon(Icons.arrow_back,color: Colors.black,),),
                Text( 'My Trips',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),),
              ],
            ),
            SizedBox(height: 20,),
            FutureBuilder(
              future:getstops() ,
              builder: (context,snapshot) {
                return SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: drivertrips.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration:BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 10.0,
                                spreadRadius: -15,
                                offset: Offset(
                                  -2,
                                  -2,
                                ),
                              )
                            ]
                        ),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ExpansionTile(
                                title: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.home),
                                        Text(
                                          '${drivertrips[index]['school_name']}',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: drivertrips[index].length,
                                    itemBuilder: (context, subIndex) {
                                      return ListTile(
                                        title: Column(
                                          children: [
                                            Text('${drivertrips[index]['stop'][subIndex]}'),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                              SizedBox(height: 20.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  SizedBox(
                                    width: 154,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: pinkColor),
                                      onPressed: () {
                                        deleteTrip(int.parse(drivertrips[index]['id']));
                                      },
                                      child: Text('Delete'),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                    width: 154,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: scanColor),
                                      onPressed: () {
                                        startTrip(drivertrips[index]['stop'][0].toString(), context);
                                      },
                                      child: Text('Start'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );

              }
            ),
            SizedBox(height: 20.0,),

            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text('Add New Trip',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 18 ),),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15,),
                            Padding(
                              padding: const EdgeInsets.only(left: 23.0),
                              child: Text('School Name'),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 296,
                                  height: 40,
                                  child: TextFormField(
                                    controller: schoolNameController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: fillColor,
                                      border: InputBorder.none, // Remove border
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 23.0),
                              child: Text('Stops'),
                            ),
                            for (int i = 0; i < stopControllers.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(left: 23.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        width: 323.0,
                                        height: 40.0,
                                        decoration: BoxDecoration(
                                          color: fillColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextFormField(
                                          style: TextStyle(
                                            color: scanColor,
                                          ),
                                          controller: stopControllers[i],
                                          onTap:() async {
                                            var place = await PlacesAutocomplete.show(
                                                logo: Text(''),
                                                context: context,
                                                apiKey: AppUrl.gKey,
                                                mode: Mode.overlay,
                                                types: [],
                                                strictbounds: false,
                                                components: [
                                                  Component(Component.country, 'ind'),
                                                ],

                                                //google_map_webservice package
                                                onError: (err){
                                                  print('error');
                                                }
                                            );

                                            if(place != null){
                                              setState(() {
                                                stopControllers[i].text = place.description.toString();
                                              });

                                              //form google_maps_webservice package
                                              final plist = GoogleMapsPlaces(apiKey:AppUrl.gKey,
                                                apiHeaders: await GoogleApiHeaders().getHeaders(),
                                                //from google_api_headers package
                                              );
                                              String placeid = place.placeId ?? "0";
                                              final detail = await plist.getDetailsByPlaceId(placeid);
                                              final geometry = detail.result.geometry!;
                                              stop_latitude = geometry.location.lat.toString();
                                              stop_longitude = geometry.location.lng.toString();
                                              // pickupLatitude = geometry.location.lat;
                                              // pickupLongitude = geometry.location.lng;
                                            }
                                          },
                                          decoration: InputDecoration(
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(6.0),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                          ),
                                          validator: (value) =>
                                          value!.isEmpty ? 'invalid data' : null,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          stopControllers.removeAt(i);
                                        });
                                      },
                                      icon: Icon(Icons.remove, color: Colors.red),
                                    )
                                  ],
                                ),
                              ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: 296,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: checkIncolor),
                            onPressed: () {
                              setState(() {
                                stopControllers.add(TextEditingController());
                                // addStop();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add),
                                Text('Add Stop'),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 15,)
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 15.0,right: 15.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: scanColor),
                    onPressed: (){
                  // startTrip();
                  setState(() {
                    print('pressed this...');

                    // Stop stop = Stop(
                    //   name: schoolNameController.text,
                    //   latitude: '',
                    //   longitude: ''
                    // );

                    List<String>stopNames = stopControllers.map((controller) => controller.text).toList();
                    print('stopNames are:${stopNames}');
                    tripEntrieses.addAll(stopNames);
                    // tripEntrieses.add(stopControllers.map((e) => e.text).toList());
                    // tripEntrieses.add(
                    //   TripEntry(schoolName: schoolNameController.text,
                    //         stopNames: stopControllers.map((controller) => controller.text).toList(),
                    //   ),
                    // );
                    print('tirpentrieees:${tripEntrieses}');
                    addstop(tripEntrieses);
                    stopControllers.clear();
                    schoolNameController.clear();
                  });
                  stopControllers.forEach((controller) => controller.clear());
                }, child: Text('Add Now')),
              ),
            )
          ],
        ),
      ),

    );
  }

}

class TripEntry {
  String schoolName;
  List<String> stopNames;

  TripEntry({required this.schoolName, required this.stopNames});

  Map<String,dynamic> toJson(){
    return{
      'schoolName':schoolName,
      'stopName':stopNames
    };
  }
}

class Stop{
  String name;
  String latitude;
  String longitude;

  Stop({required this.name,required this.latitude, required this.longitude});

  Map<String,dynamic> toJson(){
    return{
      'name':name,
      'latitude':latitude,
      'longitude':longitude
    };
  }
}
