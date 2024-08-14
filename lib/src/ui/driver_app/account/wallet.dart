import 'package:admin/src/blocs/account/wallet_bloc.dart';
import 'package:admin/src/models/account/wallet_model.dart';
import 'package:admin/src/models/app_state_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Wallet extends StatefulWidget {
  final walletBloc = WalletBloc();
  Wallet({Key? key}) : super(key: key);

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  ScrollController _scrollController = new ScrollController();
  DateFormat dateFormatter = DateFormat('dd-MMM-yyyy');
  final appStateModel = AppStateModel();
  late NumberFormat formatter;

  @override
  void initState() {
    super.initState();
    widget.walletBloc.load();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        widget.walletBloc.loadMore();
      }
    });

    formatter = NumberFormat.simpleCurrency(
        decimalDigits: AppStateModel().options.info!.priceDecimal,
        name: AppStateModel().options.info!.currency);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<List<WalletModel>>(
          stream: widget.walletBloc.allTransactions,
          builder: (context, AsyncSnapshot<List<WalletModel>> snapshot) {
          return snapshot.hasData && snapshot.data != null ? ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: EdgeInsets.all(16),
                dense: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(snapshot.data![index].type.toUpperCase()),
                        SizedBox(width: 8),
                        Text(formatter.format(double.parse(snapshot.data![index].amount))),
                      ],
                    ),
                    Text(formatter.format(double.parse(snapshot.data![index].balance))),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(snapshot.data![index].details),
                    SizedBox(height: 4),
                    Text(dateFormatter.format(snapshot.data![index].date)),
                  ],
                ),
              );
            },
          ) : Center(child: CircularProgressIndicator());
        }
      ),
    );
  }
}
