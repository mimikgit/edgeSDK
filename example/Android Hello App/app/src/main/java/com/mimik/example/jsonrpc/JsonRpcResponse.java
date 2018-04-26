package com.mimik.example.jsonrpc;

import java.util.Map;

/**
 * Created by jon on 2018-02-16.
 */

public class JsonRpcResponse {
    public final String jsonrpc = "2.0";
    public Map<String, Object> result;
    public RpcError error;
    public long id;

    public class RpcError {
        public int code;
        public String message;
        public Object data;
    }
}
