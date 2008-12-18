$(document).ready(function(){
console.log(1);
//console.log( $('td:contains("日付：")').html().match(/日付：12月＼d{1,2}日/)[0]);
console.log( $('td:contains("日付：")').html().match(/日付：12月＼d{1,2}日/)[0].replace(/日付：/, ""))
}
)

for (var i = obj.length - 1; i >= 0; i--){
  obj[i]
};