
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

const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyNDU2NDg4MTE0NTY2MzY3MjkxIiwiYXpwIjoiMjI5MDMyMzkwOTA2Mzc0NDM3MyIsImp0aSI6IjJlODJiNmIyNGRkNDg0ZTg2NGQiLCJzY29wZSI6InJlYWQ6bWUgd3JpdGU6bWUgcmVhZDp1c2VycyByZWFkOmZyaWVuZExpc3QgZGVsZXRlOmZyaWVuZCByZWFkOnJlcXVlc3RGcmllbmRMaXN0IHJlYWQ6ZnJpZW5kUmVxdWVzdExpc3QgYWRkOnJlcXVlc3RGcmllbmQgZGVsZXRlOnJlcXVlc3RGcmllbmQgdXBkYXRlOmZyaWVuZFJlcXVlc3QgZGVsZXRlOmZyaWVuZFJlcXVlc3QgdXBkYXRlOm1lIiwibmJmIjoxNTE4NjQ0OTY1LCJleHAiOjE1MzQxOTY5NjUsImlzcyI6Imh0dHBzOi8vbWlkLm1pbWlrMzYwLmNvbS9tSUQvdjEvb2F1dGgvdG9rZW4iLCJhdWQiOiJodHRwczovL21pbWlrIn0.GdR6NHbhJtE43fVQRdsq85MQnKleXtPj4Ief62V2h_g";

socket.onopen = function () {
    //calls
    jrpc.call('associateAccount', [token]).then(function (result) {
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


