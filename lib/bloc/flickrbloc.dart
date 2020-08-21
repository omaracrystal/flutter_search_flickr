import 'dart:async';
import 'package:flutter_search_flickr/models/flickrmodel.dart';
import 'package:flutter_search_flickr/bloc/bloc.dart';

class FlickrBloc extends Bloc {
  final flickrController = StreamController<List<FlickrBlocModel>>.broadcast();

  @override
  void dispose() {
    // TODO: implement dispose
    flickrController.close();
  }
}

FlickrBloc flickrBloc = FlickrBloc();
