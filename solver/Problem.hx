import haxe.Json;

using Lambda;
using ArrayHelper;

class Problem {
  public var rows: Array<Array<Int>>;
  public var columns: Array<Array<Int>>;
  public var rowDepth: Int;
  public var columnDepth: Int;
  public var width: Int;
  public var height: Int;

  private function getDepth(nums_list: Array<Array<Int>>){
    return nums_list.map(function(v){
      return v.length;
    }).max();
  }

  public function new(json:String){
    var problem = Json.parse(json);
    this.rows = problem.rows;
    this.columns = problem.columns;
    this.rowDepth = this.getDepth(this.rows);
    this.columnDepth = this.getDepth(this.columns);
    this.width = this.columns.length;
    this.height = this.rows.length;
  }
}
