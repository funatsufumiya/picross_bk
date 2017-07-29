package tests;

import haxe.unit.TestCase;
import State.*;

class SolverTest extends TestCase {
  public function test_calcSharedArea(){
    var solver = new Solver();
    var f = Reflect.callMethod.bind(solver,Reflect.field(solver,"calcSharedArea"),_);

    assertEquals(
        "Some([Filled,Filled,Filled,Filled,Filled])",
        Std.string(f(
            [
              [5],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Filled,Filled,Filled,Blank])",
        Std.string(f(
            [
              [4],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Filled,Blank,Blank])",
        Std.string(f(
            [
              [3],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Filled,Blank,Filled,Filled])",
        Std.string(f(
            [
              [2,2],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Filled,Blank,Blank,Blank])",
        Std.string(f(
            [
              [2,1],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Filled,Filled,Blank,Blank,Blank,Filled,Blank,Blank])",
        Std.string(f(
            [
              [4,3],
              [Blank,Blank,Blank,Blank,Blank
              ,Blank,Blank,Blank,Blank,Blank]
            ]
        )));
  }

  public function test_simpleShrink(){
    var solver = new Solver();
    var f = Reflect.callMethod.bind(solver,Reflect.field(solver, "simpleShrink"),_);

    assertEquals(
        "{left: 0,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 1,list: [Blank,Blank]}",
        Std.string( f(
            [
              [Cross,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 1,list: [Blank,Blank]}",
        Std.string( f(
            [
              [Cross,Blank,Blank,Cross]
            ]
        )));

    assertEquals(
        "{left: 2,list: [Blank,Blank]}",
        Std.string( f(
            [
              [Cross,Cross,Blank,Blank,Cross,Cross,Cross]
            ]
        )));

  }

  public function test_smartShrink(){
    var solver = new Solver();
    var f = Reflect.callMethod.bind(solver,Reflect.field(solver, "smartShrink"),_);

    assertEquals(
        "{nums: [1],left: 0,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1],
              [Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{nums: [2],left: 2,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2],
              [Filled,Cross,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{nums: [2],left: 3,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2],
              [Cross,Filled,Cross,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{nums: [2],left: 0,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [2,1],
              [Blank,Blank,Blank,Cross,Filled,Cross]
            ]
        )));

    assertEquals(
        "{nums: [2],left: 3,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2,1],
              [Cross,Filled,Cross,Blank,Blank,Blank,Cross,Filled,Cross]
            ]
        )));

    assertEquals(
        "{nums: [2],left: 5,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,1,2],
              [Cross,Filled,Cross,Filled,Cross,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{nums: [2],left: 6,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2,2],
              [Cross,Filled,Cross,Filled,Filled,Cross,Blank,Blank,Blank]
            ]
        )));

  }

  public function test_smartCrossAndFill(){
    var solver = new Solver();
    var f = Reflect.callMethod.bind(solver,Reflect.field(solver, "calcSmartCrossAndFill"),_);
  
    assertEquals(
        "Some([Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2],
              [Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Cross,Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2],
              [Cross,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Cross,Filled,Filled])",
        Std.string( f(
            [
              [1,2],
              [Blank,Blank,Blank,Blank,Filled,Filled]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Cross,Filled,Filled,Cross])",
        Std.string( f(
            [
              [1,2],
              [Blank,Blank,Blank,Blank,Filled,Filled,Cross]
            ]
        )));

    assertEquals(
        "Some([Cross,Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2],
              [Blank,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "None",
        Std.string( f(
            [
              [1,2],
              [Blank,Blank,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Cross,Cross,Filled,Filled,Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [3,2],
              [Blank,Blank,Filled,Filled,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Cross,Filled,Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2,3],
              [Filled,Blank,Filled,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Cross,Filled,Cross])",
        Std.string( f(
            [
              [1],
              [Blank,Blank,Blank,Filled,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Cross,Filled,Filled,Cross,Filled,Cross])",
        Std.string( f(
            [
              [3,2,1],
              [Blank,Blank,Blank,Blank,Filled,Filled,Blank,Filled,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Cross,Cross,Filled,Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2,3],
              [Filled,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Cross,Cross,Cross,Filled,Filled,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2,3],
              [Filled,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Cross,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Blank])",
        Std.string( f(
            [
              [1,2,3],
              [Filled,Blank,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Cross,Filled,Filled,Cross,Cross,Filled,Cross])",
        Std.string( f(
            [
              [3,2,1],
              [Blank,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Filled,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Cross,Filled,Filled,Cross,Cross,Cross,Filled,Cross])",
        Std.string( f(
            [
              [3,2,1],
              [Blank,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Filled,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Cross,Filled,Cross])",
        Std.string( f(
            [
              [3,2,1],
              [Blank,Blank,Blank,Blank,Filled,Filled,Blank,Blank,Blank,Blank,Filled,Blank]
            ]
        )));

    assertEquals(
        "Some([Cross,Cross,Cross,Blank,Blank,Blank])",
        Std.string( f(
            [
              [2,2],
              [Cross,Blank,Cross,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Blank,Cross,Cross,Cross])",
        Std.string( f(
            [
              [2,2],
              [Blank,Blank,Blank,Cross,Blank,Cross]
            ]
        )));

    assertEquals(
        "Some([Cross,Filled,Filled,Filled,Filled,Filled,Filled,Filled,Filled,Cross,Cross,Cross,Cross,Cross,Cross])",
        Std.string( f(
            [
              [8],
              [Cross,Filled,Filled,Filled,Filled,
              Filled,Filled,Filled,Filled,Cross,
              Cross,Cross,Cross,Blank,Cross]
            ]
        )));
  }

  public function test_splitByCross(){
    var solver = new Solver();
    var f = Reflect.callMethod.bind(solver,Reflect.field(solver, "splitByCross"),_);

    assertEquals(
        "[{left: 0,list: [Blank,Blank]}]",
        Std.string( f(
            [
              [Blank,Blank]
            ]
        )));

    assertEquals(
        "[{left: 0,list: [Blank,Blank,Filled]}]",
        Std.string( f(
            [
              [Blank,Blank,Filled]
            ]
        )));

    assertEquals(
        "[{left: 0,list: [Blank,Blank]},{left: 3,list: [Blank,Blank]}]",
        Std.string( f(
            [
              [Blank,Blank,Cross,Blank,Blank]
            ]
        )));

    assertEquals(
        "[{left: 0,list: [Blank,Blank]},{left: 5,list: [Blank,Blank]}]",
        Std.string( f(
            [
              [Blank,Blank,Cross,Cross,Cross,Blank,Blank]
            ]
        )));

    assertEquals(
        "[{left: 1,list: [Blank,Blank]},{left: 6,list: [Blank,Blank]}]",
        Std.string( f(
            [
              [Cross,Blank,Blank,Cross,Cross,Cross,Blank,Blank,Cross]
            ]
        )));

    assertEquals(
        "[{left: 1,list: [Blank,Filled]},{left: 4,list: [Blank]},{left: 6,list: [Blank,Blank]}]",
        Std.string( f(
            [
              [Cross,Blank,Filled,Cross,Blank,Cross,Blank,Blank,Cross]
            ]
        )));
  }


  public function test_calcSplitByCrossAndFill(){
    var solver = new Solver();
    var f = Reflect.callMethod.bind(solver,Reflect.field(solver, "calcSplitByCrossAndFill"),_);

    assertEquals(
        "Some([Filled,Filled,Cross,Filled,Filled])",
        Std.string( f(
            [
              [2,2],
              [Blank,Blank,Cross,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Cross,Cross,Cross,Cross,Blank,Filled,Filled,Blank])",
        Std.string( f(
            [
              [3],
              [Blank,Blank,Blank,Cross,Blank,Blank,Filled,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Filled,Cross,Cross,Cross,Cross,Filled,Filled])",
        Std.string( f(
            [
              [2,2],
              [Blank,Filled,Cross,Blank,Blank,Cross,Filled,Blank]
            ]
        )));

  }

}
