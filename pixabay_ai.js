jQuery(function($){

  $("button.ai_train").click(function(e){
    e.preventDefault();
    var $this = $(this);
    var json = $this.attr("data-array");
    var val = $this.attr("data-val");

    $.ajax({
      type: "POST",
      url: "./ai/train.php",
      data: {
        "sample": json,
        "label": val
      },
      success: function(data){
        $this.parent().append(" OK");
        console.log(data);
      }
    });
  });

  $("button.ai_predict").click(function(e){
    e.preventDefault();
    var $this = $(this);
    var json = $this.attr("data-array");

    $.ajax({
      type: "POST",
      url: "./ai/predict.php",
      data: {
        "sample": json
      },
      success: function(data){
        $this.after(data);
      }
    });
  });

  $(".ai_auto_predict").each(function(){
    var $this = $(this);
    var json = $this.attr("data-array");

    $.ajax({
      type: "POST",
      url: "./ai/predict.php",
      data: {
        "sample": json
      },
      success: function(data){
        if(data == "5"){
          $this.html('<span style="color: red; font-weight: bold;">★★★</span>');
        }else if(data == "3"){
          $this.html('<span style="color: orange; font-weight: bold;">★★</span>');
        }else{
          $this.html(data);
        }
      }
    });
  });

  $(".ai_section").show();

});
