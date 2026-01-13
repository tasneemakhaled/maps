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
    if (itemCount == 0) return const SizedBox.shrink(); // لو مفيش هيستوري ولا نتائج ميبينش حاجة بيضاء

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // شكل أنظف
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context,index){
          return ListTile(
            onTap: () async { // أضفت التفاعل عند الضغط على الصف نفسه
               var placeDetails= await PlacesDetailsService().getPlaceDetails(
                places[index].lat!,places[index].lon!);
               onPlaceSelected(placeDetails!);
            },
            trailing: IconButton(onPressed: ()async{
   var placeDetails= await PlacesDetailsService().getPlaceDetails(
    places[index].lat!,places[index].lon!);
   onPlaceSelected(placeDetails!);
   },
             icon: Icon(CupertinoIcons.arrow_up_right,size: 20,color: Colors.grey,)),
            leading: Icon(FontAwesomeIcons.locationDot,size: 20,color: Colors.blueAccent,),
            title: Text(places[index].displayName ?? 'No Name', maxLines: 1, overflow: TextOverflow.ellipsis),
          );
        }, separatorBuilder: (context,index){
        return const Divider(height: 0,);
      }, itemCount: itemCount),
    );
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// import 'package:maps/models/places_details_model/places_details_model.dart';
// import 'package:maps/utils/places_details_service.dart';

// class ListOfPredictions extends StatelessWidget {
//   const ListOfPredictions({
//     super.key, 
//     required this.itemCount, 
//     required this.places, 
//     required this.placesDetails, 
//     required this.onPlaceSelected
//   });

//   final int itemCount;
//   final List<PlacesAutocompleteModel> places;
//   final PlacesDetailsService placesDetails;
//   final Function(PlacesDetailsModel) onPlaceSelected;

//   @override
//   Widget build(BuildContext context) {
//     // إذا لم يكن هناك نتائج أو سجل، لا نعرض شيئاً
//     if (itemCount == 0) return const SizedBox.shrink();

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListView.separated(
//         padding: EdgeInsets.zero,
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(), // لمنع التعارض مع التمرير الأساسي
//         itemBuilder: (context, index) {
//           return ListTile(
//             // عند الضغط على الـ ListTile نفسه
//             onTap: () async {
//               var placeDetails = await PlacesDetailsService().getPlaceDetails(
//                   places[index].lat!, places[index].lon!);
//               if (placeDetails != null) {
//                 onPlaceSelected(placeDetails);
//               }
//             },
//             // زر السهم الذي طلبتيه (يعمل نفس الوظيفة)
//             trailing: IconButton(
//               onPressed: () async {
//                 var placeDetails = await PlacesDetailsService().getPlaceDetails(
//                     places[index].lat!, places[index].lon!);
//                 if (placeDetails != null) {
//                   onPlaceSelected(placeDetails);
//                 }
//               },
//               icon: const Icon(
//                 CupertinoIcons.arrow_up_right,
//                 size: 20,
//                 color: Colors.grey,
//               ),
//             ),
//             leading: const Icon(
//               FontAwesomeIcons.locationDot,
//               size: 20,
//               color: Colors.blueAccent,
//             ),
//             title: Text(
//               places[index].displayName ?? 'No Name',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(fontSize: 14),
//             ),
//           );
//         },
//         separatorBuilder: (context, index) {
//           return const Divider(height: 0);
//         },
//         itemCount: itemCount,
//       ),
//     );
//   }
// }


// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// // import 'package:maps/models/places_autocomplete_model/places_autocomplete_model.dart';
// // import 'package:maps/models/places_details_model/places_details_model.dart';
// // import 'package:maps/utils/places_details_service.dart';

// // class ListOfPredictions extends StatelessWidget {
// //   const ListOfPredictions({super.key, required this.itemCount, required this.places, required this.placesDetails, required this.onPlaceSelected});
// // final int itemCount;
// // final List<PlacesAutocompleteModel> places;
// // final PlacesDetailsService placesDetails;
// // final Function(PlacesDetailsModel) onPlaceSelected;
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       color: Colors.white,
// //       child: ListView.separated(
// //         shrinkWrap: true,
// //         itemBuilder: (context,index){
// //           return ListTile(
// //             trailing: IconButton(onPressed: ()async{
// //    var placeDetails= await PlacesDetailsService().getPlaceDetails(
// //     places[index].lat!,places[index].lon!);
// //    onPlaceSelected(placeDetails!);
// //    },
// //              icon: Icon(CupertinoIcons.arrow_up_right,size: 20,color: Colors.grey,)),
// //             leading: Icon(FontAwesomeIcons.locationDot,size: 20,color: Colors.blueAccent,),
// //             title: Text(places[index].displayName ?? 'No Name'),
// //           );
// //         }, separatorBuilder: (context,index){
// //         return const Divider(height: 0,);
// //       }, itemCount: itemCount),
// //     );
// //   }
// // }