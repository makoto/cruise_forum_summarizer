$(document).ready(function(){
 var threads = {}
threads = $("table[width='90%']").map(
 function(){fetch_threads(this)}
)
 alert (1);
 $("#result").append("<br>");
 //display_object(threads);
}
)

function fetch_threads(obj){
  var threads = {}
  var thread = {}
  
  var id = $(obj).find('input[name=del]').val()
  thread.title =  $(obj).find('input[name=del]').parent(':not(:contains("Re"))').children('b').text()
  var hizuke = 'ì˙ït'
  var hizuke_collong = ''
  var month = 'åé'
  var day = 'ì˙'
  var colon = 'ÅF'
  matching_condition = new RegExp(hizuke + colon + "(12" + month + ".{1,2}" + day + ")");
  replace_condition = new RegExp(hizuke + colon);

 thread.date = $(obj).find("td:contains(" + hizuke + ")").html().match(matching_condition)[1]
 thread.user =  $(obj).find("td:contains(" + hizuke + ")").children('b').get(0).innerHTML

  var replies = {}
  $(obj).find('input[name=del]').parent(':contains("Re")').each(
   function(){
     //console.log($(this).html());  


     var reply = {}
     var reply_id = $(this).children(':first-child').val();
     var reply_tag = $(this).parent().next().children(':first-child')
     reply.date = reply_tag.html().match(matching_condition)[1]
    reply.user = reply_tag.children('b').get(0).innerHTML
    replies[reply_id] = reply
   }
  )
  thread.replies = replies
  threads[id] = thread
  display_object(threads);
  return threads
}



function display_object (obj) {
 	for (t in obj)
 	{
 	  {$("#result").append(t +  "<br>")}      
  	for (tt in obj[t])
  	{ 
      if (typeof obj[t][tt] == "object")
      {
        {$("#result").append(tt +  "<br>")}      
        display_object(obj[t][tt]);
      }
      else
  	  {$("#result").append(tt + ":" + obj[t][tt] + "<br>")}
  	}
  }
}
// file:///Users/makoto/work/cruise/data/sample_input/test1.html


