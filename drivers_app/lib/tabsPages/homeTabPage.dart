import 'dart:async';

import 'package:drivers_app/AllScreeens/registrationScreen.dart';
import 'package:drivers_app/Assistants/assistantMethods.dart';
import 'package:drivers_app/Models/drivers.dart';
import 'package:drivers_app/Notificatiosn/pushNotificationService.dart';
import 'package:drivers_app/configMaps.dart';
import 'package:drivers_app/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {


  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabPageState createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

   var geoLocator = Geolocator();

   String driverStatusText = " Desconectado - Conectarse Ahora";

   Color driverStatusColor = Colors.black;

   bool isDriverAvailable = false;


   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurretDriverInfo();
  }
  
  getRideType()
  {
    driversRef.child(currentfirebaseUser.uid).child("car_details").child("type").once().then((DataSnapshot snapshot)
    {
      if(snapshot.value != null )
      {
        setState(() {
          rideType = snapshot.value.toString();
        });

      }
    });
  }
  
  
getRatings(){
  //update ratings
  driversRef.child(currentfirebaseUser.uid).child("ratings").once().then((DataSnapshot dataSnapshot)
  {
    if(dataSnapshot.value != null)
    {
      double ratings = double.parse(dataSnapshot.value.toString());
      setState(() {
        starCounter = ratings;
      });

      if(starCounter <= 1.5)
      {
        setState(() {
          title = "Muy Malo";
        });
        return;
      }
      if(starCounter <= 2.5)
      {
        setState(() {
          title = "Malo";
        });

        return;
      }
      if(starCounter <= 3.5)
      {
        setState(() {
          title = "Bueno";
        });

        return;
      }
      if(starCounter <= 4.5)
      {
        setState(() {
          title = "Muy Bueno";
        });
        return;
      }
      if(starCounter <= 5.0)
      {
        setState(() {
          title = "Excelente";
        });

        return;
      }
    }
  });
}

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    //String address = await AssistantMethods.searchCoordinateAddress(position, context);
    //print("Esta es tú dirección ::" + address);

  }


  void getCurretDriverInfo()async{
    currentfirebaseUser = await FirebaseAuth.instance.currentUser;

    driversRef.child(currentfirebaseUser.uid).once().then((DataSnapshot dataSnapshot){
      if(dataSnapshot.value != null)
      {
        driversInformation = Drivers.fromSnapshot(dataSnapshot);
      }
    });
    PushNotificationService pushNotificationService = PushNotificationService();

    pushNotificationService.initialize(context);
    pushNotificationService.getToken();

    AssistantMethods.retrieveHistoryInfo(context);
    getRatings();
    getRideType();


  }
  @override
  Widget build(BuildContext context)
  {
    return Stack(
       children: [
         GoogleMap(

         mapType: MapType.normal,
         myLocationButtonEnabled: true,
         initialCameraPosition: HomeTabPage._kGooglePlex,
         myLocationEnabled: true,
         onMapCreated: (GoogleMapController controller)
         {
           _controllerGoogleMap.complete(controller);
           newGoogleMapController = controller;
            locatePosition();

         },
       ),

         //contenedor de l usaio en lineo o no
         Expanded(
           flex: 3,
           child: Container(
             height: 140.0,
             width: double.infinity,
             color: Colors.black54,

           ),
         ),
         Positioned(
           top: 60.0,
           left: 0.0 ,
           right: 0.0,
           child: Row(
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: RaisedButton(
                    onPressed: ()
                    {


                      if(isDriverAvailable !=true){
                        makeDriverOnlineNow();
                        getLocationLiveUpdates();

                        setState(() {
                          driverStatusColor = Colors.green;
                          driverStatusText = "Conectado";
                          isDriverAvailable = true;
                        });
                          displayToastMessage("Estas en linea ", context);

                      }else{
                        makeDriverOffLine();
                        setState(() {
                          driverStatusColor = Colors.indigo;
                          driverStatusText = "Desconectado - Conectarse Ahora";
                          isDriverAvailable = false;
                        });


                        displayToastMessage("Estas desconectado", context);
                      }
                    },
                    color: driverStatusColor,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text( driverStatusText, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white ),),
                          Icon(Icons.phone_android, color: Colors.white, size: 26.0,),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
           ),
         ),


       ],
    );
  }

  void makeDriverOnlineNow() async{
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser.uid,currentPosition.latitude,currentPosition.longitude);
    rideRequestRef.set("searching");
    rideRequestRef.onValue.listen((event) {

    });
  }

  void getLocationLiveUpdates()
  {

    homeTabPageStreamSubcriptor = Geolocator.getPositionStream().listen((Position position) {
    currentPosition = position;
    if(isDriverAvailable == true){
      Geofire.setLocation(currentfirebaseUser.uid, position.latitude, position.longitude);
    }
    LatLng latLng = LatLng(position.latitude, position.longitude);
    newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }
  void makeDriverOffLine(){
    Geofire.removeLocation(currentfirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
    rideRequestRef = null;

  }
}