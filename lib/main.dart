import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cards/card_widget.dart';

import 'game_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text('Game'),
          ),
          body: BlocProvider(
            create: (context) =>
                GameBloc(),
            child: Column(
              children: <Widget>[
                GamePage(),
              ],
            ),
          ),
        )
    );
  }
}


List<Alignment> cardsAlign = [ new Alignment(0.0, 1.0), new Alignment(0.0, 0.8), new Alignment(0.0, 0.0) ];
List<Size> cardsSize = new List(3);

class GamePage extends StatefulWidget
{

  @override
  _GamePageState createState() => new _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin
{

  GameBloc _gameBloc;

  AnimationController _controller;

  final Alignment defaultFrontCardAlign = new Alignment(0.0, 0.0);
  Alignment frontCardAlign;
  double frontCardRot = 0.0;

  @override
  Widget build(BuildContext context) {

    cardsSize[0] = new Size(MediaQuery.of(context).size.width * 0.9, MediaQuery.of(context).size.height * 0.85);
    cardsSize[1] = new Size(MediaQuery.of(context).size.width * 0.85, MediaQuery.of(context).size.height * 0.80);
    cardsSize[2] = new Size(MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.height * 0.75);

    return buildBody();
  }


  @override
  void initState()
  {
    super.initState();

    frontCardAlign = cardsAlign[2];

    // Init the animation controller
    _controller = new AnimationController(duration: new Duration(milliseconds: 700), vsync: this);
    _controller.addListener(() => setState(() {}));


    _gameBloc = BlocProvider.of<GameBloc>(context);
    _gameBloc.add(DownloadGameDeckEvent());
  }



  Widget buildBody() {
    return BlocBuilder<GameBloc, GameState>(

        builder: (context, state,) {
          if (state is InitialGameState) {
            return Center(
              child: Text('Initializing...'),
            );
          }
          else if(state is GameDeckLoadedState){

            if(state.isNeedToAnimate) {
              state.isNeedToAnimate = false;

              WidgetsBinding.instance.addPostFrameCallback((_) {
                animateSwipeCards(state);
              });
            }

            return buildGame(state);
          }
          else {
            return Container();
          }
        }
    );
  }

  Widget buildGame(GameState state)
  {

    List<int> visibleCards = List();

    int i = 0;

    if(state.deletingCard != null)
      visibleCards.add(state.deletingCard);
    else if(state.userGameViewDeck.length >= 1)
      visibleCards.add(state.userGameViewDeck[i++]);

    if(state.userGameViewDeck.length >= 2)
      visibleCards.add(state.userGameViewDeck[i++]);
    if(state.userGameViewDeck.length >= 3)
      visibleCards.add(state.userGameViewDeck[i++]);



    return new Expanded
      (
        child: new Stack
          (
          children: <Widget>
          [
            if(visibleCards.length >= 3)
              backCard(visibleCards[2]),
            if(visibleCards.length >= 2)
              middleCard(visibleCards[1]),
            if(visibleCards.length >= 1)
              frontCard(visibleCards[0]),
            // Prevent swiping if the cards are animating
            _controller.status != AnimationStatus.forward ? new SizedBox.expand
              (
                child: new GestureDetector
                  (
                  // While dragging the first card
                  onPanUpdate: (DragUpdateDetails details)
                  {
                    // Add what the user swiped in the last frame to the alignment of the card
                    setState(()
                    {
                      // 20 is the "speed" at which moves the card
                      frontCardAlign = new Alignment
                        (
                          frontCardAlign.x + 20 * details.delta.dx / MediaQuery.of(context).size.width,
                          0
                      );

                      frontCardRot = frontCardAlign.x*1.5; // * rotation speed;
                    });
                  },
                  // When releasing the first card
                  onPanEnd: (_)
                  {
                    // If the front card was swiped far enough to count as swiped
                    if(frontCardAlign.x > 5.0)
                    {
                      _gameBloc.add(UploadGameResponseEvent());
                    }
                    else if(frontCardAlign.x < -5.0){
                      _gameBloc.add(UploadGameResponseEvent());
                    }
                    else
                    {
                      // Return to the initial rotation and alignment
                      setState(()
                      {
                        frontCardAlign = defaultFrontCardAlign;
                        frontCardRot = 0.0;
                      });
                    }
                  },
                )
            ) : new Container(),
          ],
        )
    );
  }

  void animateSwipeCards(GameState state)
  {
    print('animation started');

    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();

    print('animation stoped');

    void updateViewsAfterAnimation(AnimationStatus status){
      if(status == AnimationStatus.completed) {
        print('Game card id# ${state.deletingCard}');
        state.deletingCard = null;
        print('is now null');
        print('${state.userGameViewDeck.length}');
        frontCardAlign = defaultFrontCardAlign;
        frontCardRot = 0.0;

        _controller.removeStatusListener(updateViewsAfterAnimation);
      }
    }

    _controller.addStatusListener(updateViewsAfterAnimation);
  }

  Widget backCard(int id)
  {
    return new Align
      (
      alignment: _controller.status == AnimationStatus.forward ? CardsAnimation.backCardAlignmentAnim(_controller).value : cardsAlign[0],
      child: new SizedBox.fromSize
        (
          size: _controller.status == AnimationStatus.forward ? CardsAnimation.backCardSizeAnim(_controller).value : cardsSize[2],
          child: CardWidget(id: id)
      ),
    );
  }

  Widget middleCard(int id)
  {
    return new Align
      (
      alignment: _controller.status == AnimationStatus.forward ? CardsAnimation.middleCardAlignmentAnim(_controller).value : cardsAlign[1],
      child: new SizedBox.fromSize
        (
          size: _controller.status == AnimationStatus.forward ? CardsAnimation.middleCardSizeAnim(_controller).value : cardsSize[1],
          child: CardWidget(id: id)
      ),
    );
  }

  Widget frontCard(int id)
  {
    return new Align
      (
        alignment: _controller.status == AnimationStatus.forward ? CardsAnimation.frontCardDisappearAlignmentAnim(_controller, frontCardAlign).value : frontCardAlign,
        child: new Transform.rotate
          (
          angle: (pi / 180.0) * frontCardRot,
          child: new SizedBox.fromSize
            (
              size: cardsSize[0],
              child: CardWidget(id: id)
          ),
        )
    );
  }
}

class CardsAnimation
{
  static Animation<Alignment> backCardAlignmentAnim(AnimationController parent)
  {
    return new AlignmentTween
      (
        begin: cardsAlign[0],
        end: cardsAlign[1]
    ).animate
      (
        new CurvedAnimation
          (
            parent: parent,
            curve: new Interval(0.4, 0.7, curve: Curves.easeIn)
        )
    );
  }

