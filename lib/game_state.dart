import 'package:equatable/equatable.dart';

abstract class GameState extends Equatable {
  bool isNeedToAnimate;
  int deletingCard;

  final List<int> userGameViewDeck;

  GameState(this.isNeedToAnimate, this.deletingCard, this.userGameViewDeck);

  @override
  List<Object> get props => [isNeedToAnimate, deletingCard, userGameViewDeck];
}

class InitialGameState extends GameState {
  InitialGameState() : super(false, null, null);
}

class GameDeckLoadedState extends GameState {
  GameDeckLoadedState(bool isNeedToAnimate, int deletingCard, List<int> userGameViewDeck) : super(isNeedToAnimate, deletingCard, userGameViewDeck);
}