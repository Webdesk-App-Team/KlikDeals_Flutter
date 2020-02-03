import 'package:flutter/material.dart';
import 'package:klik_deals/ApiBloc/models/CouponListResponse.dart';

class listDetails extends StatelessWidget {
  Data data;
  bool isForHistory;

  listDetails({@required this.data, this.isForHistory});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 18.0 / 12.0,
              child: Image.asset(
                'assets/images/kfc.png',
                fit: BoxFit.cover,

              ),
            ),
            new Padding(
              padding: EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          data.couponCode,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ), Icon(Icons.edit, size: 20,),
                        Icon(Icons.delete, size: 20,)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: Text(
                      data.description,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.0,
                      ),
                    ),
                  ), Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                    child: Text(
                      "Food",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                    child: _staus(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _staus() {
    if (data.isFromHistory) {
      return Text(
        "${data.statusName}",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12.0,
        ),
      );
    } else {
      return Text(
        "",
        style: TextStyle(
          color: Colors.black54,
          fontSize: 12.0,
        ),
      );
    }
  }
}