  static Animation<Size> backCardSizeAnim(AnimationController parent)
  {
    return new SizeTween
      (
        begin: cardsSize[2],
        end: cardsSize[1]
    ).animate
      (
        new CurvedAnimation
          (
            parent: parent,
            curve: new Interval(0.4, 0.7, curve: Curves.easeIn)
        )
    );
  }

  static Animation<Alignment> middleCardAlignmentAnim(AnimationController parent)
  {
    return new AlignmentTween
      (
        begin: cardsAlign[1],
        end: cardsAlign[2]
    ).animate
      (
        new CurvedAnimation
          (
            parent: parent,
            curve: new Interval(0.2, 0.5, curve: Curves.easeIn)
        )
    );
  }

  static Animation<Size> middleCardSizeAnim(AnimationController parent)
  {
    return new SizeTween
      (
        begin: cardsSize[1],
        end: cardsSize[0]
    ).animate
      (
        new CurvedAnimation
          (
            parent: parent,
            curve: new Interval(0.2, 0.5, curve: Curves.easeIn)
        )
    );
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(AnimationController parent, Alignment beginAlign)
  {
    return new AlignmentTween
      (
        begin: beginAlign,
        end: new Alignment(beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0, 0.0) // Has swiped to the left or right?
    ).animate
      (
        new CurvedAnimation
          (
            parent: parent,
            curve: new Interval(0.0, 0.5, curve: Curves.easeIn)
        )
    );
  }
}
