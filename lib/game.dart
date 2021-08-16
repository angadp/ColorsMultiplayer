import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:quiver/async.dart';
import "dart:async";
import 'dart:convert';
import 'main.dart';

void game() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "IndieFlower"
      ),
      home: GamePage(title: 'Color match', difficulty: 1, colors: 4, name: "John Doe"),
    );
  }
}

// ignore: must_be_immutable
class GamePage extends StatefulWidget {
  int? difficulty;
  int? colors;
  String? name;

  GamePage({Key? key, this.title, this.difficulty, this.colors, this.name}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<GamePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  List<dynamic>? list =
  [
    [0,0,0,0,0,1,1,3,4,5],
    [3,1,4,2,5,6,2,2,5,6],
    [0,0,0,0,0,1,1,3,4,5],
    [3,1,4,2,5,6,2,2,5,6],
    [0,0,0,0,0,1,1,3,4,5],
    [3,1,4,2,5,6,2,2,5,6],
    [0,0,0,0,0,1,1,3,4,5],
    [3,1,4,2,5,6,2,2,5,6],
    [0,0,0,0,0,1,1,3,4,5],
    [3,1,4,2,5,6,2,2,5,6],
  ];

  int turn = 0;
  int scoreA = 0;
  int scoreB = 0;
  int _start = 10;
  int _current = 10;
  int setagain = 0;
  late CountdownTimer countDownTimer;
  var _colors;
  int? bestScoreX = 0;
  int? bestScoreY = 0;
  int showhint = 0;
  bool gameOver = false;

  void pass(){
    countDownTimer.cancel();

    if(setagain == 1) {
      int updatedturn = 0;
      if (turn == 0) {
        updatedturn = 1;
      }
      else {
        updatedturn = 0;
      }

      setState(() {
        setagain = 0;
        turn = updatedturn;
      });
    }
  }

  void startTimer() {
    countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    // ignore: cancel_subscriptions
    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() { _current = _start - duration.elapsed.inSeconds; });
    });

      sub.onDone(() {
      if(turn == 0 && _current <= 1) {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list![i][j] != -1) {
              update(i, j);
              return;
            }
          }
        }
      }
      });
  }

  @override
  void initState(){
    Random rand = new Random();
    int min = 0;
    int? max = widget.colors;
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin:0.0, end:1.0).animate(_animationController);

    WidgetsBinding.instance!.addObserver(this);

    List<dynamic>? newList = jsonDecode(jsonEncode(list));
    for (int i=0;i<10;i++) {
      for (int j=0;j<10;j++){
        newList![i][j] = min + rand.nextInt(max! - min);
      }
    }

    print(newList);

    setState(() {
      list = jsonDecode(jsonEncode(newList));
      setagain = 0;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
  }


  /* Hint Code */
  void hintdfs()
  {
    print(bestScoreX);
    print(bestScoreY);
    setState(() {
      showhint = 1;
    });
  }

  /* Computer Move */
  void computermove()
  {
    update(bestScoreX, bestScoreY);
  }

  int dfs(int i, int? j, int? color, List<dynamic> li)
  {
    if(li[i][j] == color)
    {
      int val = 1;
      li[i][j] = -1;
      if(i-1>=0 && li[i-1][j]!=-1)
        val += dfs(i-1, j, color, li);
      if(i+1<=9 && li[i+1][j]!=-1)
        val += dfs(i+1, j, color, li);
      if(j!-1>=0 && li[i][j-1]!=-1)
        val += dfs(i, j-1, color, li);
      if(j+1<=9 && li[i][j+1]!=-1)
        val += dfs(i, j+1, color, li);
      return val;
    }
    return 0;
  }

  void gravity(List<dynamic>? li)
  {
    for(int i=9; i>=0; i--) {
      for(int j=9; j>=0; j--) {
        if(li![i][j] == -1) {
          int k = i;
          while(k>=0) {
            if(li[k][j]!=-1) {
              li[i][j] = li[k][j];
              li[k][j] = -1;
              break;
            }
            k--;
          }
        }
      }
    }
  }

  update(int? i, int? j){
    List<dynamic>? newlist = jsonDecode(jsonEncode(list));
    int a = scoreA;
    int b = scoreB;
    if(turn == 0) {
      a = scoreA + dfs(i!, j, newlist![i][j], newlist);
    }
    else {
      b = scoreB + dfs(i!, j, newlist![i][j], newlist);
    }
    gravity(newlist);

    countDownTimer.cancel();

    bool movesleft = false;
    for(int i=0;i<10;i++){
      for(int j=0;j<10;j++){
        if(newlist[i][j]!=-1){
          movesleft = true;
          break;
        }
      }
      if(movesleft == true)
        break;
    }
    bool over = false;
    if(movesleft == false)
      over = true;

    if(setagain == 1) {
      int updatedturn = 0;
      if (turn == 0) {
        updatedturn = 1;
      }
      else {
        updatedturn = 0;
      }


      setState(() {
        list = newlist;
        setagain = 0;
        scoreA = a;
        scoreB = b;
        turn = updatedturn;
        gameOver = over;
      });
    }
  }

  /* Minimax function */
  List<int?> calculateDP(List<dynamic>? li, bool maxi, int level, int lvlScore, int? alpha, int? beta) {
    if (level == 0) {
      return [lvlScore, -1, -1];
    }
    Map dic = new Map<int, List<List<int>>>();
    List<dynamic>? lvlArray = jsonDecode(jsonEncode(li));
    for(int i=0; i<10; i++)
    {
      for (int j=0; j<10; j++)
      {
        if(lvlArray![i][j]!=-1)
        {
          int val = dfs(i, j, lvlArray[i][j] ,lvlArray);
          if(!dic.containsKey(val))
          {
            dic[val] = [[i, j]];
          }
          else {
            var prev = dic[val];
            prev.add([i, j]);
            dic[val] = prev;
          }
        }
      }
    }
    if(dic.length > 0)
    {
      if(maxi)
      {
        int? v = -100000000;
        int? valI = 0;
        int? valJ = 0;
        List keys = dic.keys.toList();
        keys.sort((k1, k2) {
          if(k1 > k2)
            return -1;
          if(k1 < k2)
            return 1;
          return 0;
        });
        for(var key in keys){
          for(var value in dic[key]){
            List<dynamic> temp = jsonDecode(jsonEncode(li));
            if(temp[value[0]][value[1]]!=-1) {
              dfs(value[0], value[1], temp[value[0]][value[1]], temp);
              gravity(temp);
              var scoreToAdd = key * key;
              var ret = calculateDP(
                  temp, !maxi, level - 1, lvlScore + scoreToAdd as int, alpha,
                  beta);
              if (v! < ret[0]!) {
                v = ret[0];
                valI = value[0];
                valJ = value[1];
              }
              if (v! >= beta!) {
                return [v, valI, valJ];
              }
              if (alpha! > v) {
                alpha = alpha;
              }
              else {
                alpha = v;
              }
            }
          }
        }
        return [v, valI, valJ];
      }
      else {
        int? v = 100000000;
        int? valI = 0;
        int? valJ = 0;
        List keys = dic.keys.toList();
        keys.sort((k1, k2) {
          if (k1 < k2)
            return -1;
          if (k1 > k2)
            return 1;
          return 0;
        });
        for (var key in keys) {
          for (var value in dic[key]) {
            List<dynamic> temp = jsonDecode(jsonEncode(li));
            if (temp[value[0]][value[1]] != -1) {
              dfs(value[0], value[1], temp[value[0]][value[1]], temp);
              gravity(temp);
              var scoreToAdd = key * key;
              var ret = calculateDP(
                  temp, !maxi, level - 1, lvlScore - scoreToAdd as int, alpha,
                  beta);
              if (v! > ret[0]!) {
                v = ret[0];
                valI = value[0];
                valJ = value[1];
              }
              if (v! <= alpha!) {
                return [v, valI, valJ];
              }
              if (beta! > v) {
                beta = v;
              }
              else {
                beta = beta;
              }
            }
          }
        }
        return [v, valI, valJ];
      }
    }
    else {
      return [lvlScore, -1, -1];
    }
  }

  Future runFutures() async {
    var futures = <Future>[];
    List<int?> li = [];
    var thread = new Future(() async {
      await new Future.value();
      List<dynamic>? io = jsonDecode(jsonEncode(list));
      li = calculateDP(io, true, 3, 0, -100000000, 100000000);
    });
    futures.add(thread);
    await Future.wait(futures);
    bestScoreX = li[1];
    bestScoreY = li[2];
  }

  List<Widget>? _createChildren() {
    List<Widget> colors = <Widget>[];
    if(turn == 0) {
      if (setagain == 0) {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list![i][j] == -1) {
              colors.add(
                Container(color: Colors.white,),
              );
            }
            else if (list![i][j] == 0) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.yellow[700]!,
                          Colors.yellow[600]!,
                          Colors.yellow[500]!,
                          Colors.yellow[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 1) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.lightBlue[700]!,
                          Colors.lightBlue[600]!,
                          Colors.lightBlue[500]!,
                          Colors.lightBlue[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 2) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.red[700]!,
                          Colors.red[600]!,
                          Colors.red[500]!,
                          Colors.red[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 3) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.lightGreen[700]!,
                          Colors.lightGreen[600]!,
                          Colors.lightGreen[500]!,
                          Colors.lightGreen[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 4) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.purple[700]!,
                          Colors.purple[600]!,
                          Colors.purple[500]!,
                          Colors.purple[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 5) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.indigo[700]!,
                          Colors.indigo[600]!,
                          Colors.indigo[500]!,
                          Colors.indigo[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 6) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.orange[700]!,
                          Colors.orange[600]!,
                          Colors.orange[500]!,
                          Colors.orange[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 7) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.pink[700]!,
                          Colors.pink[600]!,
                          Colors.pink[500]!,
                          Colors.pink[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 8) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.brown[700]!,
                          Colors.brown[600]!,
                          Colors.brown[500]!,
                          Colors.brown[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list![i][j] == 9) {
              colors.add(GestureDetector(
                onTap: () {
                  update(i, j);
                },
                child: Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.black87,
                          Colors.black54,
                          Colors.black45,
                          Colors.black38,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
          }
        }

        _start = 10;
        _current = 10;
        WidgetsBinding.instance!
            .addPostFrameCallback((_) => startTimer());
        setagain = 1;
        runFutures();
        _colors = colors;
        return colors;
      }
      else if (showhint == 1) {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list![i][j] == -1) {
              colors.add(
                Container(color: Colors.white,),
              );
            }
            else if (list![i][j] == 0) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.yellow[700]!,
                            Colors.yellow[600]!,
                            Colors.yellow[500]!,
                            Colors.yellow[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else {
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.topLeft,
                            stops: [0.1, 0.5, 0.7, 0.9],
                            colors: [
                              Colors.yellow[700]!,
                              Colors.yellow[600]!,
                              Colors.yellow[500]!,
                              Colors.yellow[400]!,
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 1) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.lightBlue[700]!,
                            Colors.lightBlue[600]!,
                            Colors.lightBlue[500]!,
                            Colors.lightBlue[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else {
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.topLeft,
                            stops: [0.1, 0.5, 0.7, 0.9],
                            colors: [
                              Colors.lightBlue[700]!,
                              Colors.lightBlue[600]!,
                              Colors.lightBlue[500]!,
                              Colors.lightBlue[400]!,
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 2) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.red[700]!,
                            Colors.red[600]!,
                            Colors.red[500]!,
                            Colors.red[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else {
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.red[700]!,
                                Colors.red[600]!,
                                Colors.red[500]!,
                                Colors.red[400]!,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 3) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.lightGreen[700]!,
                            Colors.lightGreen[600]!,
                            Colors.lightGreen[500]!,
                            Colors.lightGreen[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else {
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.lightGreen[700]!,
                                Colors.lightGreen[600]!,
                                Colors.lightGreen[500]!,
                                Colors.lightGreen[400]!,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 4) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.purple[700]!,
                            Colors.purple[600]!,
                            Colors.purple[500]!,
                            Colors.purple[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else {
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.purple[700]!,
                                Colors.purple[600]!,
                                Colors.purple[500]!,
                                Colors.purple[400]!,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 5) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.indigo[700]!,
                            Colors.indigo[600]!,
                            Colors.indigo[500]!,
                            Colors.indigo[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else{
                  colors.add(GestureDetector(
                      onTap: () {
                        update(i, j);
                      },
                      child: FadeTransition(
                        opacity: _animation as Animation<double>,
                        child: Container(
                          decoration: ShapeDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.topLeft,
                                stops: [0.1, 0.5, 0.7, 0.9],
                                colors: [
                                  Colors.indigo[700]!,
                                  Colors.indigo[600]!,
                                  Colors.indigo[500]!,
                                  Colors.indigo[400]!,
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )
                          ),
                        ),
                      )));
              }
            }
            else if (list![i][j] == 6) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.orange[700]!,
                            Colors.orange[600]!,
                            Colors.orange[500]!,
                            Colors.orange[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else{
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.orange[700]!,
                                Colors.orange[600]!,
                                Colors.orange[500]!,
                                Colors.orange[400]!,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 7) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.pink[700]!,
                            Colors.pink[600]!,
                            Colors.pink[500]!,
                            Colors.pink[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else{
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.pink[700]!,
                                Colors.pink[600]!,
                                Colors.pink[500]!,
                                Colors.pink[400]!,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 8) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.brown[700]!,
                            Colors.brown[600]!,
                            Colors.brown[500]!,
                            Colors.brown[400]!,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else{
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.brown[700]!,
                                Colors.brown[600]!,
                                Colors.brown[500]!,
                                Colors.brown[400]!,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
            else if (list![i][j] == 9) {
              if (i != bestScoreX || j != bestScoreY) {
                colors.add(GestureDetector(
                  onTap: () {
                    update(i, j);
                  },
                  child: Container(
                    decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.topLeft,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Colors.black87,
                            Colors.black54,
                            Colors.black45,
                            Colors.black38,
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                  ),
                ));
              }
              else{
                colors.add(GestureDetector(
                    onTap: () {
                      update(i, j);
                    },
                    child: FadeTransition(
                      opacity: _animation as Animation<double>,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.black87,
                                Colors.black54,
                                Colors.black45,
                                Colors.black38,
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            )
                        ),
                      ),
                    )));
              }
            }
          }
        }

        showhint = 0;
        _colors = colors;
        return colors;
      }
      else {
        return _colors;
      }
    }
    else{
      if (setagain == 0) {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list![i][j] == -1) {
              colors.add(
                Container(color: Colors.white,),
              );
            }
            else if (list![i][j] == 0) {
              colors.add(Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.yellow[700]!,
                          Colors.yellow[600]!,
                          Colors.yellow[500]!,
                          Colors.yellow[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list![i][j] == 1) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.lightBlue[700]!,
                          Colors.lightBlue[600]!,
                          Colors.lightBlue[500]!,
                          Colors.lightBlue[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list![i][j] == 2) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.red[700]!,
                          Colors.red[600]!,
                          Colors.red[500]!,
                          Colors.red[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list![i][j] == 3) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.lightGreen[700]!,
                          Colors.lightGreen[600]!,
                          Colors.lightGreen[500]!,
                          Colors.lightGreen[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list![i][j] == 4) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.purple[700]!,
                          Colors.purple[600]!,
                          Colors.purple[500]!,
                          Colors.purple[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list![i][j] == 5) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.indigo[700]!,
                          Colors.indigo[600]!,
                          Colors.indigo[500]!,
                          Colors.indigo[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list![i][j] == 6) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.orange[700]!,
                          Colors.orange[600]!,
                          Colors.orange[500]!,
                          Colors.orange[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
            else if (list![i][j] == 7) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.pink[700]!,
                          Colors.pink[600]!,
                          Colors.pink[500]!,
                          Colors.pink[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
            else if (list![i][j] == 8) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.brown[700]!,
                          Colors.brown[600]!,
                          Colors.brown[500]!,
                          Colors.brown[400]!,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
            else if (list![i][j] == 9) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.black87,
                          Colors.black54,
                          Colors.black45,
                          Colors.black38,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
          }
        }

        _start = 10;
        _current = 10;
        WidgetsBinding.instance!
            .addPostFrameCallback((_) => startTimer());
        setagain = 1;
        runFutures();
        _colors = colors;
        return colors;
      }
      else {
        return _colors;
      }
    }
  }

  createGameOverDialog(BuildContext context, String text){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Thank you for playing"),
        content: Column(
            children: <Widget>[
              Text(text),
              TextButton(
              onPressed: () {
//                var route = new MaterialphageRoute(
//                    builder: (BuildContext context){
//                      return new MyHomePage();
//                    });
//                Navigator.pop(context);
//                Navigator.of(context).push(route);
              },
              child: Text(
                "Ok",
              ))
            ]
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    var size = MediaQuery.of(context).size;

    final double itemHeight = (size.height/1.8 - 24) / 10;
    final double itemWidth = size.width / 10;

    if (gameOver == true) {
      if(scoreA > scoreB){
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.name!+ "'s Game"),
            ),
            body:
            Column(
                children: <Widget>[
                  Expanded(
                      child: GridView.count(
                        primary: false,
                        childAspectRatio: (itemWidth / itemHeight),
                        padding: const EdgeInsets.all(20),
                        crossAxisCount: 10,
                        children: _createChildren()!,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(2),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          hintdfs();
                                        },
                                        child: Text(
                                          "Hint",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          pass();
                                        },
                                        child: Text(
                                          "Pass",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                )
                              ]
                          )
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Container
                                  (
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/undraw_male_avatar.png')
                                  ),
                                  height: (MediaQuery
                                      .of(context)
                                      .size
                                      .height - appBar.preferredSize.height) /
                                      4,
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width - appBar.preferredSize.height) / 2,
                                ),
                                Column(
                                    children: <Widget>[
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          widget.name!,
                                          style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 12,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 2,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Score: $scoreA",
                                          style: TextStyle(
                                            fontSize: 30.0,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 12,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 2,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Time Left: " + "$_current",
                                          style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.red,
                                          ),),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 12,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 2,
                                      ),
                                    ]
                                )
                              ]
                          )
                      )
                  ),
                                    AlertDialog(
                                    title: Text("Thank you for playing"),
    content: Column(
    children: <Widget>[
    Text("You Won"),
      TextButton(
    onPressed: () {
                var route = new MaterialPageRoute(
                    builder: (BuildContext context){
                      return new MyHomePage();
                    });
                Navigator.pop(context);
                Navigator.of(context).push(route);
    },
    child: Text(
    "Ok",
    ))
    ]
    )
    )
                ]
            )
        );
      }
      else{
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.name!+ "'s Game"),
            ),
            body:
            Column(
                children: <Widget>[
                  Expanded(
                      child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(20),
                        childAspectRatio: (itemWidth / itemHeight),
                        crossAxisCount: 10,
                        children: _createChildren()!,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(2),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          hintdfs();
                                        },
                                        child: Text(
                                          "Hint",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          pass();
                                        },
                                        child: Text(
                                          "Pass",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                )
                              ]
                          )
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Container
                                  (
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/undraw_male_avatar.png')
                                  ),
                                  height: (MediaQuery
                                      .of(context)
                                      .size
                                      .height - appBar.preferredSize.height) /
                                      4,
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width - appBar.preferredSize.height) / 2,
                                ),
                                Column(
                                    children: <Widget>[
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          widget.name!,
                                          style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 12,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 2,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Score: $scoreA",
                                          style: TextStyle(
                                            fontSize: 30.0,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 12,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 2,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Time Left: " + "$_current",
                                          style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.red,
                                          ),),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 12,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 2,
                                      ),
                                    ]
                                )
                              ]
                          )
                      )
                  ),
                  AlertDialog(
                      title: Text("Thank you for playing"),
                      content: Column(
                          children: <Widget>[
                            Text("You Lost"),
                            TextButton(
                                onPressed: () {
                                  var route = new MaterialPageRoute(
                                      builder: (BuildContext context){
                                        return new MyHomePage();
                                      });
                                  Navigator.pop(context);
                                  Navigator.of(context).push(route);
                                },
                                child: Text(
                                  "Ok",
                                ))
                          ]
                      )
                  )
                ]
            )
        );
      }
    }
    if (turn == 0) {
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.name!+ "'s Game"),
            ),
            body:
            Column(
                children: <Widget>[
                  Expanded(
                      child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(20),
                        childAspectRatio: (itemWidth / itemHeight),
                        crossAxisCount: 10,
                        children: _createChildren()!,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(2),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          hintdfs();
                                        },
                                        child: Text(
                                          "Hint",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          pass();
                                        },
                                        child: Text(
                                          "Pass",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                )
                              ]
                          )
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Container
                                  (
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/undraw_male_avatar.png')
                                  ),
                                  height: (MediaQuery
                                      .of(context)
                                      .size
                                      .height - appBar.preferredSize.height) / 8,
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width - appBar.preferredSize.height) / 4,
                                ),
                                Column(
                                    children: <Widget>[
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          widget.name!,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Score: $scoreA",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),

                                    ]
                                ),
                                    Container
                                    (
                                    child: Image(
                                    image: AssetImage(
                                    'assets/images/undraw_computer.png')
                                    ),
                                    height: (MediaQuery
                                        .of(context)
                                        .size
                                        .height - appBar.preferredSize.height) / 8,
                                    width: (MediaQuery
                                        .of(context)
                                        .size
                                        .width - appBar.preferredSize.height) / 4,
                                    ),
                                Column(
                                    children: <Widget>[
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          'Computer',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Score: $scoreB",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),

                                    ]
                                ),
                              ]
                          )
                      )
                  ),Container
                    (
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      "Time Left: " + "$_current",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.red,
                      ),),
                    height: (MediaQuery
                        .of(context)
                        .size
                        .height -
                        appBar.preferredSize.height) / 12,
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width -
                        appBar.preferredSize.height) / 2,
                  ),
                ]
            )
        );
      }
      else if (turn == 1) {
        if (setagain == 0) {
          Timer(Duration(seconds: 3), () {
            computermove();
          });
        }
        return Scaffold(
            appBar: AppBar(
              title: Text(widget.name!+ "'s Game"),
            ),
            body:
            Column(
                children: <Widget>[
                  Expanded(
                      child: GridView.count(
                        primary: false,
                        padding: const EdgeInsets.all(20),
                        childAspectRatio: (itemWidth / itemHeight),
                        crossAxisCount: 10,
                        children: _createChildren()!,
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(2),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          hintdfs();
                                        },
                                        child: Text(
                                          "Hint",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, top: 2),
                                    child: Container(
                                      color: Colors.transparent,
                                      width: (MediaQuery
                                          .of(context)
                                          .size
                                          .width) / 2.4,
                                      height: 60,
                                      child: TextButton(
                                        onPressed: () {
                                          pass();
                                        },
                                        child: Text(
                                          "Pass",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'Raleway',
                                            fontSize: 22.0,
                                          ),
                                        ),
                                      ),
                                    )
                                )
                              ]
                          )
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: IntrinsicHeight(
                          child: Row(
                              children: <Widget>[
                                Container
                                  (
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/undraw_computer.png')
                                  ),
                                  height: (MediaQuery
                                      .of(context)
                                      .size
                                      .height - appBar.preferredSize.height) / 8,
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width - appBar.preferredSize.height) / 4,
                                ),
                                Column(
                                    children: <Widget>[
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          'Computer',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Score: $scoreB",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),

                                    ]
                                ),
                                Container
                                  (
                                  child: Image(
                                      image: AssetImage(
                                          'assets/images/undraw_male_avatar.png')
                                  ),
                                  height: (MediaQuery
                                      .of(context)
                                      .size
                                      .height - appBar.preferredSize.height) / 8,
                                  width: (MediaQuery
                                      .of(context)
                                      .size
                                      .width - appBar.preferredSize.height) / 4,
                                ),
                                Column(
                                    children: <Widget>[
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          widget.name!,
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),
                                      Container
                                        (
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          "Score: $scoreA",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                          ),
                                        ),
                                        height: (MediaQuery
                                            .of(context)
                                            .size
                                            .height -
                                            appBar.preferredSize.height) / 24,
                                        width: (MediaQuery
                                            .of(context)
                                            .size
                                            .width -
                                            appBar.preferredSize.height) / 4,
                                      ),

                                    ]
                                ),
                              ]
                          )
                      )
                  ),Container
                    (
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      "Time Left: " + "$_current",
                      style: TextStyle(
                        fontSize: 30.0,
                        color: Colors.red,
                      ),),
                    height: (MediaQuery
                        .of(context)
                        .size
                        .height -
                        appBar.preferredSize.height) / 12,
                    width: (MediaQuery
                        .of(context)
                        .size
                        .width -
                        appBar.preferredSize.height) / 2,
                  ),
                ]
            )
        );
      }
      return Container();
  }
}
