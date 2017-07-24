import haxe.unit.TestRunner;
import tests.*;

class Test {
  public static function main(){
    var r = new TestRunner();
    r.add(new SolverTest());

    r.run();
  }
}
