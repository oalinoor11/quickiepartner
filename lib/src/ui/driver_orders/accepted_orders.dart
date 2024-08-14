import 'package:admin/src/blocs/orders/orders_bloc.dart';
import 'package:admin/src/models/app_state_model.dart';
import 'package:admin/src/models/orders/orders_model.dart';
import 'package:admin/src/ui/orders/custom_card.dart';
import 'package:admin/src/ui/orders/order_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcceptedOrdersPage extends StatefulWidget {
  final String driverId;
  final OrdersBloc ordersBloc = OrdersBloc();

  AcceptedOrdersPage({Key? key, required this.driverId}) : super(key: key);
  @override
  _AcceptedOrdersPageState createState() => _AcceptedOrdersPageState();
}

class _AcceptedOrdersPageState extends State<AcceptedOrdersPage> {
  ScrollController _scrollController = new ScrollController();
  DateFormat formatter1 = new DateFormat('dd-MM-yyyy  hh:mm a');
  AppStateModel appStateModel = AppStateModel();

  @override
  void initState() {
    widget.ordersBloc.filter['status'] = 'processing';

    //Filter for Driver
    widget.ordersBloc.filter['driver_app'] = '1';
    widget.ordersBloc.filter['user_id'] = widget.driverId;
    widget.ordersBloc.filter['wcfm_delivery_boy'] = widget.driverId;
    widget.ordersBloc.filter['driver_app'] = appStateModel.options.distance;

    widget.ordersBloc.fetchItems();

    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          widget.ordersBloc.moreItems) {
        widget.ordersBloc.loadMore();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await widget.ordersBloc.fetchItems();
        return;
      },
      child: StreamBuilder<List<Order>>(
          stream: widget.ordersBloc.results,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            return buildOrder(context, snapshot.data![index]);
                          }, childCount: snapshot.data!.length)),
                  widget.ordersBloc.moreItems
                      ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      ))
                      : SliverToBoxAdapter()
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget buildOrder(BuildContext context, Order order) {
    final NumberFormat currencyFormatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString(),
        name: order.currency);

    return CustomCard(
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        onTap: () => openDetailPage(order),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                    primary: getColor(order.status!, context),
                    onPrimary: Colors.black,
                    elevation: 0,
                  ),
                  onPressed: () {},
                  child: Text(
                    '${order.number.toString()}  ${order.status!.toUpperCase()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                    order.billing.firstName + ' ' + order.billing.lastName),
              ],
            ),
            TextButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Theme.of(context).textTheme.bodyText1!.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(2.0)),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  currencyFormatter.format(order.total),
                  style: Theme.of(context).textTheme.subtitle1,
                )),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(formatter1.format(order.dateCreated)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                widget.ordersBloc.completeOrder(order);
              },
              child: Text('MARK COMPLETE'),
            ),
          ],
        ),
      ),
    );
  }

  openDetailPage(Order order) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return OrderDetail(
          order: order, ordersBloc: widget.ordersBloc);
    }));
  }

  getColor(String status, BuildContext context) {
    switch (status) {
      case 'processing':
        return Colors.lightGreen;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'failed':
        return Colors.redAccent.withOpacity(0.8);
      case 'on-hold':
        return Colors.deepOrangeAccent;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
