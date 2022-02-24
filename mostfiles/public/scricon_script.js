function copyText() {
  document.getElementById('tbox2').value = document.getElementById('tbox1').value;
  console.log('hallo daar');
}


function setText() {
  document.getElementById('tbox1').value = document.getElementById('dropdownname_03').value
}


function setCookie_old3(cName, cValue, expDays) {
  let date = new Date();
  date.setTime(date.getTime() + (expDays * 24 * 60 * 60 * 1000));
  const expires = "expires=" + date.toUTCString();
  document.cookie = cName + "=" + cValue + "; " + expires + "; path=/";
}

function getCookie(cname) {
  let name = cname + "=";
  let ca = document.cookie.split(';');
  for(let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}


function checkCookie() {
  let user = getCookie("username");
  if (user != "") {
    alert("Welcome again " + user);
  } else {
    user = prompt("Please enter your name:", "");
    if (user != "" && user != null) {
      setCookie("username", user, 365);
    }
  }
} 


function setCookieForSeconds(cName, cValue, forSeconds) {
  document.cookie = cName + "=" + cValue + ";max-age=" + forSeconds  + "; path=/scricon";
}


function testSetCookie () {
  setCookie("Koekje", "Speculaas", 7);
}


function sendFunctionToServer() {
  setCookieForSeconds("scricon_run_function", 
    "funcname:g_tools.dummyPass++location:inner++varname:statustext++param1:nieuwe statustekst", 60);
  document.forms["webbieform"].submit();

  // wait some milliseconds for the function to be executed
  let now = Date.now(),
      end = now + 1000;
  while (now < end) { now = Date.now(); }

  // Set the value of the cookie to DISABLED so that it is not executed on the next submit
  // This is needed because cookie-deletion is insecure
  setCookieForSeconds("scricon_run_function", "DISABLED", 60);

}


