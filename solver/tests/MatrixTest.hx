package tests;

import haxe.unit.TestCase;
import State.*;

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
    assertEquals("[3]",
        Std.string(Reflect.callMethod(mat,
            Reflect.field(mat, "toNumbers"), [list])));
    var list2 = [Filled,Blank,Filled,Filled,Filled];
    assertEquals("[1,3]",
        Std.string(Reflect.callMethod(mat,
            Reflect.field(mat, "toNumbers"), [list2])));
    var list3 = [Filled,Filled,Blank,Filled,Filled];
    assertEquals("[2,2]",
        Std.string(Reflect.callMethod(mat,
            Reflect.field(mat, "toNumbers"), [list3])));
    var list4 = [Blank,Blank,Blank,Blank,Blank];
    assertEquals("[0]",
        Std.string(Reflect.callMethod(mat,
            Reflect.field(mat, "toNumbers"), [list4])));
  }
}
