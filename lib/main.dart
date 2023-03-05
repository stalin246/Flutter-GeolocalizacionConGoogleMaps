  // ignore_for_file: unnecessary_this
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_maps/MarkerInformation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as lc;
import 'package:permission_handler/permission_handler.dart';


  void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      );
    }
  }

  class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key, required this.title});
    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
  }

  const DEFAULT_LOCATION = LatLng(-0.1795791, -78.4767415);

  class _MyHomePageState extends State<MyHomePage> {
    int _counter = 0;
    // LatLng position=DEFAULT_LOCATION;
    MapType mapType = MapType.normal;
    late BitmapDescriptor icon;
    bool isShowInfo = false;
    late lc.Location location;
    bool myLocationEnabled = false;
    bool myLocationButtonEnabled= false;
    LatLng currentLocation =DEFAULT_LOCATION;
    late GoogleMapController controller;

    //Creamos un marcador que siga al usuario
    Set<Marker>markers= Set<Marker>();


  
    @override
    void initState(){
      getIcons();
      requestPerms();

    }

    requestPerms()async {
      Map<Permission, PermissionStatus>statuses=await [Permission.locationAlways].request();
      var status = statuses[Permission.locationAlways];
      if(status==PermissionStatus.denied){
        requestPerms();
      }else {
        enableGPS();

      }
    }

    enableGPS() async {
      location = lc.Location();
      bool serviceStatusResult=await location.requestService();

      if(!serviceStatusResult){
        enableGPS();
      }else{
        updatestatus();
        getLocation();
        locationChanged();

      }
    }

    updatestatus(){
      setState(() {
        myLocationEnabled= true;
        myLocationButtonEnabled = true;
      });
    }
    
    getIcons()async{
      var icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), "assets/luna.png");
      setState(() {
        this.icon = icon;
      });
    }

    getLocation()async{
      var currentLocation = await location.getLocation();
      updateLocation(currentLocation);

    }
    //Para actualizar la ubicacion
    updateLocation(currentLocation){
      if(currentLocation!=null){
        // print("ubicacion actual del usuario latitud y longitud ${currentLocation.latitude} ${currentLocation.longitude}");
        setState((){
          this.currentLocation=currentLocation;
          this.controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: this.currentLocation, zoom: 17),));
          createMarkers();
        });
    
      }

    }
    locationChanged(){
      location.onLocationChanged.listen((lc.LocationData cLoc){
        if(cLoc!=null)
        updateLocation(cLoc);


      });
    }
    onMapCreated(GoogleMapController controller){
      this.controller = controller;

    }

    createMarkers(){
      markers.add(Marker(
              markerId: MarkerId("MarkerCurrent"),
              position: currentLocation,
              icon: this.icon,
              onTap:()=>setState(() {
              this.isShowInfo=!this.isShowInfo;
              })

        )
      );
    }

    @override
    Widget build(BuildContext context) {

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        // Al ser widget stack se puede ñadir mas widgets encima de el

        body: Stack(
          children: <Widget>[
            GoogleMap(
              // rotateGesturesEnabled: false,
              // scrollGesturesEnabled: false,
              zoomGesturesEnabled: false,
              // tiltGesturesEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              trafficEnabled: true,
              buildingsEnabled: true,
             
  
              initialCameraPosition: CameraPosition(
              // target: position, 
              target: currentLocation,
              zoom: 11
              ),
              //Utilizamos la ubicacion
              myLocationEnabled: myLocationEnabled,
              myLocationButtonEnabled: myLocationButtonEnabled,

              onMapCreated: onMapCreated,
              mapType: mapType,
              // Utilizaremos marcadores de Google
              markers: markers
            ),
         
            Visibility(visible: this.isShowInfo, child: MarkerInformation("Mi informacion", this.currentLocation,"assets/luna.png"))
          ]
        ),
        floatingActionButton: SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              overlayColor: Colors.black,
              overlayOpacity: 0.9,
              elevation: 8.0,
              children: [
                SpeedDialChild(
                  label: "Normal",
                  child: Icon(Icons.room),
                  onTap: ()=>setState(()=> mapType = MapType.normal)
                ),
                SpeedDialChild(
                  label: "Satelital",
                  child: Icon(Icons.satellite),
                  onTap: ()=>setState(()=> mapType = MapType.satellite)
                ),
                SpeedDialChild(
                  label: "Hibrido",
                  child: Icon(Icons.compare),
                  onTap: ()=>setState(()=> mapType = MapType.hybrid)
                ),
                SpeedDialChild(
                  label: "Terrenal",
                  child: Icon(Icons.terrain),
                  onTap: ()=>setState(()=> mapType = MapType.terrain)
                )
              ],
            ),
        
        

      );
    }
    onDragend(LatLng position){
      print("new position $position");
    }
  }
