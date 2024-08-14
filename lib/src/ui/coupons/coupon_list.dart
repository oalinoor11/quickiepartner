import 'package:admin/src/blocs/coupons/coupon_bloc.dart';
import 'package:admin/src/ui/coupons/search_coupon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admin/src/models/coupons/coupons_model.dart';
import 'package:admin/src/ui/language/app_localizations.dart';
import '../drawer.dart';
import 'add_coupon.dart';
import 'coupon_detail.dart';
import 'filter_coupon.dart';

class CouponList extends StatefulWidget {
  CouponsBloc couponsBloc = CouponsBloc();
  @override
  _CouponListState createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> {

  ScrollController _scrollController = new ScrollController();
  Widget appBarTitle = demo();
  bool _hideSearch = true;

  @override
  void initState() {
    super.initState();
    widget.couponsBloc.fetchItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        widget.couponsBloc.loadMore();
      }
    });
  }

  @override
  void dispose() {
 //  widget.couponsBloc.dispose();
   // super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: new Icon(CupertinoIcons.search),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => SearchCoupon()
                  ));
            },
          ),

          IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: 'filter',
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<DismissDialogAction>(
                builder: (BuildContext context) => FilterCoupon(couponsBloc: widget.couponsBloc),
                fullscreenDialog: true,
              ));
            },
          ),
        ],
      ),

      body: StreamBuilder(
          stream: widget.couponsBloc.results,
          builder: (context, AsyncSnapshot<List<Coupon>> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return buildList(snapshot);
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Center(child: CircularProgressIndicator());
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddCoupon()),
          );
        },
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }

  Widget buildList(AsyncSnapshot<List<Coupon>> snapshot) {

    Iterable<Widget> listTiles = snapshot.data!.map<Widget>((Coupon item) => buildListTile(context, item));
    listTiles = ListTile.divideTiles(context: context, tiles: listTiles);

    return Scrollbar(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: listTiles.toList(),
      ),
    );
  }

  Widget buildListTile(BuildContext context, Coupon coupon) {
    return MergeSemantics(
      child: ListTile(
        onTap: () => openDetail(coupon),
        isThreeLine: coupon.description != '',
        title: Text(coupon.code),
        subtitle: coupon.discountType == '' ? null : Text(coupon.discountType),
      ),
    );
  }



  openDetail(Coupon coupon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CouponDetail(coupon:coupon)),
    );
  }

  static Widget demo() {
    return  StreamBuilder(
      builder: (context, snapshot) {
        return new Text(AppLocalizations.of(context).translate("coupons"));
      }
    );
   }
}


