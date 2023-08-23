import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sembast/sembast.dart';
import '/BloCLayer/StoreEvent.dart';
import '/BloCLayer/UserBloc.dart';
import '/DataLayer/LocalDB/databaseSetup.dart';
import '/DataLayer/Models/Other/kmToMeter.dart';
import '/DataLayer/Models/StoreModels/Offer.dart';
import '/DataLayer/Models/StoreModels/RateList.dart';
import '/DataLayer/Models/StoreModels/StoreReview.dart';
import '/DataLayer/Models/adminModels/adminMetaData.dart';
import '/const.dart';
import '../DataLayer/Models/StoreModels/Store.dart';
import 'AdminBloc.dart';

class StoreBloc extends Bloc {
  //LocalDB
  final _pietyFolder = intMapStoreFactory.store(Constants.folderName);
  Future<Database> get _db async => await AppDatabase.instance.database;

  List<Store> _initialStores = [];
  List<Store> get getInitialStore => this._initialStores;
  RateList? _singleStoreRateList;
  UserBloc? _userBloc;
  AdminBloc? _adminBloc;
  set setUserBloc(UserBloc userBloc) {
    this._userBloc = userBloc;
  }

  set setAdminBloc(AdminBloc adminBloc) {
    this._adminBloc = adminBloc;
  }

  //getting all stores
  List<Store> _allStores = [];
  List<Store> get getAllStore => this._allStores;

  Store? _store;
  Store get getSingleStore => this._store!;

  RateList? _initialRateList;
  RateList get getInitialRateList => this._initialRateList!;

  List<StoreType>? storeTypes;

  List<Store> featureOfferList = [];
  get getFeatureOfferList => this.featureOfferList;

  List<Store>? sortedStores;
  List<Offer>? storeOffer;
  List<StoreReviewList>? storeReview;

  List<String> _categoryRateList = [];
  get getCategoryRateList => this._categoryRateList;
  List<RateListItem> _itemRateList = [];
  get getItemRatelist => this._itemRateList;
  List<String> _addOnServices = [];
  get getAddOnServices => this._addOnServices;
  List<String> _allServices = [];
  get getAllServices => this._allServices;
  List<String> _selectedServices = [];
  get getSelectedServices => this._selectedServices;
  List<StoreReviewList> get getStoreReview => this.storeReview!;

  List<Store>? selectedStore;
  get getSelectedStore => this.selectedStore;



  List<Store>? primaryStore;
  get getPrimaryStore=>this.getPrimaryStore;

/////////////////////Stream for primary stores
  StreamController<List<Store>> _primaryStoreController=
  StreamController<List<Store>>.broadcast();
  StreamSink<List<Store>> get storePrimaryListSink=>
  _primaryStoreController.sink;
  Stream<List<Store>>get storePrimaryListStream =>
  _primaryStoreController.stream;




  StreamController<List<Offer>> _storeOfferListController =
      StreamController<List<Offer>>.broadcast();
  StreamSink<List<Offer>> get storeOfferListSink =>
      _storeOfferListController.sink;
  Stream<List<Offer>> get storeOfferListStream =>
      _storeOfferListController.stream;

  StreamController<List<Store>> _storeTypeListController =
      StreamController<List<Store>>.broadcast();
  StreamSink<List<Store>> get storeTypeListSink =>
      _storeTypeListController.sink;
  Stream<List<Store>> get storeTypeListStream =>
      _storeTypeListController.stream;

  StreamController<List<Store>> _allStoreController =
      StreamController<List<Store>>.broadcast();
  StreamSink<List<Store>> get allStoreSink => _allStoreController.sink;
  Stream<List<Store>> get allStoreStream => _allStoreController.stream;

  //storeReview
  StreamController<List<StoreReviewList>> _storeReviewListController =
      StreamController<List<StoreReviewList>>.broadcast();
  StreamSink<List<StoreReviewList>> get storeReviewListSink =>
      _storeReviewListController.sink;
  Stream<List<StoreReviewList>> get storeReviewListStream =>
      _storeReviewListController.stream;

