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
//   $('.pref_pick_int').change(function() {
//       if($(this).val() != "") {
//           $(".pref_pick_int option:selected").remove();
//           $('.pref_pick_int option:selected').attr('disabled', 'disabled');
//       } else {
//           // $('.pref_pick_int option:selected').removeAttr('disabled');
//       }
//   })
// })