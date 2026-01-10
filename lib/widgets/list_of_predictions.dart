import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';

class ListOfPredictions extends StatelessWidget {
  const ListOfPredictions({super.key, required this.itemCount, required this.places});
final int itemCount;
final List<PlacesAutocompleteModel> places;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context,index){
          return ListTile(
            trailing: IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.arrow_up_right,size: 20,color: Colors.grey,)),
            leading: Icon(FontAwesomeIcons.locationDot,size: 20,color: Colors.blueAccent,),
            title: Text(places[index].displayName ?? 'No Name'),
          );
        }, separatorBuilder: (context,index){
        return const Divider(height: 0,);
      }, itemCount: itemCount),
    );
  }
}