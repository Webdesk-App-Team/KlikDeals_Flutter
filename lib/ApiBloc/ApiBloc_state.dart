import 'package:equatable/equatable.dart';
import 'package:klik_deals/ApiBloc/models/CouponListResponse.dart';
import 'package:klik_deals/ApiBloc/models/LoginResponse.dart';

import 'models/SearchResponse.dart';

abstract class ApiBlocState extends Equatable {}

class ApiUninitializedState extends ApiBlocState {
  @override
  
  List<Object> get props => [];
}

class ApiFetchingState extends ApiBlocState {
  @override 
  List<Object> get props => [];
}

class ApiFetchedState extends ApiBlocState {
  final SearchResponse searchResult;

  ApiFetchedState({this.searchResult});

  @override
  List<Object> get props => [searchResult];
}

class CouponListFetchedState extends ApiBlocState{
  final CouponListResponse couponlist;

  CouponListFetchedState(this.couponlist);

  @override
  
  List<Object> get props => [couponlist];
}

class ApiErrorState extends ApiBlocState {
  @override
  List<Object> get props => [];
}

class couponApiErrorState extends ApiBlocState {
  final CouponListResponse couponlist;

  couponApiErrorState(this.couponlist);

  @override
  List<Object> get props => [couponlist];
}

class ApiEmptyState extends ApiBlocState {
  @override
  
  List<Object> get props => [];
}
