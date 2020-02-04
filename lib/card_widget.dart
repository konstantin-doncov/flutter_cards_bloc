import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  final int id;

  const CardWidget({Key key, this.id}) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigoAccent,
      height: 300,
      child: Center(child: Text('${widget.id}', style: TextStyle(fontSize: 80),)),
    );
  }
}
