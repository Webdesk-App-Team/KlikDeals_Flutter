import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:klik_deals/ApiBloc/ApiBloc_event.dart';
import 'package:klik_deals/ApiBloc/ApiBloc_state.dart';
import 'package:klik_deals/AppLocalizations.dart';
import 'package:klik_deals/HomeScreen/HomeState.dart';
import 'package:klik_deals/ImagePickerFiles/Image_picker_handler.dart';
import 'package:klik_deals/commons/CenterLoadingIndicator.dart';
import 'package:klik_deals/mywidgets/ErrorDialog.dart';
import 'package:klik_deals/mywidgets/NoNetworkWidget.dart';
import 'package:klik_deals/mywidgets/RoundWidget.dart';

import 'CouponBloc.dart';

class AddCoupon extends StatefulWidget {
  static const String routeName = "/addCoupon";
  _CouponAdd createState() => _CouponAdd();
}

class _CouponAdd extends State<AddCoupon>
    with TickerProviderStateMixin, ImagePickerListener {
  DateTime _Startdate;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  File _imageBanner;
  bool _isLoading;
  bool isDirty = false;
  CouponBloc auth;
  RoundWidget round;
  String _couponCodeValue;
  String _startDateValue;
  String _endDateValue;
  String _descValue;
  String _errorMessage;
  ApiBlocEvent lastEvent;

  TextEditingController _startDateController,
      _endDateController,
      _couponCodeController,
      _descriptionController;

  _CouponAdd();

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _couponCodeController = TextEditingController();
    _descriptionController = TextEditingController();

    imagePicker = new ImagePickerHandler(this, _controller, maxWidth: 1080);
    imagePicker.init();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    auth = BlocProvider.of<CouponBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate("label_addcoupon"),
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: Stack(children: <Widget>[
        AddCouponDesign(context),
        BlocListener<CouponBloc, ApiBlocState>(
            listener: (context, state) {
              // final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
              //     Scaffold.of(context).showSnackBar(snackBar);
              if (state is CouponAddErrorState) {
                String error =
                    state.addCouponResponse.errorMessage.getCommonError();
                if (error != null) {
                  //ErrorDialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => ErrorDialog(
                      mainMessage: error,
                      okButtonText: AppLocalizations.of(context).translate("label_ok"),
                    ),
                  ).then((isConfirm) {
                    print("we got isConfirm $isConfirm");
                  });
                  // Scaffold.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text(error),
                  //     backgroundColor: Theme.of(context).primaryColor,
                  //   ),
                  // );
                }
              } else if (state is CouponAddFetchedState) {
                lastEvent = ReloadEvent(true);
                auth.add(lastEvent);
                Navigator.pop(context, true);
              }
            },
            child: BlocBuilder<CouponBloc, ApiBlocState>(
                bloc: auth,
                builder: (
                  BuildContext context,
                  ApiBlocState currentState,
                ) {
                  if (currentState is ApiFetchingState) {
                    round = RoundWidget();
                    return CenterLoadingIndicator();
                    // return round;
                  } else if (currentState is NoInternetState) {
                    return NoNetworkWidget(
                      retry: () {
                        retryCall();
                      },
                    );
                  } else {
                    return Container();
                  }
                }))
      ]),
    );
  }

  Widget _ShowerrorMessages() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return SnackBar(
        content: Text(_errorMessage),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate("label_undo"),
          onPressed: () {},
        ),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget AddCouponDesign(BuildContext context) {
    return Stack(children: <Widget>[
      Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                // colorFilter: ColorFilter.mode(
                //     Colors.black.withOpacity(0.2), BlendMode.dstATop),
                image: AssetImage('assets/images/splash_bg.png'),
                fit: BoxFit.cover)),
      ),
      new Padding(
        padding: const EdgeInsets.only(left: 28.0, right: 28.0, top: 8.0),
        child: Container(
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _couponCode(),
                _startDate(context),
                _expiryDate(context),
                _uploadImage(context),
                _description(),
                _addCouponButton(),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Padding _addCouponButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 16),
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
            side: BorderSide(color: Theme.of(context).primaryColor)),
        onPressed: () {
          _validateRequiredFields();
        },
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        child: Text(AppLocalizations.of(context).translate("label_addcoupon").toUpperCase(), style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Padding _description() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child:GestureDetector(
        onTap: (){
           FocusScope.of(context).requestFocus(FocusNode());
        },
      
      child: TextFormField(
          keyboardType: TextInputType.multiline,
          onSaved: (value) => _descValue = value.trim(),
          controller: _descriptionController,
          validator: (value) {
            if (value.isEmpty || value == null) {
              return AppLocalizations.of(context).translate("error_message_coupon");
;
            }
            return null;
          },  
          style: TextStyle(color: Theme.of(context).primaryColor),
          cursorColor: Theme.of(context).primaryColor,
          maxLines: 6,
          decoration: _inputType(AppLocalizations.of(context).translate("label_description"), false))
          ),
    );
  }

  Padding _uploadImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(width: 1, color: Colors.grey)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16.0, bottom: 16, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    AppLocalizations.of(context).translate("title_upload_image"),
                    style: TextStyle(
                        fontSize: 15.0, color: Theme.of(context).primaryColor),
                  ),
                  Spacer(),
                  IconButton(
                    icon: new Icon(Icons.attach_file),
                    iconSize: 20,
                    color: Theme.of(context).primaryColor,
                    onPressed: () {
                      imagePicker.showDialog(context);
                    },
                  )
                ],
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: isDirty
                      ? new Container(
                          height: 160.0,
                          width: 360.0,
                          decoration: new BoxDecoration(
                            image: _CouponImage(isDirty, _imageBanner),
                            border: Border.all(color: Colors.white, width: 0.5),
                          ),
                        )
                      : new Container(
                          height: 160.0,
                          width: 360.0,
                          decoration: new BoxDecoration(
                            image: _CouponImage(isDirty, null),
                            border: Border.all(color: Colors.white, width: 0.5),
                          ),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  Padding _expiryDate(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: TextFormField(
          onSaved: (value) => _endDateValue = value.trim(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context).translate("error_message_expirydate");
;
            }
            return null;
          },
          style: TextStyle(color: Theme.of(context).primaryColor),
          controller: _endDateController,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            if (_Startdate != null && _Startdate != "") {
              _showEndDatePicker(context, _Startdate);
            } else {
              final snackBar = SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                content: Text(AppLocalizations.of(context).translate("error_message_startdate")),
              );
              _scaffoldKey.currentState.showSnackBar(snackBar);
            }
          },
          decoration: _forSearchInputType(AppLocalizations.of(context).translate("title_expirydate"), true)),
    );
  }

  Padding _startDate(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: TextFormField(
          onSaved: (value) => _startDateValue = value.trim(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppLocalizations.of(context).translate("error_message_startdate");
;
            }
            return null;
          },
          style: TextStyle(color: Theme.of(context).primaryColor),
          controller: _startDateController,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
            _showStartDatePicker(context);
          },
          decoration: _forSearchInputType(AppLocalizations.of(context).translate("title_startdate"), true)),
    );
  }

  TextFormField _couponCode() {
    return TextFormField(
        controller: _couponCodeController,
        onSaved: (value) => _couponCodeValue = value.trim(),
        validator: (value) {
          if (value.isEmpty) {
            return AppLocalizations.of(context).translate("error_message_couponcode");
;
          }
          return null;
        },
        style: TextStyle(color: Theme.of(context).primaryColor),
        cursorColor: Theme.of(context).primaryColor,
        decoration: _inputType(AppLocalizations.of(context).translate("label_couponCode"), false));
  }

  InputDecoration _inputType(String hintText, bool isForImageUpload) {
    return InputDecoration(
      fillColor: Color(0xB3FFFFFF),
      filled: true,
      hintStyle: TextStyle(color: Theme.of(context).primaryColor),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.grey)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.grey)),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 10.0),
      hintText: hintText,
    );
  }

  InputDecoration _forSearchInputType(String hintText, bool isForCal) {
    return InputDecoration(
      fillColor: Color(0xB3FFFFFF),
      filled: true,
      hintStyle: TextStyle(color: Theme.of(context).primaryColor),
      suffixIcon: _InputsuffixIcon(isForCal),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
          borderSide: BorderSide(color: Colors.grey)),
      border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(30.0)),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      contentPadding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 10.0),
      hintText: hintText,
    );
  }

  _InputsuffixIcon(bool isForCal) {
    if (isForCal) {
      return new Icon(
        Icons.calendar_today,
        color: Theme.of(context).primaryColor,
        size: 20,
      );
    } else {
      return new Icon(
        Icons.attach_file,
        color: Theme.of(context).primaryColor,
        size: 20,
      );
    }
  }

  //Start date date picker
  void _showStartDatePicker(BuildContext context) {
    final now = DateTime.now();
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(now.year, now.month, now.day + 1),
        maxTime: DateTime(now.year + 1, now.month, now.day), onChanged: (date) {
      _endDateController.clear();
      print('change $date');
    }, onConfirm: (date) {
      _Startdate = date;
      var formatter = new DateFormat('yyyy/MM/dd');
      String formatted = formatter.format(date);
      print('confirm $date');
      setState(() {
        _startDateController.text = formatted.toString();
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  //End date date picker
  void _showEndDatePicker(BuildContext context, DateTime startDate) {
    final now = DateTime.now();
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        minTime: DateTime(startDate.year, startDate.month, startDate.day + 1),
        maxTime: DateTime(now.year + 1, now.month, now.day), onChanged: (date) {
      print('change $date');
    }, onConfirm: (date) {
      var formatter = new DateFormat('yyyy/MM/dd');
      String formatted = formatter.format(date);
      print('confirm $date');
      setState(() {
        _endDateController.text = formatted.toString();
      });
    }, currentTime: DateTime.now(), locale: LocaleType.en);
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateRequiredFields() {
    if (validateAndSave()) {
      print(":::::::::::::::We get coupon data :::::::::::");
      print(_couponCodeValue);
      print(_startDateValue);
      print(_endDateValue);
      print(_descValue);
      print(_imageBanner);
      try {
        lastEvent = AddCouponEvent(_couponCodeValue, _startDateValue,
            _endDateValue, _descValue, _imageBanner);
        auth.add(lastEvent);
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  userImage(File _image) {
    if (_image != null) {
      setState(() {
        isDirty = true;
        this._imageBanner = _image;
      });
    } else {
      print("Image is null please check @416");
    }
  }

  void retryCall() {
    if (lastEvent != null) {
      auth.add(lastEvent);
    }
  }
}

_CouponImage(bool isDirty, File imageBanner) {
  if (isDirty) {
    return new DecorationImage(
      image: new FileImage(imageBanner),
      fit: BoxFit.cover,
    );
  } else {
    return new DecorationImage(
      colorFilter: new ColorFilter.mode(
          Colors.white.withOpacity(0.2), BlendMode.dstATop),
      image: new AssetImage('assets/images/logo.png'),
      fit: BoxFit.scaleDown,
    );
  }
}
