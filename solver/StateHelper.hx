import StateGroup.*;

class StateHelper {
  public static function toGroup(state:State, n:Int): StateGroup {
    return switch(state){
      case Blank:
        BlankGroup(n);
      case Filled:
        FilledGroup(n);
      case Cross:
        CrossGroup(n);
    }
  }

  public static function toGroups(list:Array<State>): Array<StateGroup>{
    return Matrix.toGroups(list);
  }

  public static function toNumbers(list:Array<State>): Array<Int>{
    return Matrix.toNumbers(list);
  }

  public static function toVisualString(list:Array<State>): String {
    return list.map(function(state){
      return switch(state){
        case Blank: "_";
        case Filled: "#";
        case Cross: "/";
      }
    }).join("");
  }

  public static function hasBlank(list:Array<State>): Bool {
    for( s in list ){
      if( Type.enumEq(s, Blank) ){
        return true;
      }
    }
    return false;
  }

  public static function hasFilled(list:Array<State>): Bool {
    for( s in list ){
      if( Type.enumEq(s, Filled) ){
        return true;
      }
    }
    return false;
  }

  public static function mostLeftFilledIndex(list:Array<State>): Int {
    for( i in 0...list.length ){
      if( Type.enumEq(list[i], Filled) ){
        return i;
      }
    }
    return -1;
  }

  public static function mostRightFilledIndex(list:Array<State>): Int {
    var i = list.length;
    while(--i >= 0){
      if( Type.enumEq(list[i], Filled) ){
        return i;
      }
    }
    return -1;
  }

  public static function isFilledGroup(s:StateGroup){
    return switch s {
      case FilledGroup(_):
        true;
      case _:
        false;
    }
  }

  public static function isCrossGroup(s:StateGroup){
    return switch s {
      case CrossGroup(_):
        true;
      case _:
        false;
    }
  }

  public static function isBlankGroup(s:StateGroup){
    return switch s {
      case BlankGroup(_):
        true;
      case _:
        false;
    }
  }

  public static function getCount(s:StateGroup){
    return switch s {
      case BlankGroup(n):
        return n;
      case CrossGroup(n):
        return n;
      case FilledGroup(n):
        return n;
    }
  }
}
