import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetails
{
  String pickup_addres;
  String dropoff_addres;
  LatLng pickup;
  LatLng dropoff;
  String ride_request_id;
  String payment_method;
  String rider_name;
  String rider_phone;

  RideDetails({this.pickup_addres, this.dropoff_addres, this.pickup, this.dropoff, this.ride_request_id, this.payment_method, this.rider_name, this.rider_phone,});
}
