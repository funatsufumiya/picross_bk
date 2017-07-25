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
}
