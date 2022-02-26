function copyText() {
  document.getElementById('tbox2').value = document.getElementById('tbox1').value;
  console.log('hallo daar');
}


// function dropdownname_03_onchange() {
//   document.getElementById('tbox1').value = document.getElementById('dropdownname_03').value
// }


function setCookie_old3(cName, cValue, expDays) {
  let date = new Date();
  date.setTime(date.getTime() + (expDays * 24 * 60 * 60 * 1000));
  const expires = "expires=" + date.toUTCString();
  document.cookie = cName + "=" + cValue + "; " + expires + "; path=/";
}


function setCookieForSeconds(cName, cValue, forSeconds) {
  document.cookie = cName + "=" + cValue + ";max-age=" + forSeconds  + "; path=/scricon";
}


function testSetCookie () {
  setCookie("Koekje", "Speculaas", 7);
}


function finalize(){

  document.forms["webbieform"].submit();
  // wait some milliseconds for the function to be executed
  let now = Date.now(),
      end = now + 200;
  while (now < end) { now = Date.now(); }

  // Set the value of the cookie to DISABLED so that it is not executed on the next submit
  // This is needed because cookie-deletion is insecure
  setCookieForSeconds("scricon_run_function", "DISABLED", 300);  
}


function sendFunctionToServer() {
  setCookieForSeconds("scricon_run_function", 
    "funcname:g_tools.dummyPass++location:inner++varname:statustext++param1:nieuwe statustekst", 300);
  finalize();
}


function dropdownname_03_onchange() {
  setCookieForSeconds("scricon_run_function", 
    "funcname:g_html_json.setDropDown++location:inner++varname:dropdown1++param2:dropdownname_01++param3:third realvalue++param4:1", 300);
  finalize();
}


