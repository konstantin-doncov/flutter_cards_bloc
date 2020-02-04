import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc.dart';

class GameBloc extends Bloc<GameEvent, GameState> {

  @override
  GameState get initialState => InitialGameState();

  @override
  Stream<GameState> mapEventToState(
    GameEvent event,
  ) async* {
    if(event is DownloadGameDeckEvent){

      final result = List.generate(10, (i) => i);

      yield GameDeckLoadedState(false, null, result);
    }
    else if(event is UploadGameResponseEvent){

      int deletingCard = state.userGameViewDeck.removeAt(0);
      yield GameDeckLoadedState(true, deletingCard, state.userGameViewDeck);

      if(state.userGameViewDeck.length < 3){

        final result = List.generate(10, (i) => i + state.userGameViewDeck.last + 1);

        result.insertAll(0, state.userGameViewDeck);
        await Future.delayed(Duration(milliseconds: 100));

        yield GameDeckLoadedState(state.isNeedToAnimate, state.deletingCard, result);

      }

    }
  }
}
