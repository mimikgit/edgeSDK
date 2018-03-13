package com.mimik.edgeservice;

import java.util.Map;
import com.mimik.edgeservice.EdgeServiceParcelable;

// Binding action for mimik edge service is "com.mimik.edgeservice.ACTION_BIND"
interface IEdgeService {
    int start(in EdgeServiceParcelable params);
    void stop();
    String getMcmLicense();
}