  StreamController<Store> _singleStoreController =
      StreamController<Store>.broadcast();
  StreamSink<Store> get singleStoreSink => _singleStoreController.sink;
  Stream<Store> get singleStoreStream => _singleStoreController.stream;

  StreamController<RateList> _rateListController =
      StreamController<RateList>.broadcast();
  StreamSink<RateList> get singleRateListSink => _rateListController.sink;
  Stream<RateList> get singleRateListStream => _rateListController.stream;

  //allService
  StreamController<List<String>> _allServicesController =
      StreamController<List<String>>.broadcast();
  StreamSink<List<String>> get allServicesSink => _allServicesController.sink;
  Stream<List<String>> get allServicesStream => _allServicesController.stream;

  //addOnServices
  StreamController<List<String>> _addOnServicesController =
      StreamController<List<String>>.broadcast();
  StreamSink<List<String>> get addOnServicesSink =>
      _addOnServicesController.sink;
  Stream<List<String>> get addOnServicesStream =>
      _addOnServicesController.stream;

  StreamController<List<StoreType>> _storeTypeController =
      StreamController<List<StoreType>>.broadcast();
  StreamSink<List<StoreType>> get storeTypeSink => _storeTypeController.sink;
  Stream<List<StoreType>> get storeTypeStream => _storeTypeController.stream;

  StreamController<List<RateListItem>> _rateListItemTypeController =
      StreamController<List<RateListItem>>.broadcast();
  StreamSink<List<RateListItem>> get rateListItemTypeSink =>
      _rateListItemTypeController.sink;
  Stream<List<RateListItem>> get rateListItemTypeStream =>
      _rateListItemTypeController.stream;

  StreamController<List<String>> _categoryListOfStoreController =
      StreamController<List<String>>.broadcast();
  StreamSink<List<String>> get categoryListOfStoreSink =>
      _categoryListOfStoreController.sink;
  Stream<List<String>> get categoryListOfStoreStream =>
      _categoryListOfStoreController.stream;

  StreamController<List<Store>> _selectedStoreController =
      StreamController<List<Store>>.broadcast();
  StreamSink<List<Store>> get selectedStoreSink =>
      _selectedStoreController.sink;
  Stream<List<Store>> get selectedStoreStream =>
      _selectedStoreController.stream;

  StreamController<List<Store>> _featuredOfferStoreController =
      StreamController<List<Store>>.broadcast();
  StreamSink<List<Store>> get featuredOfferStoreOfferListSink =>
      _featuredOfferStoreController.sink;
  Stream<List<Store>> get featuredOfferStoreOfferListStream =>
      _featuredOfferStoreController.stream;

  // final Distance distance = new Distance();

  StoreBloc.initialize() {
    mapEventToState(FetchLocalDB());
  }


