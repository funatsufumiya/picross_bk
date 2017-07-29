import haxe.ds.Option;
import State.*;

using Lambda;
using ArrayHelper;
using StateHelper;

typedef ListWithOffset = { list: Array<State>, left: Int }
typedef ListWithOffsetAndNums = { list: Array<State>, left: Int, nums: Array<Int> }

class Solver {
  private var problem: Problem;
  private var matrix: Matrix; 
  private var width: Int;
  private var height: Int;
  private var step: Int;

  public function new(){
  }

  public function stepLog(row_or_column: String, index: Int, step: Int, message: String){
    trace("("+step+") "+"[" + row_or_column + " " + (index+1) + "] " + message);
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
    // trace("row: " + row.toVisualString());
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

  // 届かないセルに×をつけ、塗り部分を統合する
  private function calcUnreachableAndMergeFilled(_nums: Array<Int>, _list: Array<State>)
    : Array<State>
  {
    // 数が１つのときは、届かないセルにバツを付ける
    if(_nums.length == 1 && _list.hasBlank() && _list.hasFilled()){
      var list = _list.slice(0, _list.length);
      var left = list.mostLeftFilledIndex(); 
      var right = list.mostRightFilledIndex(); 
      var w = right - left + 1;

      // 塗られているセル数と、数字の差を計算
      var diff = _nums[0] - w;

      // 塗られているセルが分散していれば、間の空白を塗る
      for( i in left...(right+1) ){
        if(Type.enumEq(list[i], Blank)){
          list[i] = Filled;
        }
      }

      // 左の方の届かないセルに×をつける
      var c = 0;
      var i = left;
      while(--i >= 0){
        // trace("i: " + i);
        // trace("c: " + c);
        if(c >= diff){
          list[i] = Cross;
        }
        ++c;
      }

      // 右の方の届かないセルに×をつける
      var c = 0;
      var i = right;
      while(++i < list.length){
        // trace("i: " + i);
        // trace("c: " + c);
        if(c >= diff){
          list[i] = Cross;
        }
        ++c;
      }

      return list;
    
    // 数が２つ以上のとき
    }else{
      // TODO: 現状のアルゴリズムでは計算できない
      return _list;
    }

  }

  // Xによってリストを分割し、可能な限り×付けや塗りを行う
  private function splitByCrossAndFill(){
    var flag = false;
    var flag_line = false;

    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        var result = calcSplitByCrossAndFill(nums, row);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            flag_line = false;
            for( x in 0...width ){
              if( matrix.get(x,y) != list[x] ){
                matrix.set(x,y,list[x]);
                flag = true;
                flag_line = true;
              }
            }
            if(flag_line){
              step += 1;
              stepLog("row",y,step,"split by cross, and fill");
              trace("\n" + matrix.toString());
            }
            continue;
        }
      }
    }

    for( x in 0...width ){
      if(matrix.hasBlankInColumn(x)){
        var nums = problem.columns[x];
        var column = matrix.column(x);
        var result = calcSplitByCrossAndFill(nums, column);
        switch (result) {
          case None:
            continue;
          case Some(list):
            // trace("Some(list): " + list);
            flag_line = false;
            for( y in 0...height ){
              if( matrix.get(x,y) != list[y] ){
                matrix.set(x,y,list[y]);
                flag = true;
                flag_line = true;
              }
            }
            if(flag_line){
              step += 1;
              stepLog("col",x,step,"split by cross, and fill");
              trace("\n" + matrix.toString());
            }
            continue;
        }
      }
    }

    return flag;
  }

  // Xによってリストを分割し、可能な限り×付けや塗りを行って返す
  private function calcSplitByCrossAndFill(_nums: Array<Int>, _list: Array<State>)
    : Option<Array<State>> {

    // 分割
    var splitted = splitByCross(_list);
    // 塗りがあるブロックの数をカウント
    var filled_count = splitted.filter(function(lwo){
      return lwo.list.hasFilled();
    }).length;

    var list = _list.slice(0, _list.length);

    // 塗りのあるブロックの数 == 数字の数 ならば
    if( filled_count == _nums.length ){
      var filled_index = 0;
      for( i in 0...splitted.length ){
        var lwo = splitted[i];
        var left = lwo.left;
        var num = _nums[filled_index];

        // 塗りがあるブロックなら
        if( lwo.list.hasFilled() ){
          // そのブロックの共通部分を塗る
          var result = calcSharedArea([num], lwo.list);
          switch (result) {
            case None:
            case Some(ls):
              for( i in 0...ls.length ){
                list[left+i] = ls[i];
                lwo.list[i] = ls[i];
              }
          }

          // 到達しない部分に×をつけ、塗りを統合する
          var l = calcUnreachableAndMergeFilled([num], lwo.list);
          for( i in 0...l.length ){
            list[left+i] = l[i];
          }

          filled_index += 1;

        // 塗りのないブロックなら
        }else{
          // Xで埋める
          for( i in 0...lwo.list.length ){
            list[left+i] = Cross;
          }
        }
      }

      return Some(list);

    // 分割数 == 数字の数 ならば
    }else if( splitted.length == _nums.length ){
 
      // 数字と対応した分割かどうかチェック
      if( _nums.length > 1 ){
        for( i in 0...splitted.length ){
          // 対応していない (ブロックの幅 < 数字)
          if( splitted[i].list.length < _nums[i] ){
            return None;
          }
        }

        // ２つ以上の数字が入ってしまうブロックがないかチェック
        // FIXME: 本当にこれだけで十分な例外チェックになっているのか…

        var filt_sp = splitted.slice(0, splitted.length);
        var filt_nums = _nums.slice(0, _nums.length);

        while(true){
          if( filt_sp.length > 0 && filt_nums.length > 1){

            if( filt_sp[0].list.length
                >= filt_nums[0] + filt_nums[1] + 1 ){
              return None;
            }else{
              filt_sp = filt_sp.slice(1, filt_sp.length);
              filt_nums = filt_nums.slice(1, filt_nums.length);
              continue;
            }
            
            if( filt_sp[filt_sp.length-1].list.length
                >= filt_nums[filt_nums.length-1] + filt_nums[filt_nums.length-2] + 1){
              return None;
            }else{
              filt_sp = filt_sp.slice(0, filt_sp.length-1);
              filt_nums = filt_nums.slice(0, filt_nums.length-1);
              continue;
            }

          }else{
            break;
          }
        }

        var sum = filt_nums.fold(function(n, num){
          return n + num;
        }, 0);

        for( i in 0...filt_sp.length ){
          if( filt_sp[i].list.length > sum ){
            return None;
          }
        }
      }

      // チェック完了したら、塗り作業に入る

      for( i in 0...splitted.length ){
        var lwo = splitted[i];
        var left = lwo.left;
        var num = _nums[i];

        // それぞれの共通部分を塗る
        var result = calcSharedArea([num], lwo.list);
        switch (result) {
          case None:
          case Some(ls):
            for( i in 0...ls.length ){
              list[left+i] = ls[i];
              lwo.list[i] = ls[i];
            }
        }
        
        // 到達しない部分に×をつけ、塗りを統合する
        var l = calcUnreachableAndMergeFilled([num], lwo.list);
        for( i in 0...l.length ){
          // if(!Type.enumEq(list[left+i], l[i])){
            list[left+i] = l[i];
          // }
        }
      }

      return Some(list);
    }

    return None;
  }

  // Xによってリストを分割し、オフセットを付加して返す
  private function splitByCross(_list: Array<State>): Array<ListWithOffset> {
    var sh = simpleShrink(_list);
    var list = sh.list;
    var left = sh.left;

    var start = 0;
    var retList: Array<ListWithOffset> = [];
    var gr = list.toGroups();
    
    // inner functions
    function count(gr:Array<StateGroup>){
      var n = 0;
      for( sg in gr ){
        n += sg.getCount();
      }
      return n;
    }

    function ret(_gr:Array<StateGroup>, _ls:Array<State>, _start:Int, _end:Int){
      var edge_gr = _gr.slice(0,_start);
      var sub_gr = _gr.slice(0,_end+1);
      var _left = count(edge_gr);
      var len = count(sub_gr);
      return { left: left + _left, list: _ls.slice(_left, len) };
    }
    // End of inner functions

    for( i in 0...gr.length ){
      if(gr[i].isCrossGroup()){
        retList.push(ret(gr, list, start, i-1));
        start = i+1;
      }
    }

    retList.push(ret(gr, list, start, gr.length-1));

    return retList;
  }

  // 端から、確定しているセルを発見して×付けを行う
  private function smartCrossAndFill(): Bool {
    var flag = false;
    var flag_line = false;
    
    for( y in 0...height ){
      if(matrix.hasBlankInRow(y)){
        var nums = problem.rows[y];
        var row = matrix.row(y);
        var result = calcSmartCrossAndFill(nums, row);
        switch (result) {
          case None:
            continue;
          case Some(list):
            flag_line = false;
            for( x in 0...width ){
              if( matrix.get(x,y) != list[x] ){
                matrix.set(x,y,list[x]);
                flag = true;
                flag_line = true;
              }
            }
            if(flag_line){
              step += 1;
              stepLog("row",y,step,"smart cross and fill");
              trace("\n" + matrix.toString());
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
            flag_line = false;
            for( y in 0...height ){
              if( matrix.get(x,y) != list[y] ){
                matrix.set(x,y,list[y]);
                flag = true;
                flag_line = true;
              }
            }
            if(flag_line){
              step += 1;
              stepLog("col",x,step,"smart cross and fill");
              trace("\n" + matrix.toString());
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
    var list = _list.slice(0, _list.length);
    var orig_len = list.length;
    var result = _list.slice(0, _list.length);
    var nums = _nums.slice(0, _nums.length);
    var left = 0;
    var right = 0;
    var changed = false;
    var ret = function(){
      return if(changed) Some(result) else None;
    }
    
    while(true){
      var sh = simpleShrink(list, left);
      right = (_list.length - sh.list.length) - sh.left;
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

      // [OX__ を [__ に縮める
      if(
          gr[0].isFilledGroup()
          && gr[0].getCount() == first_num
          && gr[1].isCrossGroup()
        ){

        list = list.slice(first_num + 1, list.length);
        left += first_num + 1;
        nums = nums.slice(1, nums.length);
        continue;

      // __XO] を __] に縮める
      }else if(
          gr[gr_len-1].isFilledGroup()
          && gr[gr_len-1].getCount() == last_num
          && gr[gr_len-2].isCrossGroup()
        ){
        list = list.slice(0, list.length - last_num - 1);
        right += last_num + 1;
        nums = nums.slice(0, nums.length-1);
        continue;
      }

      // ==========

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

      // trace("_list: " + _list);
      // trace("list: " + list);

      changed = true;
    }
  }

  // 端の方の完成している数字のマスを検出し、その分縮めて返す
  private function smartShrink(_nums: Array<Int>, _list: Array<State>, left_offset = 0): ListWithOffsetAndNums {
    var list = _list.slice(0, _list.length);
    var nums = _nums.slice(0, _nums.length);
    var left = left_offset;

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
  private function simpleShrink(_list: Array<State>, left_offset = 0): ListWithOffset {
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
            step += 1;
            if(row.length == shrinked.list.length){
              stepLog("row",y,step,"smart shared area method");
            }else{
              stepLog("row",y,step,"smart shrinking shared area method");
            }
            trace("\n" + matrix.toString());
            flag = true;
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
              if( !Type.enumEq( matrix.get(x,y), list[y-left] ) ){
                matrix.set(x,y,list[y-left]);
              }
            }
            step += 1;
            if(column.length == shrinked.list.length){
              stepLog("col",x,step,"smart shared area method");
            }else{
              stepLog("col",x,step,"smart shrinking shared area method");
            }
            trace("\n" + matrix.toString());
            flag = true;
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
            step += 1;
            if(row.length == shrinked.list.length){
              stepLog("row",y,step,"simple shared area method");
            }else{
              stepLog("row",y,step,"simple shrinking shared area method");
            }
            trace("\n" + matrix.toString());
            flag = true;
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
            step += 1;
            if(column.length == shrinked.list.length){
              stepLog("col",x,step,"simple shared area method");
            }else{
              stepLog("col",x,step,"simple shrinking shared area method");
            }
            trace("\n" + matrix.toString());
            flag = true;
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
            step += 1;
            stepLog("row",y,step,"simple shared area method");
            trace("\n" + matrix.toString());
            flag = true;
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
            step += 1;
            stepLog("col",x,step,"simple shared area method");
            trace("\n" + matrix.toString());
            flag = true;
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
          stepLog("row",y,step,"numbers completed");
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
          stepLog("col",x,step,"numbers completed");
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
      splitByCrossAndFill();
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
