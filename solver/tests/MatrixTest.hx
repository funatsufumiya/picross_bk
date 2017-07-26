package tests;

import haxe.unit.TestCase;
import State.*;
import StateGroup.*;

class MatrixTest extends TestCase {
  public function test_width_height(){
    var mat = new Matrix(5,10);
    assertEquals(5, Reflect.getProperty(mat, "width"));
    assertEquals(10, Reflect.getProperty(mat, "height"));
  }

  public function test_set_and_get(){
    var mat = new Matrix(2,2);
    assertEquals("Blank", Std.string(mat.get(0,0)));
    assertEquals("Blank", Std.string(mat.get(1,0)));
    assertEquals("Blank", Std.string(mat.get(0,1)));
    assertEquals("Blank", Std.string(mat.get(1,1)));
    mat.set(0,0,State.Filled);
    mat.set(1,0,State.Filled);
    assertEquals("Filled", Std.string(mat.get(0,0)));
    assertEquals("Filled", Std.string(mat.get(1,0)));
    assertEquals("Blank", Std.string(mat.get(0,1)));
    assertEquals("Blank", Std.string(mat.get(1,1)));
  }

  public function test_row(){
    var mat = new Matrix(5,5);
    assertEquals("[Blank,Blank,Blank,Blank,Blank]", Std.string(mat.row(0)));
    mat.set(0,0,Filled);
    assertEquals("[Filled,Blank,Blank,Blank,Blank]", Std.string(mat.row(0)));
  }

  public function test_column(){
    var mat = new Matrix(5,5);
    assertEquals("[Blank,Blank,Blank,Blank,Blank]", Std.string(mat.column(0)));
    mat.set(0,1,Filled);
    assertEquals("[Blank,Filled,Blank,Blank,Blank]", Std.string(mat.column(0)));
  }

  public function test_toNumbers(){
    var mat = new Matrix(5,5);
    var list = [Filled,Filled,Filled,Blank,Blank];
    var f = function(v){ return Matrix.toNumbers(v[0]); };
    assertEquals("[3]",
        Std.string(f([list])));
    var list2 = [Filled,Blank,Filled,Filled,Filled];
    assertEquals("[1,3]",
        Std.string(f([list2])));
    var list3 = [Filled,Filled,Blank,Filled,Filled];
    assertEquals("[2,2]",
        Std.string(f([list3])));
    var list4 = [Blank,Blank,Blank,Blank,Blank];
    assertEquals("[0]",
        Std.string(f([list4])));
  }

  public function test_rowToNumbers_columnToNumbers(){
    var mat = new Matrix(5,5);
    mat.set(0,1,Filled);
    mat.set(0,2,Filled);
    assertEquals("[0]", Std.string(mat.rowToNumbers(0)));
    assertEquals("[1]", Std.string(mat.rowToNumbers(1)));
    assertEquals("[1]", Std.string(mat.rowToNumbers(2)));
    assertEquals("[2]", Std.string(mat.columnToNumbers(0)));
    assertEquals("[0]", Std.string(mat.columnToNumbers(1)));
    mat.set(0,4,Filled);
    assertEquals("[2,1]", Std.string(mat.columnToNumbers(0)));
  }

  public function test_toGroups(){
    var mat = new Matrix(5,5);
    var f = function(v){ return Matrix.toGroups(v[0]); };

    assertEquals("[BlankGroup(5)]",
        Std.string(f(
            [
              [Blank,Blank,Blank,Blank,Blank]
            ]
        )));

    assertEquals("[FilledGroup(3),BlankGroup(2)]",
        Std.string(f(
            [
              [Filled,Filled,Filled,Blank,Blank]
            ]
        )));

    assertEquals("[CrossGroup(1),FilledGroup(3),BlankGroup(2),CrossGroup(2)]",
        Std.string(f(
            [
              [Cross,Filled,Filled,Filled,Blank,Blank,Cross,Cross]
            ]
        )));
  }
  
  public function test_rowToGroup_columnToGroup(){
    var mat = new Matrix(5,5);
    mat.set(0,1,Filled);
    mat.set(0,2,Filled);
    assertEquals("[BlankGroup(5)]", Std.string(mat.rowToGroup(0)));
    assertEquals("[FilledGroup(1),BlankGroup(4)]", Std.string(mat.rowToGroup(1)));
    assertEquals("[BlankGroup(1),FilledGroup(2),BlankGroup(2)]", Std.string(mat.columnToGroup(0)));
    assertEquals("[BlankGroup(5)]", Std.string(mat.columnToGroup(1)));
  }
}
