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
