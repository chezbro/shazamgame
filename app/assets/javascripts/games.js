// $(function() {

//     function getSelections() {
//       var $selects = $('.pref_pick_int option:selected').not($(".pref_pick_int").find("option:contains('Select an Amount')")  )
//           values = [];

//         $($selects).each(function() {
//             if($(this).val()) {
//                 values.push($(this).val());        
//             }
//         });
//           if(!values.length) {
//               alert('Please select a new pref pick amount');
//               return false;
//           }
//         if(values.length < $selects.length || $.unique(values).length < $selects.length) {
//           alert('Please Select a unique Pref Amount');
//           $(this)[0].selectedIndex=0;
//           return false;
//         }

//   }

// $('.pref_pick_int').change(getSelections);

// })




// $(function() {

// var $select = $(".pref_pick_int");
// $select.on("change", function() {
//     var selected = [];  
//     $.each($select, function(index, select) {           
//         if (select.value !== "") { selected.push(select.value); }
//     });         
//    $(".pref_pick_int option").prop("disabled", false);         
//    for (var index in selected) { 
//       selected.filter(function(itm,i,a){
//         if (i==a.indexOf(itm)){
//           $('option[value="'+selected[index]+'"]').prop("disabled", true); 
//         }
//       })
//    }
// });

// })

