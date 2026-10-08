JScode <-
  "$(function() {
    setTimeout(function(){
      var vals = [0];
      var powStart = 5;
      var powStop = 2;
      for (i = powStart; i >= powStop; i--) {
        var val = Math.pow(10, -i);
        val = parseFloat(val.toFixed(8));
        vals.push(val);
      }
      $('#pvalue').data('ionRangeSlider').update({'values':vals})
    }, 5)})"