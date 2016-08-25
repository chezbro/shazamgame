$(function() {

  function getSelections() {
    var options = $('.pref_pick_int option:selected');

    var a = $.map(options ,function(option) {
        return option.value;
    });

    for (i = 0; i < a.length; ++i) {
        if(a.indexOf(a[i]) != a.lastIndexOf(a[i]))
              alert("Preference Amount Must be Unique");
    }
}


$('.pref_pick_int').change(getSelections);

})


