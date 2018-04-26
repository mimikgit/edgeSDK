
var WebSocket = new require('ws');
var simple_jsonrpc = require('simple-jsonrpc-js');

//configure
var jrpc = new simple_jsonrpc();
var socket = new WebSocket("ws://127.0.0.1:8083/ws/edge-service-api/v1");

socket.onmessage = function (event) {
    jrpc.messageHandler(event.data);
};

jrpc.toStream = function (_msg) {
    socket.send(_msg);
};

socket.onerror = function (error) {
    console.error("Error: " + error.message);
};

/*

socket.onclose = function(event) {
    if (event.wasClean) {
        console.info('Connection close was clean');
    } else {
        console.error('Connection suddenly close');
    }

    console.info('close code : ' + event.code + ' reason: ' + event.reason);
};*/

//usage
//after connect

const token = process.env.ACCESS_TOKEN;

socket.onopen = function () {
    //calls
    jrpc.call('unassociateAccount', [token]).then(function (result) {
        console.log(result);
        setImmediate(function () {
            socket.onmessage = undefined;
            socket.close();
        });
    }).catch(e => {
    console.log(e);
    setImmediate(function () {
            socket.onmessage = undefined;
            socket.close();
        });
    }) ;
};


