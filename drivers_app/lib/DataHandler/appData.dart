import 'package:drivers_app/Models/history.dart';
import 'package:flutter/cupertino.dart';
import 'package:drivers_app/Models/address.dart';


class AppData extends ChangeNotifier
{
  //Address pickUpLocation , dropOffLocation;

  //void updatePickUpLocationAddress(Address pickUpAddress)
 // {
   // pickUpLocation = pickUpAddress;
    //notifyListeners();

  //}
  //void updateDropOffLocationAddress(Address dropOffAddres)
 // {
   // dropOffLocation = dropOffAddres;;
   // notifyListeners();
 // }

  String earnings = "0";
  int countTrips = 0;
  List<String> tripHistoryKeys = [];
  List<History> tripHistoryDataList = [];

  void updateEarnings(String updatedEarnings)
  {
    earnings = updatedEarnings;
    notifyListeners();
  }

  void updateTripsCounter(int tripCounter)
  {
    countTrips = tripCounter;
    notifyListeners();
  }

  void updateTripKeys(List<String> newkeys)
  {
    tripHistoryKeys = newkeys;
    notifyListeners();
  }

  void updateTripHistoryData(History eachHistory)
  {
    tripHistoryDataList.add(eachHistory);
    notifyListeners();
  }
}