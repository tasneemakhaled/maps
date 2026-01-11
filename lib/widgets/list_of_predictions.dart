import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
import 'package:maps/models/places_details_model/places_details_model.dart';
import 'package:maps/utils/places_details_service.dart';

class ListOfPredictions extends StatelessWidget {
  const ListOfPredictions({super.key, required this.itemCount, required this.places, required this.placesDetails, required this.onPlaceSelected});
final int itemCount;
final List<PlacesAutocompleteModel> places;
final PlacesDetailsService placesDetails;
final Function(PlacesDetailsModel) onPlaceSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context,index){
          return ListTile(
            trailing: IconButton(onPressed: ()async{
   var placeDetails= await PlacesDetailsService().getPlaceDetails(
    places[index].lat!,places[index].lon!);
   onPlaceSelected(placeDetails!);
   },
             icon: Icon(CupertinoIcons.arrow_up_right,size: 20,color: Colors.grey,)),
            leading: Icon(FontAwesomeIcons.locationDot,size: 20,color: Colors.blueAccent,),
            title: Text(places[index].displayName ?? 'No Name'),
          );
        }, separatorBuilder: (context,index){
        return const Divider(height: 0,);
      }, itemCount: itemCount),
    );
  }
}