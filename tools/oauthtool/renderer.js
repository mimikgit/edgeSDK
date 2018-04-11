// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

try {
    var hash = window.location.hash.substring(1);

    var ERROR_STR = 'error-';
    var json;

    if (hash.startsWith(ERROR_STR)) {
        var e = hash.substring(ERROR_STR.length);
        json = JSON.parse(e);;
    } else {
        json = JSON.parse(hash);
    }

    var para = document.createElement("code");
    para.className = "prettyprint js";
    var node = document.createTextNode(JSON.stringify(json));
    para.appendChild(node);

    var element = document.getElementById("main");
    element.appendChild(para);
} catch (error) {

}