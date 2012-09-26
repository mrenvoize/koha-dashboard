
function loadbugs(){
    $.get('bug_status'
    ,function(data){
       // $('#bugs').html(data);
      $('#bugs_table > tbody').append( data );
    });

};


function randombug(){
    jQuery.support.cors = true;

  $.get('randombug'
  ,function(data){
    $('#randomtable').html( '<tr><td>'+  data +'</td></tr>' );
  }
  )
  setTimeout(randombug, 900000);
};



function needsignoff(){
  $.get('needsignoff'
  ,function(data){
  $('#needsignoff').html(data);
  }
  )
  setTimeout(needsignoff, 900000);
};




function jenkins(){
$.getJSON('http://jenkins.koha-community.org/api/json?jsonp='+"?&callback=?",
  function(data){
 //   $('#jenkins').html('<ul>');
    var jobs = data.jobs;


    for(var i=0;i<jobs.length;i++){



      var name = jobs[i].name;
      var colour = jobs[i].color;
      var status;
      if (colour === 'yellow') {
         status = 'Unstable';
         }
      else {
        if (colour === 'blue'){
           status = 'Stable';
        }
        else {
           status = 'Broken';
        }
      }
    //  $('#jenkins').html('<tr>');



    //  $('#jenkins').append('<td>'+name+' - '+status+"11</td>\n"    );
     $('#jenkins_table > tbody').append('<tr><td>'+name+'</td><td>'+status+"</td></tr> \n"    );

//      $('#jenkins').html('</tr>');
    }



//    $('#jenkins').append('</ul>');
    }
)
};


