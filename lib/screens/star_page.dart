import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StarPage extends StatefulWidget {
  final String uid;
  StarPage({required this.uid});

  @override
  _StarPageState createState() => _StarPageState();
}

class _StarPageState extends State<StarPage> {
  double? newTotalRatingCount;
  int? newCustomersReviewed;
  double? newAverageRating;
  String? restarauntName;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  @override
  void initState() {
    GetRestarauntName();

    super.initState();
  }

  GetRestarauntName() async {
    await firestoreInstance
        .collection("Restaraunts")
        .doc(widget.uid)
        .get()
        .then((value) {
      restarauntName = value.data()!["restarauntName"];
      setState(() {});
    });
  }

  updateDatatbase() async {
    //------------------->>>>>> GETTING FROM DATABSE

    await firestoreInstance
        .collection("Restaraunts")
        .doc(widget.uid)
        .get()
        .then((value) async {
      // ------------- TotalRatingCount ------------ //

      //--------- GET

      newTotalRatingCount = value.data()!["TotalRatingCount"] + _stars;
      Map<String, dynamic> updateTotalRatingCount = {
        "TotalRatingCount": newTotalRatingCount,
      };

      //--------- UPDATE

      firestoreInstance
          .collection("Restaraunts")
          .doc(widget.uid)
          .update(updateTotalRatingCount)
          .whenComplete(() => print("TotalRatingCount updated in the database"))
          .catchError((onError) => print(onError));

      // ------------- CustomersReviewed ------------ //

      //--------- GET

      newCustomersReviewed = value.data()!["CustomersReviewed"] + 1;
      Map<String, dynamic> updateCustomersReviewed = {
        "CustomersReviewed": newCustomersReviewed,
      };

      //--------- UPDATE
      firestoreInstance
          .collection("Restaraunts")
          .doc(widget.uid)
          .update(updateCustomersReviewed)
          .whenComplete(
              () => print("CustomersReviewed updated in the database"))
          .catchError((onError) => print(onError));

      // ------------- newAverageRating ------------ //

      //--------- GET

      newAverageRating =
          (newTotalRatingCount! / newCustomersReviewed!);
      Map<String, dynamic> updateAverageRating = {
        "AverageRating": newAverageRating!.toStringAsFixed(2),
      };

      //--------- UPDATE
      firestoreInstance
          .collection("Restaraunts")
          .doc(widget.uid)
          .update(updateAverageRating)
          .whenComplete(() => print("AverageRating updated in the database"))
          .catchError((onError) => print(onError));
    });
  }

  double _stars = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 5,
            ),
            const Image(
              image: AssetImage("assets/shopping-bag.png"),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Rate your meal'),
            const SizedBox(
              height: 30,
            ),
            Text('$restarauntName'),
            Divider(
              color: Color(0xfff0CF7BA),
              indent: MediaQuery.of(context).size.width / 2.5,
              endIndent: MediaQuery.of(context).size.width / 2.5,
              thickness: 3.0,
            ),
            const SizedBox(
              height: 5,
            ),
            RatingBar.builder(
              itemSize: 30.0,
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _stars = rating;
                });
              },
            ),
            const SizedBox(
              height: 20,
            ),
            rating(
              stars: _stars.round(),
            ),
            const SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: _stars == 0
                    ? null
                    : () async{
                        await updateDatatbase();
                        // TODO: NAVIGATE.POP
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: buttonColor(_stars.round()),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                  ),
                  height: 50,
                  width: 100,
                  // color: Colors.greenAccent,
                ),
              ),
            ),
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Your word makes GoFoodMan a beter place',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      'You are the influence!',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ]),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class rating extends StatelessWidget {
  int stars = 0;
  rating({
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    switch (stars) {
      case 0:
        return Container();
      case 1:
        return const Icon(
          Icons.sentiment_very_dissatisfied,
          color: Colors.red,
          size: 50,
        );
      case 2:
        return const Icon(
          Icons.sentiment_dissatisfied,
          color: Colors.redAccent,
          size: 50,
        );
      case 3:
        return const Icon(
          Icons.sentiment_neutral,
          color: Colors.amber,
          size: 50,
        );
      case 4:
        return const Icon(
          Icons.sentiment_satisfied,
          color: Colors.lightGreen,
          size: 50,
        );
      case 5:
        return const Icon(
          Icons.sentiment_very_satisfied,
          color: Colors.green,
          size: 50,
        );

      default:
        {
          return Container();
        }
    }
  }
}

Color buttonColor(int _stars) {
  int stars = _stars;

  switch (stars) {
    case 0:
      return Colors.grey;

    case 1:
      return Colors.red;

    case 2:
      return Colors.redAccent;

    case 3:
      return Colors.amber;

    case 4:
      return Colors.lightGreen;

    case 5:
      return Colors.green;

    default:
      {
        return Colors.grey;
      }
  }
}
