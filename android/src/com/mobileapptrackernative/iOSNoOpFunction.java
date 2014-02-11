package com.mobileapptrackernative;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class iOSNoOpFunction implements FREFunction {
    public static final String GET_PARAMS           = "getSDKDataParameters";
    public static final String SET_ADVERTISER       = "setAppleAdvertisingIdentifier";
    public static final String SET_VENDOR           = "setAppleVendorIdentifier";
    public static final String DELEGATE             = "setDelegate";
    public static final String JAILBROKEN           = "setJailbroken";
    public static final String REDIRECT_URL         = "setRedirectUrl";
    public static final String GEN_JAILBROKEN       = "setShouldAutoDetectJailbroken";
    public static final String GEN_VENDOR           = "setShouldAutoGenerateAppleVendorIdentifier";
    public static final String USE_COOKIE           = "setUseCookieTracking";

    @Override
    public FREObject call(FREContext arg0, FREObject[] arg1) {
        return null;
    }

}
