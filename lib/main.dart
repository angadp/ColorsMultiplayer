import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:quiver/async.dart';
import "dart:async";
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "IndieFlower"
      ),
      home: MyHomePage(title: 'Color match'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  List<dynamic> list =
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
  int score_a = 0;
  int score_b = 0;
  int _start = 10;
  int _current = 10;
  int setagain = 0;
  CountdownTimer countDownTimer;
  int _score = 0;
  var _colors;
  int bestScore_x = 0;
  int bestScore_y = 0;
  int showhint = 0;

  void startTimer() {
    countDownTimer = new CountdownTimer(
      new Duration(seconds: _start),
      new Duration(seconds: 1),
    );

    var sub = countDownTimer.listen(null);
    sub.onData((duration) {
      setState(() { _current = _start - duration.elapsed.inSeconds; });
    });

    if(turn == 0 && _current <= 1) {
      sub.onDone(() {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list[i][j] != -1) {
              update(i, j);
              return;
            }
          }
        }
      });
    }
  }

  @override
  void initState(){
    Random rand = new Random();
    int min = 0;
    int max = 4;
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin:0.0, end:1.0).animate(_animationController);

    WidgetsBinding.instance.addObserver(this);

    print("Called this");

    List<dynamic> newList = jsonDecode(jsonEncode(list));
    for (int i=0;i<10;i++) {
      for (int j=0;j<10;j++){
        newList[i][j] = min + rand.nextInt(max - min);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
  }

  int hintdfs()
  {
    print(bestScore_x);
    print(bestScore_y);
    setState(() {
      showhint = 1;
    });
  }

  void computermove()
  {
    update(bestScore_x, bestScore_y);
  }

  int dfs(int i, int j, int color, List<dynamic> li)
  {
    if(li[i][j] == color)
    {
      int val = 1;
      li[i][j] = -1;
      if(i-1>=0 && li[i-1][j]!=-1)
        val += dfs(i-1, j, color, li);
      if(i+1<=9 && li[i+1][j]!=-1)
        val += dfs(i+1, j, color, li);
      if(j-1>=0 && li[i][j-1]!=-1)
        val += dfs(i, j-1, color, li);
      if(j+1<=9 && li[i][j+1]!=-1)
        val += dfs(i, j+1, color, li);
      return val;
    }
    return 0;
  }

  void gravity(List<dynamic> li)
  {
    for(int i=9; i>=0; i--) {
      for(int j=9; j>=0; j--) {
        if(li[i][j] == -1) {
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

  update(int i, int j){
    List<dynamic> newlist = jsonDecode(jsonEncode(list));
    int a = score_a;
    int b = score_b;
    if(turn == 0) {
      a = score_a + dfs(i, j, newlist[i][j], newlist);
    }
    else {
      b = score_b + dfs(i, j, newlist[i][j], newlist);
    }
    gravity(newlist);

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
        list = newlist;
        setagain = 0;
        score_a = a;
        score_b = b;
        turn = updatedturn;
      });
    }
  }

  List<int> CalculateDP(List<dynamic> li, bool maxi, int level, int lvlscore, int alpa, int beta) {
    if (level == 0) {
      return [lvlscore, -1, -1];
    }
    Map dic = new Map<int, List<List<int>>>();
    List<dynamic> lvlarray = jsonDecode(jsonEncode(li));
    for(int i=0; i<10; i++)
    {
      for (int j=0; j<10; j++)
      {
        if(lvlarray[i][j]!=-1)
        {
          int val = dfs(i, j, lvlarray[i][j] ,lvlarray);
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
        int v = -100000000;
        int val_i = 0;
        int val_j = 0;
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
              var ji = dfs(value[0], value[1], temp[value[0]][value[1]], temp);
              gravity(temp);
              var score_to_add = key * key;
              var ret = CalculateDP(
                  temp, !maxi, level - 1, (lvlscore + score_to_add), alpa,
                  beta);
              if (v < ret[0]) {
                v = ret[0];
                val_i = value[0];
                val_j = value[1];
              }
              if (v >= beta) {
                return [v, val_i, val_j];
              }
              if (alpa > v) {
                alpa = alpa;
              }
              else {
                alpa = v;
              }
            }
          }
        }
        return [v, val_i, val_j];
      }
      else {
        int v = 100000000;
        int val_i = 0;
        int val_j = 0;
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
              var ji = dfs(value[0], value[1], temp[value[0]][value[1]], temp);
              gravity(temp);
              var score_to_add = key * key;
              var ret = CalculateDP(
                  temp, !maxi, level - 1, (lvlscore - score_to_add), alpa,
                  beta);
              if (v > ret[0]) {
                v = ret[0];
                val_i = value[0];
                val_j = value[1];
              }
              if (v <= alpa) {
                return [v, val_i, val_j];
              }
              if (beta > v) {
                beta = v;
              }
              else {
                beta = beta;
              }
            }
          }
        }
        return [v, val_i, val_j];
      }
    }
    else {
      return [lvlscore, -1, -1];
    }
  }

  Future runFutures() async {
    var futures = <Future>[];
    List<int> li = [];
    var thread = new Future(() async {
      await new Future.value();
      List<dynamic> io = jsonDecode(jsonEncode(list));
      li = CalculateDP(io, true, 3, 0, -100000000, 100000000);
    });
    futures.add(thread);
    await Future.wait(futures);
    bestScore_x = li[1];
    bestScore_y = li[2];
  }

  List<Widget> _createChildren() {
    List<Widget> colors = new List<Widget>();

    if(turn == 0) {
      if (setagain == 0) {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list[i][j] == -1) {
              colors.add(
                Container(color: Colors.white,),
              );
            }
            else if (list[i][j] == 0) {
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
                          Colors.yellow[700],
                          Colors.yellow[600],
                          Colors.yellow[500],
                          Colors.yellow[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 1) {
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
                          Colors.lightBlue[700],
                          Colors.lightBlue[600],
                          Colors.lightBlue[500],
                          Colors.lightBlue[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 2) {
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
                          Colors.red[700],
                          Colors.red[600],
                          Colors.red[500],
                          Colors.red[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 3) {
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
                          Colors.lightGreen[700],
                          Colors.lightGreen[600],
                          Colors.lightGreen[500],
                          Colors.lightGreen[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 4) {
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
                          Colors.purple[700],
                          Colors.purple[600],
                          Colors.purple[500],
                          Colors.purple[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 5) {
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
                          Colors.indigo[700],
                          Colors.indigo[600],
                          Colors.indigo[500],
                          Colors.indigo[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 6) {
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
                          Colors.orange[700],
                          Colors.orange[600],
                          Colors.orange[500],
                          Colors.orange[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 7) {
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
                          Colors.pink[700],
                          Colors.pink[600],
                          Colors.pink[500],
                          Colors.pink[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 8) {
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
                          Colors.brown[700],
                          Colors.brown[600],
                          Colors.brown[500],
                          Colors.brown[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 9) {
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
        WidgetsBinding.instance
            .addPostFrameCallback((_) => startTimer());
        setagain = 1;
        runFutures();
        _colors = colors;
        return colors;
      }
      else if (showhint == 1) {
        for (int i = 0; i < 10; i++) {
          for (int j = 0; j < 10; j++) {
            if (list[i][j] == -1) {
              colors.add(
                Container(color: Colors.white,),
              );
            }
            else if (list[i][j] == 0) {
              if (i != bestScore_x || j != bestScore_y) {
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
                            Colors.yellow[700],
                            Colors.yellow[600],
                            Colors.yellow[500],
                            Colors.yellow[400],
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
                      opacity: _animation,
                      child: Container(decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.topLeft,
                            stops: [0.1, 0.5, 0.7, 0.9],
                            colors: [
                              Colors.yellow[700],
                              Colors.yellow[600],
                              Colors.yellow[500],
                              Colors.yellow[400],
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
            else if (list[i][j] == 1) {
              if (i != bestScore_x || j != bestScore_y) {
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
                            Colors.lightBlue[700],
                            Colors.lightBlue[600],
                            Colors.lightBlue[500],
                            Colors.lightBlue[400],
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
                      opacity: _animation,
                      child: Container(decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.topLeft,
                            stops: [0.1, 0.5, 0.7, 0.9],
                            colors: [
                              Colors.lightBlue[700],
                              Colors.lightBlue[600],
                              Colors.lightBlue[500],
                              Colors.lightBlue[400],
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
            else if (list[i][j] == 2) {
              if (i != bestScore_x || j != bestScore_y) {
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
                            Colors.red[700],
                            Colors.red[600],
                            Colors.red[500],
                            Colors.red[400],
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
                      opacity: _animation,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.red[700],
                                Colors.red[600],
                                Colors.red[500],
                                Colors.red[400],
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
            else if (list[i][j] == 3) {
              if (i != bestScore_x || j != bestScore_y) {
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
                            Colors.lightGreen[700],
                            Colors.lightGreen[600],
                            Colors.lightGreen[500],
                            Colors.lightGreen[400],
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
                      opacity: _animation,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.lightGreen[700],
                                Colors.lightGreen[600],
                                Colors.lightGreen[500],
                                Colors.lightGreen[400],
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
            else if (list[i][j] == 4) {
              if (i != bestScore_x || j != bestScore_y) {
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
                            Colors.purple[700],
                            Colors.purple[600],
                            Colors.purple[500],
                            Colors.purple[400],
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
                      opacity: _animation,
                      child: Container(
                        decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.topLeft,
                              stops: [0.1, 0.5, 0.7, 0.9],
                              colors: [
                                Colors.purple[700],
                                Colors.purple[600],
                                Colors.purple[500],
                                Colors.purple[400],
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
            else if (list[i][j] == 5) {
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
                          Colors.indigo[700],
                          Colors.indigo[600],
                          Colors.indigo[500],
                          Colors.indigo[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 6) {
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
                          Colors.orange[700],
                          Colors.orange[600],
                          Colors.orange[500],
                          Colors.orange[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 7) {
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
                          Colors.pink[700],
                          Colors.pink[600],
                          Colors.pink[500],
                          Colors.pink[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 8) {
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
                          Colors.brown[700],
                          Colors.brown[600],
                          Colors.brown[500],
                          Colors.brown[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ));
            }
            else if (list[i][j] == 9) {
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
            if (list[i][j] == -1) {
              colors.add(
                Container(color: Colors.white,),
              );
            }
            else if (list[i][j] == 0) {
              colors.add(Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.yellow[700],
                          Colors.yellow[600],
                          Colors.yellow[500],
                          Colors.yellow[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list[i][j] == 1) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.lightBlue[700],
                          Colors.lightBlue[600],
                          Colors.lightBlue[500],
                          Colors.lightBlue[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list[i][j] == 2) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.red[700],
                          Colors.red[600],
                          Colors.red[500],
                          Colors.red[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list[i][j] == 3) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.lightGreen[700],
                          Colors.lightGreen[600],
                          Colors.lightGreen[500],
                          Colors.lightGreen[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list[i][j] == 4) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.purple[700],
                          Colors.purple[600],
                          Colors.purple[500],
                          Colors.purple[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list[i][j] == 5) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.indigo[700],
                          Colors.indigo[600],
                          Colors.indigo[500],
                          Colors.indigo[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ));
            }
            else if (list[i][j] == 6) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.orange[700],
                          Colors.orange[600],
                          Colors.orange[500],
                          Colors.orange[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
            else if (list[i][j] == 7) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.pink[700],
                          Colors.pink[600],
                          Colors.pink[500],
                          Colors.pink[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
            else if (list[i][j] == 8) {
              colors.add(
                Container(
                  decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.topLeft,
                        stops: [0.1, 0.5, 0.7, 0.9],
                        colors: [
                          Colors.brown[700],
                          Colors.brown[600],
                          Colors.brown[500],
                          Colors.brown[400],
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
              ));
            }
            else if (list[i][j] == 9) {
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
        WidgetsBinding.instance
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

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    if(turn == 0) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body:
          Column(
              children: <Widget>[
                Expanded(
                    child: GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(20),
                      crossAxisCount: 10,
                      children: _createChildren(),
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
                                    child: OutlineButton(
                                      onPressed: () {
                                        hintdfs();
                                      },
                                      borderSide: BorderSide(color: Colors
                                          .black),
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
                                    child: OutlineButton(
                                      onPressed: () {},
                                      borderSide: BorderSide(color: Colors
                                          .black),
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
                                    .height - appBar.preferredSize.height) / 4,
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
                                        "Angad",
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
                                        "Score: $score_a",
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
                )
              ]
          )
      );
    }
    else if (turn == 1){
        if(setagain == 0) {
          Timer(Duration(seconds: 3), () {
            computermove();
          });
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body:
          Column(
              children: <Widget>[
                Expanded(
                    child: GridView.count(
                      primary: false,
                      padding: const EdgeInsets.all(20),
                      crossAxisCount: 10,
                      children: _createChildren(),
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
                                    child: OutlineButton(
                                      onPressed: () {
                                        hintdfs();
                                      },
                                      borderSide: BorderSide(color: Colors
                                          .black),
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
                                    child: OutlineButton(
                                      onPressed: () {},
                                      borderSide: BorderSide(color: Colors
                                          .black),
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
                                    .height - appBar.preferredSize.height) / 4,
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
                                        "Computer",
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
                                        "Score: $score_b",
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
                )
              ]
          )
      );
    }
  }
}
