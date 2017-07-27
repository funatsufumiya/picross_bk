import haxe.ds.Option;
import State.*;

using Lambda;
using ArrayHelper;
using StateHelper;

typedef ShrinkedList = { list: Array<State>, left: Int }
typedef SmartShrinkedList = { list: Array<State>, left: Int, nums: Array<Int> }

class Solver {
  private var problem: Problem;
  private var matrix: Matrix; 
  private var width: Int;
  private var height: Int;
  private var step: Int;

  public function new(){
  }

  // 問題をJSONから読み込む
  public function readFromJson(json: String){
    this.problem = new Problem(json);
    this.width = problem.width;
    this.height = problem.height;

    // trace("rows: " + problem.rows);
    // trace("rowDepth: " + problem.rowDepth);
    // trace("columns: " + problem.columns);
    // trace("columnDepth: " + problem.columnDepth);
    // trace("width: " + problem.width);
    // trace("height: " + problem.height);
  }

  // 行・列の共通部分を実際に計算する関数
  // 変更があった場合は、Some([...])で計算結果を返す
  // 変更がなかった場合はNoneを返す
  private function calcSharedArea(nums: Array<Int>, row: Array<State>)
    : Option<Array<State>>
  {
    // 数列が空であればスキップ
    if(nums.length == 0){
      return None;
    }

    // 数列が [0] ならばスキップ
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

  // 端から、確定しているセルを発見して×付けを行う
  private function smartCrossAndFill(): Bool {
    var flag = false;
    
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        var result = calcSmartCrossAndFill(nums, row);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( x in 0...width ){
              if( matrix.get(x,y) != list[x] ){
                matrix.set(x,y,list[x]);
                flag = true;
              }
            }
            if(flag){
              trace("[row "+y+"] smart cross and fill");
              trace("\n" + matrix.toString());
              step += 1;
            }
            continue;
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column = matrix.column(x);
        var result = calcSmartCrossAndFill(nums, column);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( y in 0...height ){
              if( matrix.get(x,y) != list[y] ){
                matrix.set(x,y,list[y]);
                flag = true;
              }
            }
            if(flag){
              trace("[col "+x+"] smart cross and fill");
              trace("\n" + matrix.toString());
              step += 1;
            }
            continue;
        }
      }
    }

    return flag;
  }

  // [O___ を [OX__ に置換する
  // 変更があった場合は、Some([...])で計算結果を返す
  // 変更がなかった場合はNoneを返す
  private function calcSmartCrossAndFill(_nums: Array<Int>, _list: Array<State>)
    : Option<Array<State>>
  {
    var list = _list;
    var orig_len = list.length;
    var result = _list;
    var nums = _nums;
    var left = 0;
    var right = 0;
    var changed = false;
    var ret = function(){
      return if(changed) Some(result) else None;
    }

    while(true){
      var sh = simpleShrink(list, left);
      right += (list.length - sh.list.length) - sh.left;
      list = sh.list;
      left = sh.left;

      if(list.length == 0 || nums.length == 0){
        return ret();
      }

      var gr = list.toGroups();
      if(gr.length < 2){
        return ret();
      }

      var gr_len = gr.length;
      var first_num = nums[0];
      var last_num = nums[nums.length-1];

      // [O___ を [OX__ に置換する
      if(
          gr[0].isFilledGroup()
          && gr[0].getCount() == first_num
          && gr[1].isBlankGroup()
        ){

        result[left+first_num] = Cross;
        list = list.slice(first_num + 1, list.length);
        left += first_num + 1;
        nums = nums.slice(1, nums.length);
        // nums.shift();

      // [_O___ を [XOX__ に置換する
      }else if(
          gr.length > 2
          && gr[0].isBlankGroup()
          && gr[0].getCount() <= first_num
          && gr[1].isFilledGroup()
          && gr[1].getCount() == first_num
          && gr[2].isBlankGroup()
        ){

        var edge_count = gr[0].getCount();
        for( i in left...(left+edge_count) ){
          result[i] = Cross;
        }
        result[left + edge_count + first_num] = Cross;
        list = list.slice(first_num + edge_count + 1, list.length);
        left += first_num + edge_count + 1;
        nums = nums.slice(1, nums.length);
        // nums.shift();

      // [_X___ を [XX___ に置換する
      }else if(
          gr[0].isBlankGroup()
          && gr[0].getCount() < first_num
          && gr[1].isCrossGroup()
        ){

        var edge_count = gr[0].getCount();
        for( i in left...(left+edge_count) ){
          result[i] = Cross;
        }
        list = list.slice(edge_count + 1, list.length);
        left += edge_count + 1;
        nums = nums.slice(1, nums.length);
        // nums.shift();

      // ___O] を __XO] に置換する
      }else if(
          gr[gr_len-1].isFilledGroup()
          && gr[gr_len-1].getCount() == last_num
          && gr[gr_len-2].isBlankGroup()
        ){

        result[orig_len - 1 - right - last_num] = Cross;
        list = list.slice(0, list.length - last_num - 1);
        right += last_num + 1;
        nums = nums.slice(0, nums.length-1);
        // nums.pop();

      // ___O_] を __XOX] に置換する
      }else if(
          gr.length > 2
          && gr[gr_len-1].isBlankGroup()
          && gr[gr_len-1].getCount() <= last_num
          && gr[gr_len-2].isFilledGroup()
          && gr[gr_len-2].getCount() == last_num
          && gr[gr_len-3].isBlankGroup()
        ){

        var edge_count = gr[gr_len-1].getCount();
        for( i in (orig_len - right - edge_count)...(orig_len - right) ){
          result[i] = Cross;
        }
        result[orig_len - 1 - right - last_num - edge_count] = Cross;
        list = list.slice(0, list.length - last_num - edge_count - 1);
        right += last_num + edge_count + 1;
        nums = nums.slice(0, nums.length-1);
        // nums.shift();

      // ___X_] を ___XX] に置換する
      }else if(
          gr[gr_len-1].isBlankGroup()
          && gr[gr_len-1].getCount() < last_num
          && gr[gr_len-2].isCrossGroup()
        ){

        var edge_count = gr[gr_len-1].getCount();
        for( i in (orig_len - right - edge_count)...(orig_len - right) ){
          result[i] = Cross;
        }
        result[orig_len - right - edge_count] = Cross;
        list = list.slice(0, list.length - edge_count - 1);
        right += edge_count + 1;
        nums = nums.slice(0, nums.length-1);
        // nums.shift();

      }else{
        return ret();
      }

      changed = true;
    }
  }

  // 端の方の完成している数字のマスを検出し、その分縮めて返す
  private function smartShrink(_nums: Array<Int>, _list: Array<State>): SmartShrinkedList {
    var list = _list;
    var nums = _nums;
    var left = 0;

    while(true){
      var sh = simpleShrink(list, left);
      list = sh.list;
      left = sh.left;

      if(list.length == 0 || nums.length == 0){
        return {list: list, left: left, nums: nums};
      }

      var gr = list.toGroups();
      if(gr.length < 2){
        return {list: list, left: left, nums: nums};
      }

      var gr_len = gr.length;
      var first_num = nums[0];
      var last_num = nums[nums.length-1];

      // [OX__ を [__ に短縮する
      if(
          gr[0].isFilledGroup()
          && gr[0].getCount() == first_num
          && gr[1].isCrossGroup()
        ){

        var cross_count = gr[1].getCount();
        list = list.slice(first_num + cross_count, list.length);
        left = left + first_num + cross_count;
        nums = nums.slice(1, nums.length);
        // nums.shift();

      // __XO] を __] に短縮する
      }else if(
          gr[gr_len-1].isFilledGroup()
          && gr[gr_len-1].getCount() == last_num
          && gr[gr_len-2].isCrossGroup()
        ){

        var cross_count = gr[gr_len-2].getCount();
        list = list.slice(0, list.length - last_num - cross_count);
        // left = left;
        nums = nums.slice(0, nums.length-1);
        // nums.pop();

      }else{
        return {list: list, left: left, nums: nums};
      }
    }
  }

  // 両端にある×を検出し、その分を縮小して返す。
  // 左(上)からどれだけ縮小されたかを、left、結果をlistに格納する。
  private function simpleShrink(_list: Array<State>, left_offset = 0): ShrinkedList {
    var list = _list;
    var left = left_offset;

    while(true){
      if(list.length == 0){
        return {list: list, left: left};
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

  // 端から確定したセルの分だけ縮小、×付けを行い、行・列の数字の共通部分を塗りつぶす
  // 変更があった場合は true, なかった場合は false を返す
  private function smartShrinkingSharedAreaMethod(): Bool {
    var flag = false;
    
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        // ここで一度行を縮小する
        var shrinked = smartShrink(nums, row);
        var left = shrinked.left;
        // if(!shrinked.list.hasBlank()){
        //   continue;
        // }
        // 共通部分を計算
        var result = calcSharedArea(shrinked.nums, shrinked.list);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // 共通部分の塗りを実際に反映する
            for( x in left...(shrinked.list.length + left) ){
              matrix.set(x,y,list[x-left]);
            }
            if(row.length == shrinked.list.length){
              trace("[row "+y+"] smart shared area method");
            }else{
              trace("[row "+y+"] smart shrinking shared area method");
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
        var shrinked = smartShrink(nums, column);
        var left = shrinked.left;
        // if(!shrinked.list.hasBlank()){
        //   continue;
        // }
        var result = calcSharedArea(shrinked.nums, shrinked.list);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            for( y in left...(list.length + left) ){
              matrix.set(x,y,list[y-left]);
            }
            if(column.length == shrinked.list.length){
              trace("[col "+x+"] smart shared area method");
            }else{
              trace("[col "+x+"] smart shrinking shared area method");
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

  // 端にある×の分だけ縮小し、行・列の数字の共通部分を塗りつぶす
  // 変更があった場合は true, なかった場合は false を返す
  private function simpleShrinkingSharedAreaMethod(): Bool {
    var flag = false;
    
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        // ここで一度行を縮小する
        var shrinked = simpleShrink(row);
        var left = shrinked.left;
        // if(!shrinked.list.hasBlank()){
        //   continue;
        // }
        // 共通部分を計算
        var result = calcSharedArea(nums, shrinked.list);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // 共通部分の塗りを実際に反映する
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
        // if(!shrinked.list.hasBlank()){
        //   continue;
        // }
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

  // 行・列の数字の共通部分を塗りつぶす
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

  private function isCompleted(){
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        return false;
      }
    }

    for( x in 0...height ){
      if(matrix.hasBlankInColumn(x)){
        return false;
      }
    }

    return true;
  }

  // 数字が完成している行・列を検出して、空白を×に置き換える
  private function checkFixedAndCross(){
    var flag = false;

    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        // セルの並びを数列に変換する
        var row_nums = matrix.rowToNumbers(y);

        // trace(matrix.row(y));
        // trace(row_nums);

        // 問題の数列と、セルの数列が一致すれば
        if(nums.eq(row_nums)){
          // trace("eq: " + nums + " / " + row_nums);
          flag = true;
          step += 1;
          // 空白を×に置き換える
          matrix.rowReplaceBlankToCross(y);
          trace("[row "+y+"] numbers completed");
          trace("\n" + matrix.toString());
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        // セルの並びを数列に変換する
        var column_nums = matrix.columnToNumbers(x);
        // 問題の数列と、セルの数列が一致すれば
        if(nums.eq(column_nums)){
          // trace("eq: " + nums + " / " + column_nums);
          flag = true;
          step += 1;
          // 空白を×に置き換える
          matrix.columnReplaceBlankToCross(x);
          trace("[col "+x+"] numbers completed");
          trace("\n" + matrix.toString());
        }
      }
    }

    return flag;
  }

  // // 問題を解く(単純法)
  // public function solveSimple(): Option<Matrix>{
  //   matrix = new Matrix(width, height);
  //
  //   step = 0;
  //   while(matrix.hasBlank()){
  //     if(
  //         !simpleShrinkingSharedAreaMethod()
  //         && !checkFixedAndCross()
  //       ){
  //       trace("失敗 (" + step + " steps)");
  //       trace("rows: " + problem.rows);
  //       trace("columns: " + problem.columns);
  //       return None; // 失敗
  //     }
  //     // trace("\n" + matrix.toString());
  //   }
  //
  //   trace("成功 (" + step + " steps)");
  //   return Some(matrix); // 成功
  // }

  // 問題を解く
  public function solve(): Option<Matrix>{
    matrix = new Matrix(width, height);

    step = 0;
    while(matrix.hasBlank()){

      matrix.isChanged = false;

      smartShrinkingSharedAreaMethod();
      smartCrossAndFill();
      checkFixedAndCross();

      if( isCompleted() ){
        break;
      }

      if( matrix.isChanged == false ){
        trace("失敗 (" + step + " steps)");
        trace("rows: " + problem.rows);
        trace("columns: " + problem.columns);
        return None; // 失敗
      }

      // trace("\n" + matrix.toString());
    }

    trace("成功 (" + step + " steps)");
    trace("\n" + matrix.toString());
    return Some(matrix); // 成功
  }
}
