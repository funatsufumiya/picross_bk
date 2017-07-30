class Main {
  static public function main(){
    // var json = '{"columns":[[3,1],[1,1,1],[1,1,1],[1,1,1],[5]],"rows":[[5],[1,1],[5],[1],[5]]}'; // 9
    // var json = '{"columns":[[5],[1],[2],[1],[5]],"rows":[[1,1],[1,1,1],[1,1,1],[2,2],[1,1]]}'; // W
    // var json = '{"columns":[[8],[7],[6],[6],[7],[7],[7],[2,3],[1,1],[1]],"rows":[[2],[3],[5],[7],[8],[10],[7],[1,5],[4],[4]]}';
    // var json = '{"columns":[[2],[4],[6],[8],[10],[10],[8],[6],[4],[2]],"rows":[[2],[2],[4],[4],[6],[6],[8],[8],[10],[10]]}'; // Triangle
    // var json = '{"columns":[[0],[2],[4],[3,5],[3,5],[3,5],[3,5],[3,5],[8],[7],[6],[11],[11],[11],[0]],"rows":[[0],[11],[11],[11],[6],[7],[8],[5,3],[5,3],[5,3],[5,3],[5,3],[4],[2],[0]]}'; // Arrow
    // var json = '{"columns":[[0],[6],[11],[2,7],[2,14],[2,4,6],[2,3,8],[7,5],[7,4],[5,10],[16],[16],[16],[16],[15],[14],[13],[11],[7],[0]],"rows":[[0],[5],[6],[3,4],[14],[17],[18],[2,2,2,9],[2,1,9],[2,1,9],[4,10],[4,1,10],[5,9],[5,9],[6,9],[15],[14],[12],[8],[2]]}'; // Apple
    // var json = '{"columns":[[5],[8],[9],[3,5],[1,3],[1,2],[2],[2],[2],[1]],"rows":[[3],[3],[3],[3],[3],[4],[4],[5,2],[8],[6]]}'; // Moon
    // var json = '{"columns":[[2],[2],[4,2],[8],[9],[6,3],[6,4],[5,5],[5,6],[4,7],[3,7],[2,8],[2,7],[8],[5]],"rows":[[6],[9],[6,2],[6,4],[6,5],[5,6],[5,6],[4,7],[3,7],[11],[9],[8],[2],[2],[1]]}'; // Leaf
    
    // var json = '{"columns":[[0],[15],[15],[15],[1,1],[1,3,1,1,1],[1,1,1,1,1,1],[1,1,1,1,1,1],[1,1,1,1,1,1],[1,1,1,1,1,1],[1,3,1,1,1],[1,1],[15],[0],[0]],"rows":[[12],[3,1],[3,1],[3,6,1],[3,1,1,1],[3,6,1],[3,1],[3,1],[3,6,1],[3,1],[3,6,1],[3,1],[3,1],[3,1],[12]]}'; // ノート
    // var json = '{"columns":[[20],[13,5],[12,4],[11,4],[11,3],[5,3],[4,1,1,3],[3,1,1,3],[3,3,3],[3,3,3],[3,3,1,3],[3,3,1,3],[3,3,3],[4,1,1,3],[5,3],[7,3,3],[7,2,4],[8,1,4],[13,5],[20]],"rows":[[20],[20],[20],[7,7],[6,6,6],[5,1,6,5],[5,6,5],[5,3],[5,2,2],[5,2,2],[5,1,2],[3,3],[2,2],[1,1,1,1],[1,2,1],[2,2],[4,4],[20],[20],[20]]}'; // コーヒーカップ

    // var json = '{"columns":[[2],[2],[3,1],[4,2],[7],[1,5],[2,5],[2,2,3],[4,4],[4,4],[4,3],[2,1],[2],[2],[2]],"rows":[[4,1],[5],[6],[7],[1,1],[0],[4],[5],[4,1],[5],[3],[6],[9],[2,5],[4]]}'; // カモメ

    // var json = '{"columns":[[2,2],[2,2],[2,5,2],[5,4,3],[4,3,2],[6,2],[6,6,2,1],[17,2],[20],[19],[18],[16],[6,9],[4,7,3],[9,2],[18],[1,4,3,5],[3,2],[3,2],[5]],"rows":[[5,2],[7,1],[8,1],[8,2],[3,8,2],[4,8,2],[1,2,7,3],[2,5,3,2],[20],[3,16],[2,12,1],[14,1],[14,1],[14],[6,3],[11,2],[9,7],[2,3,6],[3],[3]]}'; // タコ
    // var json = '{"columns":[[1,8],[3,8],[3,9],[4,10],[5,11],[6,3,8],[7,1,1,9],[7,1,8],[8,13],[8,2,8],[10,11],[11,9],[9,2,1,8],[9,2,1,9],[9,1,1,9],[9,2,8],[10,1,9],[9,1,8],[9,10],[20],[19],[18],[17],[16],[11]],"rows":[[5],[14],[21],[23],[22],[20],[19],[17],[3,16],[6,1,15],[12,10],[5,2,4,1,6],[7,1,1,2,7],[9,1,10],[11,4,7],[12,8],[24],[22],[21],[18],[16],[12],[8],[6],[2]]}'; // 宝箱
    // var json = '{"columns":[[6],[9],[10],[12],[13],[15],[16],[17],[19],[19],[20],[20],[8,11],[8,10],[7,11],[5,8],[2,9],[1,1,6],[1,1,3],[3,1]],"rows":[[5],[8],[9],[11],[10],[11,3],[10,1,1],[10,1,2],[9,2],[11,6],[18],[18],[18],[18],[17],[16],[16],[15],[14],[12]]}'; // 探偵

    // var json = '{"columns":[[0],[0],[4],[7],[8],[4,4],[12],[4,8],[15],[3,11],[15],[6,3,4],[15],[17],[18],[9,8],[1,8,7],[16],[11,3],[9],[9],[4],[1,1],[1,1],[0]],"rows":[[0],[0],[2,1],[2,2],[8],[8],[8],[12,1],[15],[14],[2,12],[9,8],[10,4],[5,6],[2,11],[14],[15],[8,6],[2,12],[15],[13],[11],[7],[2],[0]]}'; // いちご

    // var json = '{"columns":[[0],[0],[5],[9],[11],[13],[1,4,10],[1,1,3,12],[2,2,3,12],[9,14],[23],[21],[21],[1,19],[20],[2,18],[2,17],[17],[17],[15],[13],[10],[6],[0],[0]],"rows":[[2],[2],[2],[1,2,1],[7,2],[5,2],[6],[8],[14],[16],[4,12],[4,13],[3,16],[21],[21],[21],[21],[21],[19],[19],[17],[16],[14],[12],[10]]}'; // トマト

    // var json = '{"columns":[[1,4],[3,5],[3,8],[13],[7,6],[7,8],[7,15],[7,16],[24],[8,15],[8,15],[5,14],[4,14],[5,15],[20],[20],[2,14],[3,2,6],[4,7],[7],[8],[9],[7],[6],[4]],"rows":[[2,1],[6,2],[6,2],[9,3],[12,2],[17,2],[19,3],[5,4,3,2,2],[2,3,2,1,3],[7,6,3],[16,2],[3,12,4],[22],[22],[22],[21],[18],[2,14],[11],[11],[11],[11],[11],[10],[4]]}'; // 忍者くん

    // var json = '{"columns":[[9],[13],[11,3],[13,4],[16,3],[4,8,3],[19,3],[2,7,8,2],[9,8,3],[9,6,2],[9,6,1],[11,5,1],[11,1],[11,1],[4,6,1],[4,6,2],[10,2],[2,9,1],[2,10,2],[2,11,2],[3,5,3,3],[3,6,2],[15],[5,7],[9]],"rows":[[9],[13],[17],[4,9,3],[12,2,2],[17,2],[4,13,2],[4,14,2],[5,15,3],[5,2,10,3],[5,2,5,8],[7,6,1],[9,8],[11,2,4],[12,2,4],[2,9,6],[2,8,2,3],[2,8,2,2],[3,7,2],[2,3,1],[3,2],[4,3],[5,3],[4,4],[9]]}'; // 地球儀

    // var json = '{"columns":[[4,6,5],[1,2,8,5],[4,8,5],[16,5],[6,10,5],[17,5],[17,5],[2,17,5],[2,7,9,5],[20,5],[19,5],[16,2,5],[29],[29],[12,2,3,6],[19,5],[18,5],[18,5],[9,9,5],[17,5],[17,5],[16,6],[16,6],[16,6],[3,10,6],[1,9,6],[9,6],[9,6],[3,5,6],[1,6],[6],[6],[1,4,6],[17],[4,6],[11],[10],[6],[6],[6]],"rows":[[0],[6],[14],[15],[3,15],[22],[24],[24],[24],[25],[1,1,24],[18,10],[7,21],[14,13,1],[29,2],[29,1],[14,14,1],[11,2,14,2],[14,14,3],[16,2,4],[7,4,1,5],[2,3,4],[2,1,2],[2,1,2],[3,19],[40],[40],[40],[40],[40]]}'; // キリンと木

    var json = '{"columns":[[6],[10],[13],[1,12],[2,13],[1,14],[14],[1,15],[3,15],[2,1,15],[7,8],[5,5],[5,5],[3,5],[1,1,4],[3,3],[2,2],[4],[0],[0]],"rows":[[1],[2],[1,2],[2,9],[3,4,2],[2,6,2],[12],[12],[11],[11],[10,1],[10,1],[11,1],[10,1],[10,2],[15],[14],[13],[11],[9]]}';

    var solver = new Solver();
    solver.readFromJson(json);
    solver.solve();
  }
}
