package tests;

import haxe.unit.TestCase;
import State.*;

class SolverTest extends TestCase {
  public function test_calcSharedArea(){
    var solver = new Solver();

    assertEquals(
        "Some([Filled,Filled,Filled,Filled,Filled])",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "calcSharedArea"),
            [
              [5],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Filled,Filled,Filled,Blank])",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "calcSharedArea"),
            [
              [4],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Filled,Blank,Blank])",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "calcSharedArea"),
            [
              [3],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Filled,Filled,Blank,Filled,Filled])",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "calcSharedArea"),
            [
              [2,2],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Filled,Blank,Blank,Blank])",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "calcSharedArea"),
            [
              [2,1],
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "Some([Blank,Blank,Filled,Filled,Blank,Blank,Blank,Filled,Blank,Blank])",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "calcSharedArea"),
            [
              [4,3],
              [Blank,Blank,Blank,Blank,Blank
              ,Blank,Blank,Blank,Blank,Blank]
            ]
        )));
  }

  public function test_simpleShrink(){
    var solver = new Solver();

    assertEquals(
        "{left: 0,list: [Blank,Blank,Blank]}",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "simpleShrink"),
            [
              [Blank,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 1,list: [Blank,Blank]}",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "simpleShrink"),
            [
              [Cross,Blank,Blank]
            ]
        )));

    assertEquals(
        "{left: 1,list: [Blank,Blank]}",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "simpleShrink"),
            [
              [Cross,Blank,Blank,Cross]
            ]
        )));

    assertEquals(
        "{left: 2,list: [Blank,Blank]}",
        Std.string(Reflect.callMethod(solver,
            Reflect.field(solver, "simpleShrink"),
            [
              [Cross,Cross,Blank,Blank,Cross,Cross,Cross]
            ]
        )));

  }
}
