import 'dart:io';
import 'package:admin/src/config.dart';
import 'package:admin/src/models/app_state_model.dart';
import 'package:admin/src/resources/api_provider.dart';
import 'package:admin/src/ui/customers/newsletter.dart';
import 'package:admin/src/ui/gift_cards/gift_card_list.dart';
import 'package:admin/src/ui/orders/bluetooth_printer.dart';
import 'package:admin/src/ui/reviews/reviews.dart';
import 'package:admin/src/ui/tax_classes/tax_classes.dart';
import 'package:admin/src/ui/tax_rates/tax_rates.dart';
import 'package:admin/src/ui/theme_settings.dart';
import 'package:admin/src/ui/webview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:scoped_model/scoped_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:admin/src/models/account/account_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'language/app_localizations.dart';
import 'settings/settings.dart';
import 'shipping/shipping_zone.dart';

class MyDrawer extends StatefulWidget {
  final ValueChanged<int> onChangePageIndex;
  MyDrawer({Key? key, required this.onChangePageIndex}) : super(key: key);
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> with TickerProviderStateMixin {
  final TextStyle _biggerFont =
      const TextStyle(fontSize: 24, color: Colors.white);

  static final Animatable<Offset> _drawerDetailsTween = Tween<Offset>(
    begin: const Offset(0.0, -1.0),
    end: Offset.zero,
  ).chain(CurveTween(
    curve: Curves.fastOutSlowIn,
  ));

  late AnimationController _controller;
  late Animation<double> _drawerContentsOpacity;
  late Animation<Offset> _drawerDetailsPosition;
  bool _showDrawerContents = true;
  //Account activeAccount = new Account(name: '', url: '');

  @override
  initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _drawerContentsOpacity = CurvedAnimation(
      parent: ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = _controller.drive(_drawerDetailsTween);
    //getActiveAccount();
  }

  /*getActiveAccount() async {
    final database = openDatabase(
        join(await getDatabasesPath(), 'accounts_database.db'));

    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts', where: 'selected = 1');

    if(maps.isNotEmpty){
      setState(() {
        activeAccount.name = maps[0]['name'];
        activeAccount.url = maps[0]['url'];
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    Color primaryIconThemeColor = Theme.of(context).primaryIconTheme.color!;
    return Drawer(
      child: ScopedModelDescendant<AppStateModel>(
          builder: (context, child, model) {
        return Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              arrowColor: primaryIconThemeColor,
              accountName: model.options.info?.name != null ? Text(model.options.info!.name) : Text(''),
              accountEmail: model.options.info?.description != null ? Text(model.options.info!.description) : Text(''),
              margin: EdgeInsets.zero,
              onDetailsPressed: () {
                _showDrawerContents = !_showDrawerContents;
                if (_showDrawerContents)
                  _controller.reverse();
                else
                  _controller.forward();
              },
            ),
            MediaQuery.removePadding(
              context: context,
              // DrawerHeader consumes top MediaQuery padding.
              removeTop: true,
              child: Builder(
                builder: (context) {
                    return Expanded(
                      child: model.user!.role == 'administrator' ? ListView(
                        dragStartBehavior: DragStartBehavior.down,
                        padding: const EdgeInsets.only(top: 8.0),
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              FadeTransition(
                                opacity: _drawerContentsOpacity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("report"),
                                      ),
                                      leading: CircleAvatar(child: Text('R')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(0);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("orders"),
                                      ),
                                      leading: CircleAvatar(child: Text('O')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(1);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("bookings"),),
                                      leading: CircleAvatar(child: Text('O')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(2);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("products"),
                                      ),
                                      leading: CircleAvatar(child: Text('P')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(3);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("customers"),
                                      ),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(4);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("drivers"),),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/DeliveryBoys');
                                      },
                                    ),
                                    /*ListTile(
                                      title: Text('Newsletters'),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/NewsLetter');
                                      },
                                    ),*/
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("categories"),
                                      ),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/CategoryList');
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("coupons"),
                                      ),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/Coupons');
                                      },
                                    ),
                                    ListTile(
                                      title: Text( AppLocalizations.of(context)
                      .translate("gift_cards"),),
                                      leading: CircleAvatar(child: Text('S')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => GiftCardList()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("payments"),
                                      ),
                                      leading: CircleAvatar(child: Text('P')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/PaymentGatewayList');
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("reviews"),),
                                      leading: CircleAvatar(child: Text('R')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ReviewsPage()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("shipping"),),
                                      leading: CircleAvatar(child: Text('S')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ShippingZonePage()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("tax_rates"),),
                                      leading: CircleAvatar(child: Text('T')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TaxRates()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("tax_classes"),),
                                      leading: CircleAvatar(child: Text('T')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TaxClasses()),
                                        );
                                      },
                                    ),
                                   /* ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("admin_panel"),),
                                      leading: CircleAvatar(child: Text('S')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => WebViewPage(
                                                  url: ApiProvider().wc_api.url +
                                                      '/wp-admin/index.php')),
                                        );
                                      },
                                    ),*/
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("connect_printer"),),
                                      leading: CircleAvatar(child: Text('P')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BluetoothOrderPrinter()),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("settings"),),
                                      leading: CircleAvatar(child: Text('S')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SettingsGroups()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SlideTransition(
                                position: _drawerDetailsPosition,
                                child: FadeTransition(
                                  opacity: ReverseAnimation(_drawerContentsOpacity),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      ListTile(
                                        trailing: Icon(Icons.arrow_right),

                                        leading: const Icon(Icons.language),
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .translate("Language"),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/LanguagePage');
                                        },
                                      ),
                                      ListTile(
                                        trailing: Icon(Icons.arrow_right),

                                        leading: const Icon(Icons.notifications),
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .translate("notifications"),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/NotificationPage');
                                        },
                                      ),
                                      ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ThemeSettingsPage()));
                                        },
                                        leading:
                                        Icon(CupertinoIcons.brightness_solid),
                                        trailing: Icon(Icons.arrow_right),
                                        title: Text(AppLocalizations.of(context)
                                            .translate("theme"),),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          AppStateModel().logout();
                                        },
                                        leading:
                                        Icon(CupertinoIcons.power),
                                        trailing: Icon(Icons.arrow_right),
                                        title: Text(AppLocalizations.of(context)
                                            .translate("logout"),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ) : ListView(
                        dragStartBehavior: DragStartBehavior.down,
                        padding: const EdgeInsets.only(top: 8.0),
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              FadeTransition(
                                opacity: _drawerContentsOpacity,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("orders"),
                                      ),
                                      leading: CircleAvatar(child: Text('O')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(0);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                                        .translate("bookings")),
                                      leading: CircleAvatar(child: Text('O')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(1);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("products"),
                                      ),
                                      leading: CircleAvatar(child: Text('P')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        widget.onChangePageIndex(2);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("drivers")),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/DeliveryBoys');
                                      },
                                    ),
                                   /* ListTile(
                                      title: Text(
                                        AppLocalizations.of(context)
                                            .translate("categories"),
                                      ),
                                      leading: CircleAvatar(child: Text('C')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.pushNamed(context, '/CategoryList');
                                      },
                                    ),*/
                                    ListTile(
                                      title: Text(AppLocalizations.of(context)
                      .translate("connect_printer"),),
                                      leading: CircleAvatar(child: Text('P')),
                                      trailing: Icon(Icons.arrow_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  BluetoothOrderPrinter()),
                                        );
                                      },
                                    ),
                                    /*ListTile(
                                      onTap: () {
                                        Navigator.push(
                                            context, MaterialPageRoute(builder: (context) => WebViewPage(url: Config().url + _getVendorUrl(model.options.vendorType))));
                                      },
                                      leading: CircleAvatar(child: Text('D')),
                                      trailing: Icon(Icons.arrow_right),
                                      title: Text('Dashboard'),
                                    ),*/
                                  ],
                                ),
                              ),
                              SlideTransition(
                                position: _drawerDetailsPosition,
                                child: FadeTransition(
                                  opacity: ReverseAnimation(_drawerContentsOpacity),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      ListTile(
                                        trailing: Icon(Icons.arrow_right),

                                        leading: const Icon(Icons.language),
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .translate("Language"),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/LanguagePage');
                                        },
                                      ),
                                      ListTile(
                                        trailing: Icon(Icons.arrow_right),

                                        leading: const Icon(Icons.notifications),
                                        title: Text(
                                          AppLocalizations.of(context)
                                              .translate("notifications"),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/NotificationPage');
                                        },
                                      ),
                                      ListTile(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ThemeSettingsPage()));
                                        },
                                        leading:
                                        Icon(CupertinoIcons.brightness_solid),
                                        trailing: Icon(Icons.arrow_right),
                                        title: Text(AppLocalizations.of(context)
                                            .translate("theme"),),
                                      ),
                                      ListTile(
                                        onTap: () {
                                          AppStateModel().logout();
                                        },
                                        leading:
                                        Icon(CupertinoIcons.power),
                                        trailing: Icon(Icons.arrow_right),
                                        title: Text(AppLocalizations.of(context)
                                            .translate("logout"),),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                }
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getVendorUrl(String vendorType) {
    switch (vendorType) {
      case 'wcfm':
        return '/store-manager';
      case 'dokan':
        return '/dashboard';
      case 'wcfm':
        return '/wp-admin';
      default:
        return '/wp-admin';
    }
  }
}
