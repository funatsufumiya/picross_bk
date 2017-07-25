import haxe.ds.Option;
import State.*;

using Lambda;
using ArrayHelper;

typedef ShrinkedList = { list: Array<State>, left: Int }

class Solver {
  private var problem: Problem;
  private var matrix: Matrix; 
  private var width: Int;
  private var height: Int;
  private var step: Int;

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

  private function calcSharedArea(nums: Array<Int>, row: Array<State>)
    : Option<Array<State>>
  {
    // Noneを返す場合は変更なし、Someを返す場合は変更あり
    
    // 数字が 0 ならばスキップ
    if(nums.length == 1 && nums[0] == 0){
      return None;
    }

    var len = row.length;
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

      var dots = row.slice(0, row.length);
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
        var fill_first = sum - diff_num;
        var fill_last = sum;

        // trace("n: " + n);
        // trace("sum: " + sum);

        // trace("rest_len: " + rest_len);
        // trace("diff_edge: " + diff_edge);
        // trace("diff_num: " + diff_num);

        // trace("fill_first: " + fill_first);
        // trace("fill_last: " + fill_last);

        // fill_first から fill_last までを共通部分として塗りつぶす
        if(diff_num > 0){
          for( j in fill_first...fill_last ){
            dots[j] = Filled;
          }
          // trace("dots: " + dots);
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

  private function simpleShrink(row: Array<State>): ShrinkedList {
    var list = row;
    var left = 0;

    while(true){
      if(list.length == 0){
        return {list: list, left: 0};
      }

      if(Type.enumEq(list[0], Cross)){
        list = list.slice(1,list.length);
        left += 1;
      }else if(Type.enumEq(list[list.length-1], Cross)){
        list = list.slice(0,list.length-1);
      }else{
        return {list: list, left: left};
      }
    }
  }

  private function simpleShrinkingSharedAreaMethod(): Bool {
    var flag = false;
    
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        // trace("before shrink: " + row);
        var shrinked = simpleShrink(row);
        var left = shrinked.left;
        // trace("after shrink: " + shrinked.list);
        if(!shrinked.list.hasBlank()){
          continue;
        }
        var result = calcSharedArea(nums, shrinked.list);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( x in left...(shrinked.list.length + left) ){
              matrix.set(x,y,list[x-left]);
            }
            if(row.length == shrinked.list.length){
              trace("[row "+y+"] simple shared area method");
            }else{
              trace("[row "+y+"] simple shrinking shared area method");
            }
            trace("\n" + matrix.toString());
            flag = true;
            step += 1;
            continue;
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column = matrix.column(x);
        var shrinked = simpleShrink(column);
        var left = shrinked.left;
        if(!shrinked.list.hasBlank()){
          continue;
        }
        var result = calcSharedArea(nums, shrinked.list);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( y in left...(list.length + left) ){
              matrix.set(x,y,list[y-left]);
            }
            if(column.length == shrinked.list.length){
              trace("[col "+x+"] simple shared area method");
            }else{
              trace("[col "+x+"] simple shrinking shared area method");
            }
            trace("\n" + matrix.toString());
            flag = true;
            step += 1;
            // trace("nums: "+nums);
            // trace("column: "+column);
            // trace("shrinked: "+shrinked);
            // trace("list: "+list);
            // trace("shrinked.list.length: "+shrinked.list.length);
            // trace("list.length: "+list.length);
            continue;
        }
      }
    }

    return flag;
  }

  private function simpleSharedAreaMethod(): Bool {
    var flag = false;
    
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        var result = calcSharedArea(nums, row);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( x in 0...width ){
              matrix.set(x,y,list[x]);
            }
            trace("[row "+y+"] simple shared area method");
            trace("\n" + matrix.toString());
            flag = true;
            step += 1;
            continue;
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column = matrix.column(x);
        var result = calcSharedArea(nums, column);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( y in 0...height ){
              matrix.set(x,y,list[y]);
            }
            trace("[col "+x+"] simple shared area method");
            trace("\n" + matrix.toString());
            flag = true;
            step += 1;
            continue;
        }
      }
    }

    return flag;
  }

  private function checkFixedAndCross(){
    var flag = false;

    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row_nums = matrix.rowToNumbers(y);

        // trace(matrix.row(y));
        // trace(row_nums);

        if(nums.eq(row_nums)){
          // trace("eq: " + nums + " / " + row_nums);
          flag = true;
          step += 1;
          matrix.rowReplaceBlankToCross(y);
          trace("[row "+y+"] numbers completed");
          trace("\n" + matrix.toString());
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column_nums = matrix.columnToNumbers(x);
        if(nums.eq(column_nums)){
          // trace("eq: " + nums + " / " + column_nums);
          flag = true;
          step += 1;
          matrix.columnReplaceBlankToCross(x);
          trace("[col "+x+"] numbers completed");
          trace("\n" + matrix.toString());
        }
      }
    }

    return flag;
  }

  public function solve(): Option<Matrix>{
    matrix = new Matrix(width, height);

    step = 0;
    while(matrix.hasBlank()){
      if(
          !simpleShrinkingSharedAreaMethod()
          && !checkFixedAndCross()
        ){
        trace("失敗 (" + step + " steps)");
        trace("rows: " + problem.rows);
        trace("columns: " + problem.columns);
        return None; // 失敗
      }
      // trace("\n" + matrix.toString());
    }

    trace("成功 (" + step + " steps)");
    return Some(matrix); // 成功
  }
}
