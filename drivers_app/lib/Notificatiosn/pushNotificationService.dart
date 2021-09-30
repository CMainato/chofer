
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:drivers_app/Models/rideDetails.dart';
import 'package:drivers_app/Notificatiosn/notificationDialog.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:io'show Platform;

import 'package:google_maps_flutter/google_maps_flutter.dart';
class PushNotificationService
{
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future initialize(context) async {

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async{
        retrieveRideRequestInfo(getRideRequestId(message),context);
      },
      onLaunch: (Map<String, dynamic> message) async{
        retrieveRideRequestInfo(getRideRequestId(message),context);
      },
      onResume: (Map<String, dynamic> message) async{
        retrieveRideRequestInfo(getRideRequestId(message),context);
      },
    );
  }

  Future<String> getToken() async {
    String token = await firebaseMessaging.getToken();
    print("este es tu token");
    print(token);
    driversRef.child(currentfirebaseUser.uid).child("token").set(token);
    firebaseMessaging.subscribeToTopic("alldrivers");
    firebaseMessaging.subscribeToTopic("allusers");
  }

  String getRideRequestId(Map<String, dynamic> message) {
    String rideRequesId="";
    if (Platform.isAndroid) {
      rideRequesId = message['data']["ride_request_id"];

    } else {
      rideRequesId = message ["request_id"];

    }
    return rideRequesId;
  }

  void retrieveRideRequestInfo(String rideRequestId, BuildContext context)
  {
    newRequestsRef.child(rideRequestId).once().then((DataSnapshot dataSnapShot)
    {
      if(dataSnapShot.value != null)
      {

        assetsAudioPlayer.open(Audio("sounds/alert.mp3"));
        assetsAudioPlayer.play();

        double pickUpLocationLat = double.parse(dataSnapShot.value['pickup']['latitude'].toString());
        double pickUpLocationLng = double.parse(dataSnapShot.value['pickup']['longitude'].toString());
        String pickUpAddress = dataSnapShot.value['pickup_addres'].toString();

        double dropOffLocationLat = double.parse(dataSnapShot.value['dropoff']['latitude'].toString());
        double dropOffLocationLng = double.parse(dataSnapShot.value['dropoff']['longitude'].toString());
        String dropOffAddress = dataSnapShot.value['dropoff_addres'].toString();


        String paymentMethod = dataSnapShot.value['payment_method'].toString();

        String rider_name = dataSnapShot.value["rider_name"];
        String rider_phone = dataSnapShot.value["rider_phone"];

        RideDetails rideDetails = RideDetails();
        rideDetails.ride_request_id = rideRequestId;
        rideDetails.pickup_addres = pickUpAddress;
        rideDetails.dropoff_addres = dropOffAddress;
        rideDetails.pickup = LatLng(pickUpLocationLat, pickUpLocationLng);
        rideDetails.dropoff = LatLng(dropOffLocationLat, dropOffLocationLng);
        rideDetails.payment_method = paymentMethod;
        rideDetails.rider_name = rider_name;
        rideDetails.rider_phone = rider_phone;

        print('Information::');
        print(rideDetails.pickup_addres);
        print(rideDetails.dropoff_addres);

        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>NotificationDialog(rideDetails: rideDetails,),


        );
      }
    });
  }

}