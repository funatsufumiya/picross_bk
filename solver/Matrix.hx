import State.*;

using Lambda;

class Matrix {

  private var matrix: Array<Array<State>>;
  private var width: Int;
  private var height: Int;

  public function new(width: Int, height: Int){
    this.width = width;
    this.height = height;
    this.matrix = [];
    for( y in 0...height ){
      var row = [];
      for( x in 0...width ){
        row.push(Blank);
      } 
      this.matrix.push(row);
    }
  }

  public function get(x:Int, y:Int){
    return matrix[y][x];
  }

  public function set(x:Int, y:Int, v:State){
    return matrix[y][x] = v;
  }

  public function row(y:Int){
    return matrix[y];
  }

  public function column(x:Int){
    return [for (y in 0...height) matrix[y][x]];
  }

  private function toNumbers(list:Array<State>){
    var nums = [];
    var n = 0;
    for( i in 0...list.length ){
      var state = list[i];
      if(Type.enumEq(state, Blank) || Type.enumEq(state, Cross)){
        if(n > 0){
          nums.push(n);
          n = 0;
        }
      }else{
        n += 1;
      }
    }

    if(n > 0){
      nums.push(n);
    }
    
    if(nums.length == 0){
      return [0];
    }else{
      return nums;
    }
  }

  public function rowReplaceBlankToCross(y:Int){
    for( x in 0...width ){
      if(Type.enumEq(matrix[y][x], Blank)){
        matrix[y][x] = Cross;
      }
    }
  }

  public function columnReplaceBlankToCross(x:Int){
    for( y in 0...height ){
      if(Type.enumEq(matrix[y][x], Blank)){
        matrix[y][x] = Cross;
      }
    }
  }

  public function rowToNumbers(y:Int){
    return toNumbers(this.row(y));
  }

  public function columnToNumbers(x:Int){
    return toNumbers(this.column(x));
  }

  public function hasBlank(){
    for( y in 0...height ){
      for( x in 0...width ){
        if(Type.enumEq(matrix[y][x], Blank)){
          return true;
        }
      } 
    }

    return false;
  }

  public function hasBlankInRow(y){
    for( x in 0...width ){
      if(Type.enumEq(matrix[y][x], Blank)){
        return true;
      }
    }

    return false;
  }

  public function hasBlankInColumn(x){
    for( y in 0...height ){
      if(Type.enumEq(matrix[y][x], Blank)){
        return true;
      }
    }

    return false;
  }

  public function toString(){
    return this.matrix.map(function(row){
      row.map(function(v){
        switch v {
          case Blank:
            return "_";
          case Filled:
            return "#";
          case Cross:
            return "/";
        }
      }).join("");
    }).join("\n");
  }
}
