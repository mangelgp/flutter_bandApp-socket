import 'dart:io';

import 'package:band_names/src/models/band.dart';
import 'package:band_names/src/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = []; 

  @override
  void initState() { 

    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('bands', (payload){
      this.bands = (payload as List).map( (band) => Band.fromMap(band) ).toList();
      setState(() {});
      print(payload);
    });
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('BandNames', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: socketService.serverStatus == ServerStatus.Online?
              Icon(Icons.check_circle, color: Colors.blue[300]) :
              Icon(Icons.offline_bolt, color: Colors.red)
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => _bandTile(bands[index]),
        itemCount: bands.length,
      ), 
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBand,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
      },
      background: Container(
        padding: EdgeInsets.only(left: 15.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete, color: Colors.white),
        )
      ),
      key: Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}'),
        onTap: () {
          print(band.name);
          socketService.socket.emit('vote-band', { 'id': band.id } );
        },
      ),
    );
  }

  _addNewBand() {

    final textController = new TextEditingController();

    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New BandName'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                textColor: Colors.blue,
                onPressed: () => _addBandName(textController.text)
              )
            ],
          );
        }
      );
    }

    showCupertinoDialog(
      context: context, 
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('New Band Name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => _addBandName(textController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );
  }

  void _addBandName(String name) {

    print(name);

    if (name.length > 1) {
      //agregar banda
      this.bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    } 

    Navigator.pop(context);
  }
}