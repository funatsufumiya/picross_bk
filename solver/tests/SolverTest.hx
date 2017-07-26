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
        "{left: 0,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1],
              [Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 2,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2],
              [Filled,Cross,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 3,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2],
              [Cross,Filled,Cross,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 0,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [2,1],
              [Blank,Blank,Blank,Cross,Filled,Cross]
            ]
        )));

    assertEquals(
        "{left: 3,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,2,1],
              [Cross,Filled,Cross,Blank,Blank,Blank,Cross,Filled,Cross]
            ]
        )));

    assertEquals(
        "{left: 5,list: [Blank,Blank,Blank]}",
        Std.string( f(
            [
              [1,1,2],
              [Cross,Filled,Cross,Filled,Cross,Blank,Blank,Blank]
            ]
        )));

  }
}
