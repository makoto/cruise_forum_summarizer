$(document).ready(function(){
console.log(1);
//console.log( $('td:contains("���t�F")').html().match(/���t�F12���_d{1,2}��/)[0]);
���t�F12���_d{1,2}��
console.log( $('td:contains("���t�F")').html().match()[0].replace(/���t�F/, ""))
}
)