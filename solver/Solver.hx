import haxe.ds.Option;
import State.*;

using Lambda;
using ArrayHelper;

class Solver {
  private var problem: Problem;
  private var matrix: Matrix; 
  private var width: Int;
  private var height: Int;

  public function new(){
  }

  public function readFromJson(json: String){
    this.problem = new Problem(json);
    this.width = problem.width;
    this.height = problem.height;

    trace("rows: " + problem.rows);
    trace("rowDepth: " + problem.rowDepth);
    trace("columns: " + problem.columns);
    trace("columnDepth: " + problem.columnDepth);
    trace("width: " + problem.width);
    trace("height: " + problem.height);
  }

  private function calcSimpleBoxes(len:Int, nums: Array<Int>, row: Array<State>)
    : Option<Array<State>>
  {
    var first_num = nums[0];
    var rest_nums = nums.slice(1, nums.length);
    var sum = rest_nums.fold(function(n, num){
      return n + num + 1;
    }, first_num);
    var max = nums.max();

    // trace("first_num: " + first_num);
    // trace("rest_nums: " + rest_nums);
    // trace("nums: " + nums);
    // trace("sum: " + sum);
    // trace("--");

    if(len - sum < max){
      // Apply simple boxes

      var dots = row.slice(0, row.length-1);
      var rest_len = len;
      var n = null;

      for( i in 0...nums.length ){
        var id = nums.length - i - 1;
        if(i > 0){
          sum -= (n + 1);
          rest_len -= (n + 1);
        }
        n = nums[id];

        var diff_edge = rest_len - sum;
        var diff_num = n - diff_edge;

        // trace("n: " + n);
        // trace("sum: " + sum);
        // trace("rest_len: " + rest_len);
        // trace("diff_edge: " + diff_edge);
        // trace("diff_num: " + diff_num);

        if(diff_num > 0){
          for( j in (rest_len-n)...(rest_len) ){
            dots[j] = Filled;
          }
        }
      }

      // 新たに変更があればOK、なければ失敗
      for( i in 0...len ){
        if(!Type.enumEq(row[i], dots[i])){
          return Some(dots);
        }
      }

      return None;

    }else{
      // Not applied
      return None;
    }

  }

  private function simpleBoxes(): Bool {
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        var result = calcSimpleBoxes(width, nums, row);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( x in 0...width ){
              matrix.set(x,y,list[x]);
            }
            return true;
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column = matrix.column(x);
        var result = calcSimpleBoxes(height, nums, column);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( y in 0...height ){
              matrix.set(x,y,list[y]);
            }
            return true;
        }
      }
    }

    return false;
  }

  private function checkAndCross(){
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row_nums = matrix.rowToNumbers(y);

        // trace(matrix.row(y));
        // trace(row_nums);

        if(nums.eq(row_nums)){
          matrix.rowReplaceBlankToCross(y);
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column_nums = matrix.columnToNumbers(x);
        if(nums.eq(column_nums)){
          matrix.columnReplaceBlankToCross(x);
        }
      }
    }
  }

  public function solve(): Option<Matrix>{
    matrix = new Matrix(width, height);

    var step = 0;
    while(matrix.hasBlank()){
      checkAndCross();
      if(!simpleBoxes()){
        trace("失敗 (" + step + " steps)");
        return None; // 失敗
      }
      trace("\n" + matrix.toString());

      step += 1;
    }

    trace("成功 (" + step + " steps)");
    return Some(matrix); // 成功
  }
}
