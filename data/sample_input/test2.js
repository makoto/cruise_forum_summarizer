$(document).ready(function(){
console.log(1);
//console.log( $('td:contains("日付：")').html().match(/日付：12月＼d{1,2}日/)[0]);
日付：12月＼d{1,2}日
console.log( $('td:contains("日付：")').html().match()[0].replace(/日付：/, ""))
}
)