class Main {
  static public function main(){
    var json = '{"columns":[[3,1],[1,1,1],[1,1,1],[1,1,1],[5]],"rows":[[5],[1,1],[5],[1],[5]]}';
    var solver = new Solver();
    solver.readFromJson(json);
    solver.solve();
  }
}
