import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object> get props => [];
}

class DownloadGameDeckEvent extends GameEvent{

}

class UploadGameResponseEvent extends GameEvent{

}