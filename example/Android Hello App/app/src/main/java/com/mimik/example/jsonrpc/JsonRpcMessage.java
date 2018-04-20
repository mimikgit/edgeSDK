package com.mimik.example.jsonrpc;

import java.util.List;

/**
 * Created by jon on 2018-02-16.
 */

public class JsonRpcMessage {
    public final String jsonrpc = "2.0";
    public String method;
    public List<Object> params;
    public long id;

    public JsonRpcMessage(String method, List<Object> params, long id) {
        this.method = method;
        this.params = params;
        this.id = id;
    }
}
