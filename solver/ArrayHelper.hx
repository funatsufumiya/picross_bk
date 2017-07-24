using Lambda;

class ArrayHelper {
  public static function max( arr:Array<Int> ){
    return arr.fold(function(max, n){
      if(max == null){
        return n;
      }
      if(n > max){
        return n;
      }else{
        return max;
      }
    }, null);
  }

  public static function eq( arr1:Array<Int>, arr2: Array<Int>){
    if( arr1.length != arr2.length){
      return false;
    }

    for( i in 0...arr1.length ){
      if(arr1[i] != arr2[i]){
        return false;
      }
    }

    return true;
  }
}
