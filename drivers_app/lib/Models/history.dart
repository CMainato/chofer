import 'package:firebase_database/firebase_database.dart';

class History
{
  String paymentMethod;
  String createdAt;
  String status;
  String fares;
  String dropOff;
  String pickUp;

  History({ this.paymentMethod, this.createdAt, this.status, this.fares, this.dropOff, this.pickUp});

  History.fromSnapshot(DataSnapshot snapshot)
  {
    paymentMethod = snapshot.value["payment_method"];
    createdAt = snapshot.value["created_at"];
    status = snapshot.value["status"];
    fares = snapshot.value["fares"];
    dropOff = snapshot.value["dropoff_addres"];
    pickUp = snapshot.value["pickup_addres"];
  }


























}