   mapEventToState(StoreEvent event) async {
    if (event is FetchLocalDB) {
      print("GetAll Store from localDB");
      List<Store> stores = [];
      final recordSnapshot = await _pietyFolder.find(await _db);
      print("Local DB::: " + recordSnapshot.length.toString());
      recordSnapshot.forEach((store) {
        stores.add(Store.fromMap(store.value));
      });
      _allStores = stores;
      allStoreSink.add(stores);
      print("_stores :: " + stores.length.toString());

      print("Stores in Local DB " + recordSnapshot.length.toString());
    } else if (event is GetAllStore) {
      print("GetAll Store");
      FirebaseFirestore.instance
          .collection("stores")
          .where("isActive", isEqualTo: true)
          .where("isOpen", isEqualTo: true)
          .snapshots()
          .listen((QuerySnapshot querySnapshot) async {
        List<Store> stores = [];
        querySnapshot.docs.forEach((DocumentSnapshot snapshot) {
          Store intermediateStore =
              Store.fromMap(snapshot.data() as Map<String, dynamic>);
          print("Services ::: ${intermediateStore.services}");
          stores.add(intermediateStore);
        });

        _allStores = stores;
        //first delete existing and then add new
        await _pietyFolder.drop(await _db).then((_) {
          //insert each store to local DB
          _allStores.forEach((x) async {
            await _pietyFolder.add(await _db, x.toJson());
          });
        });
        allStoreSink.add(stores);
        mapEventToState(GetFeatureOfferList());
      });
    } else if (event is GetFeatureOfferList) {
      List<String> storeIdList = [];
      FirebaseFirestore.instance
          .collection("admin_panel")
          .doc("data")
          .snapshots()
          .listen((data) {
        featureOfferList = [];
        List<Store> offerList = [];
        data.data()!["featureOffer"].forEach((offer) {
          if (offer["status"] == "Approved") {
            print("Offer List ${offer["storeId"]}");
            storeIdList.add(offer["storeId"]);
            getAllStore.forEach((store) {
              if (store.uid == offer["storeId"]) {
                offerList.add(store);
              }
            });
          }
        });
        featureOfferList = offerList;
        featuredOfferStoreOfferListSink.add(featureOfferList);
      });
    } else if (event is InitialData) {
      print("InitialData Called");
      Placemark place = event.currentPosition;
      String address =
          "${place.name}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
      var location = await locationFromAddress(address);
      print("++++++++++");
      print(location[0].latitude);
      print(location[0].longitude);

      var latx = location[0].latitude;
      var longx = location[0].longitude;

      List<Store> stores = [];
      if (getAllStore != null) {
        getAllStore.forEach((store) {
          Store intermediateStore = store;
          // num distanceInMeters = GeolocatorPlatform.instance.bearingBetween(
          //   latx,
          //   longx,
          //   intermediateStore.storeCoordinates!.latitude,
          //   intermediateStore.storeCoordinates!.longitude,
          // );
          num distanceInMeters = GeolocatorPlatform.instance.distanceBetween(
            latx,
            longx,
            intermediateStore.storeCoordinates!.latitude,
            intermediateStore.storeCoordinates!.longitude,
          );
          print(intermediateStore.name);
          print("latx: "+latx.toString() + " longx: "+longx.toString()+ " store lat: "+intermediateStore.storeCoordinates!.latitude.toString()+" store long:" + intermediateStore.storeCoordinates!.longitude.toString());
          print("dist in m" + distanceInMeters.toString());
          print("km to meter" +
              KmToMeter.getMeterFromKM(intermediateStore.selfDeliveryDistance!)
                  .toString());
          if (distanceInMeters <
              KmToMeter.getMeterFromKM(
                  intermediateStore.selfDeliveryDistance!)) {
            print("jjjjj");
            print(distanceInMeters);
            stores.add(intermediateStore);
          } else {
            print("else jjj");
            print(
                "My distance from store ${store.name} and distance $distanceInMeters");
          }
        });

        _initialStores = stores;
        sortedStores = stores;
        selectedStore = stores;
        print("hello world: ");
        print(stores.length);
        storeTypeListSink.add(stores);
      }
    } else if (event is GetStoresOfType) {
      print("GETSTOREOFTYPE");
      // Position currentPosition = event.currentPosition.position;
      List<Location> location =
          await locationFromAddress(event.currentPosition.locality.toString());
      var latx = location[0];
      print("$latx ppp");

      List<Store> stores = [];
      _allStores.forEach((store) {
        Store intermediateStore = store;
        if (intermediateStore.storeType == event.storeType) {
          stores.add(intermediateStore);
        }
      });
      print("$stores ooooo");
      _initialStores = stores;
      sortedStores = stores;
      storeTypeListSink.add(stores);
    } else if (event is GetSingleStore) {
      Store newStore =
          _allStores.firstWhere((store) => store.uid == event.storeID);
      _store = newStore;
      print(_store);
      singleStoreSink.add(_store!);
    } else if (event is FetchRateList) {
      FirebaseFirestore.instance
          .collection("rateLists")
          .where("storeId", isEqualTo: event.storeID)
          .snapshots()
          .listen((QuerySnapshot snapshot) {
        _allServices = [];
        _addOnServices = [];
        _categoryRateList = [];
        _singleStoreRateList = RateList.fromSnapshot(
            snapshot.docs[0] as QueryDocumentSnapshot<Map<String, dynamic>>);
        //print("Rate List length is : ${snapshot.docs.length}");
        if (snapshot.docs != null && snapshot.docs.isNotEmpty) {
          RateList loaded = RateList.fromSnapshot(snapshot.docs.first
              as QueryDocumentSnapshot<Map<String, dynamic>>);
          _initialRateList = loaded;
          print("LOADED::" + loaded.toString());
          for (int i = 0; i < loaded.categoryList!.length; i++) {
            if (loaded.categoryList![i] != "Add - ons" &&
                loaded.categoryList![i] != "") {
              _allServices.add(loaded.categoryList![i]);
            }
          }
          for (int i = 0; i < loaded.rateListItem!.length; i++) {
            if (loaded.rateListItem![i].categoryName == "Add - ons") {
              _addOnServices.add(loaded.rateListItem![i].serviceName!);
            }
          }
          // print(_initialRateList.toString());
          _categoryRateList = loaded.categoryList!;
          categoryListOfStoreSink.add(loaded.categoryList!);
          allServicesSink.add(_allServices);
          addOnServicesSink.add(_addOnServices);

          singleRateListSink.add(RateList.fromSnapshot(snapshot.docs.first
              as QueryDocumentSnapshot<Map<String, dynamic>>));
        } else {
          singleRateListSink.addError("Unable to Fetch Rate List");
        }
      });
    } else if (event is GetStoreType) {
      FirebaseFirestore.instance
          .collection("admin_panel")
          .doc("data")
          .snapshots()
          .listen((data) {
        List<StoreType> types = [];
        for (int i = 0; i < data.data()!["storeTypes"].length; i++) {
          types.add(StoreType.fromMap(data.data()!["storeTypes"][i]));
        }
        storeTypeSink.add(types);
        storeTypes = types;
        // print("Store Types are : ${storeTypes.toString()}");
      });
    } else if (event is SortByPrice) {
      sortedStores!
          .sort((a, b) => a.minOrderAmount!.compareTo(b.minOrderAmount!));
      storeTypeListSink.add(sortedStores!);
    } else if (event is SortByName) {
      sortedStores!.sort((a, b) => a.name!.compareTo(b.name!));
      storeTypeListSink.add(sortedStores!);
    } else if (event is GetRateListOfType) {
      List<RateListItem> items = _singleStoreRateList!.rateListItem!;
      List<RateListItem> temp = [];
      _itemRateList = [];
      if (event.rateListType != "All") {
        temp.addAll(
            items.where((item) => item.categoryName == event.rateListType));
        // print("\n$temp\n");
        _itemRateList = temp;
        rateListItemTypeSink.add(temp);
      } else {
        _itemRateList = items;
        rateListItemTypeSink.add(items);
      }
    } else if (event is GetStoreOffer) {
      Store _store =
          _allStores.firstWhere((store) => store.uid == event.storeId);
      storeOffer = [];
      for (var i = 0; i < _store.offers!.length; i++) {
        // if (_userBloc.getUser.appliedOffers
        //     .contains(snapshot.data["offers"][i]["offerCode"])) {
        // } else {
        storeOffer!.add(_store.offers![i]);
        //}
      }
      storeOfferListSink.add(storeOffer!);
    } else if (event is GetStoreReview) {
      FirebaseFirestore.instance
          .collection("orders")
          .where("storeId", isEqualTo: event.storeId)
          .snapshots()
          .listen((snapshot) {
        storeReview = [];
        for (var i = 0; i < snapshot.docs.length; i++) {
          if (snapshot.docs[i].data()["userReview"] != null) {
            storeReview!.add(StoreReviewList.fromSnapshot(snapshot.docs[i]));
          }
        }
        storeReviewListSink.add(storeReview!);
        //print("StoreBloc:: storeReview" + storeReview.length.toString());
      });
    } else if (event is SelectedStore) {
      selectedStore = [];
      List<Store> intermediateStore = [];
      if (event.isFeatured) {
        getAllStore.forEach((store) {
          if (store.name!.contains(event.storeName!)) {
            intermediateStore.add(store);
          }
        });
      } else {
        getAllStore.forEach((store) {
          if (store.storeType == event.selectedStore) {
            intermediateStore.add(store);
          }
        });
      }

      selectedStore = intermediateStore;
      selectedStoreSink.add(selectedStore!);
    } else if (event is SearchBasedStore) {
      selectedStore = [];
      List<Store> intermediateStore = [];
      getAllStore.forEach((store) {
        if (store.services!.contains(event.serviceName.trim())) {
          intermediateStore.add(store);
        }
      });
      selectedStore = intermediateStore;
      selectedStoreSink.add(selectedStore!);
    }
////////////////////////////////////////////////
     // ...
    else if(event is PrimaryStores) {
  primaryStore = [];
  List<Store> intermediateStore = [];

  FirebaseFirestore.instance.collection("stores").get().then((querySnapshot) {
  querySnapshot.docs.forEach((storeDoc) {
  var storeData = storeDoc.data();
  if(storeData.containsKey("storeCoordinates")&&  storeData["storeCoordinates"].containsKey("lat") &&
      storeData["storeCoordinates"].containsKey("lng")){
  double storeLatitude = storeData["storeCoordinates"]["lat"];
  double storeLongitude = storeData["storeCoordinates"]["lng"];

  double distanceInMeters = Geolocator.distanceBetween(
  event.latitude,
  event.longitude,
  storeLatitude,
  storeLongitude,
  );

  if (distanceInMeters < 1000000.0) {

    try {

      intermediateStore.add(Store.fromMap(storeData));
      print("Added to intermediateStore");
    } catch (e) {
      print("Error adding to intermediateStore: $e");
    }

    intermediateStore.sort((a, b) => b.rating!.compareTo(a.rating!));
    primaryStore = intermediateStore;
    print("Adding data to stream: ${primaryStore?.length}");
    storePrimaryListSink.add(primaryStore!);
  }}}
  );}
  );}
// ...

/////////////////////////////////////////////


      else if (event is FilterBasedStore) {
      // selectedStore = [];
      List<Store> intermediateStore = [];
      if (event.isRatingFilter) {
        selectedStore!.forEach((store) {
          if (event.rating! <= store.rating!) {
            intermediateStore.add(store);
          }
        });
      } else {
        selectedStore!.forEach((store) {
          if (event.searchStoreName!.trim() == store.name &&
              event.searchStoreName!.isNotEmpty) {
            intermediateStore.add(store);
          }
        });
      }

      selectedStore = [];
      selectedStore = intermediateStore;
      selectedStoreSink.add(selectedStore!);
      _userBloc!.positionStream.listen((place) {
        mapEventToState(InitialData(currentPosition: place));
      });
    }

  }

  @override
  void dispose() {
    _allServicesController.close();
    _addOnServicesController.close();
    _storeTypeListController.close();
    _singleStoreController.close();
    _rateListController.close();
    _storeTypeController.close();
    _rateListItemTypeController.close();
    _categoryListOfStoreController.close();
    _selectedStoreController.close();
    _storeReviewListController.close();
    _storeOfferListController.close();
    _allStoreController.close();
    _featuredOfferStoreController.close();
    _primaryStoreController.close();

  }
}
