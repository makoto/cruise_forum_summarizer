// alert('aaa');
$(document).ready(function(){

  var threads = {}
  var thread = {}
  var id = $('input[name=del]').val()
  thread.title =  $('input[name=del]').parent(':not(:contains("Re"))').children('b').text()

  hizuke = '日付'
  hizuke_collong = ''
  month = '月'
  day = '日'
  colon = '：'
  matching_condition = new RegExp(hizuke + colon + "12" + month + "\\d{1,2}" + day);
  replace_condition = new RegExp(hizuke + colon);

  thread.date = $("td:contains(" + hizuke + ")").html().match(matching_condition)[0].replace(replace_condition,"")
  thread.user =  $("td:contains(" + hizuke + ")").children('b').get(0).innerHTML
  
  var replies = {}
  
  $('input[name=del]').parent(':contains("Re")').each(
   function(){

     // <tbody>
     //   <tr> 
     //     <td rowspan="3" width="32"><br></td> 
     //     <td><input name="del" value="5635" type="checkbox">5635．<b>Re: カーニバル「レジェンド」</b></td> 
     //   </tr> 
     //   <tr> 
     //     <td>名前：<b>いちごおじさん</b> &nbsp;&nbsp; 日付：12月13日(土) 1時2分</td> 
     //   </tr> 
     //   <tr>
     //     <td> 藤原様<br><br>お返事ありがとうございます。<br>実は旅行業に従事しておりますが、クルーズではありませんが、１１月、１２月の日本からカナダへの旅行者は、エアラインの燃油費が高いのもあり、円高傾向になったものの例年と比べると激減し、インバウンド旅行業は瀕死の状態と言っていい状態です。<br>クルーズのように航空会社の燃油費もいち早く撤廃して欲しいと感じています。 <br> <a href="http://ameblo.jp/funship/entrylist.html%20" target="_blank">http://ameblo.jp/funship/entrylist.html </a> </td> 
     //   </tr>
     // </tbody>
     var reply = {}
     var reply_id = $(this).children(':first-child').val();
     var reply_tag = $(this).parent().next().children(':first-child')
     reply.date = reply_tag.html().match(matching_condition)[0].replace(replace_condition,"")
     reply.user = reply_tag.children('b').get(0).innerHTML
     replies[reply_id] = reply
   }
  )
  thread.replies = replies

  threads[id] = thread
  $("#result").append("<br>");
  display_object(threads);
}
)

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


// function get_date () {
//   $(this).html().match(/日付：12月\d{1,2}日/)[0].replace(/日付：/g,"")
// }