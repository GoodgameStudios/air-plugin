package com.hasoffers.nativeExtensions
{
    import flash.events.EventDispatcher;
    import flash.events.StatusEvent;
    import flash.external.ExtensionContext;
    import flash.utils.Dictionary;

    [RemoteClass(alias="com.hasoffers.nativeExtensions.MobileAppTracker")]
    public class MobileAppTracker extends EventDispatcher
    {
        static public const TUNE_DEEPLINK:String = "TUNE_DEEPLINK";
        static public const TUNE_DEEPLINK_FAILED:String = "TUNE_DEEPLINK_FAILED";
        // If the AIR application creates multiple MobileAppTracker objects,
        // all the objects share one instance of the ExtensionContext class.

        private static var extId:String = "com.hasoffers.MobileAppTracker";
        private static var extContext:ExtensionContext = null;

        public var matAdvertiserId:String;
        public var matConversionKey:String;

        private static var _instance:MobileAppTracker = null;

        public static function get instance():MobileAppTracker
        {
            trace("MATAS.instance");
            if (_instance == null)
            {
                _instance = new MobileAppTracker(new SingletonEnforcer());
            }
            return _instance;
        }

        public function MobileAppTracker(enforcer:SingletonEnforcer)
        {
            trace("MATAS.Constructor");
            if (enforcer == null) throw new Error("Invalid singleton access. Please use MobileAppTracker.instance() instead.");
        }

        public function init(matAdvertiserId:String, matConversionKey:String):void
        {
            trace("MATAS.init(" + matAdvertiserId + ", " + matConversionKey + ")");

            // If the one instance of the ExtensionContext class has not
            // yet been created, create it now.

            if (!extContext)
            {
                if(null == matAdvertiserId || null == matConversionKey || 0 == matAdvertiserId.length || 0 == matConversionKey.length)
                {
                    throw new Error("advertiser id and conversion key cannot be null or empty");
                }

                this.matAdvertiserId = matAdvertiserId;
                this.matConversionKey = matConversionKey;

                initExtension(matAdvertiserId, matConversionKey);
            }
        }

        // Initialize the extension by calling our "initNativeCode" ANE function
        private function initExtension(matAdvertiserId:String, matConversionKey:String):void
        {
            trace("MATAS.initExtension(" + matAdvertiserId + ", " + matConversionKey + "): Create an extension context");

            // The extension context's context type is NULL, because this extension
            // has only one context type.
            extContext = ExtensionContext.createExtensionContext(extId, null);

            if ( extContext )
            {
                extContext.addEventListener(StatusEvent.STATUS, onStatusEvent);
                trace("MATAS.initExtension: calling initMAT");
                extContext.call(NativeMethods.initMAT, matAdvertiserId, matConversionKey);
            }
            else
            {
                trace("MATAS.initExtension: extContext = null");
                throw new Error("Error when instantiating MobileAppTracker native extension." );
            }
        }

        public function checkForDeferredDeeplink():void
        {
            trace("MATAS.checkForDeferredDeeplink()");
            extContext.call(NativeMethods.checkForDeferredDeeplink);
        }
        
        public function measureSession():void
        {
            trace("MATAS.measureSession()");
            extContext.call(NativeMethods.measureSession);
        }

        public function measureEventName(event:String):void
        {
            trace("MATAS.measureEventName(" + event + ")");
            extContext.call(NativeMethods.measureEventName, event);
        }

        public function measureEvent(event:Dictionary):void
        {
            trace("MATAS.measureEvent(" + event + ")");

            // Create array to hold the event item param values
            var arrItems:Array = new Array();

            for each (var dictItem:Dictionary in event["eventItems"])
            {
                arrItems.push(new String(dictItem.item));
                arrItems.push(dictItem.unit_price != null ? dictItem.unit_price : 0);
                arrItems.push(dictItem.quantity != null ? dictItem.quantity : 0);
                arrItems.push(dictItem.revenue != null ? dictItem.revenue : 0);
                arrItems.push(new String(dictItem.attribute1));
                arrItems.push(new String(dictItem.attribute2));
                arrItems.push(new String(dictItem.attribute3));
                arrItems.push(new String(dictItem.attribute4));
                arrItems.push(new String(dictItem.attribute5));
            }

            trace("MATAS.measureEvent: arrItems = " + arrItems);

            extContext.call(NativeMethods.measureEvent,
                        new String(event.name),
                        arrItems,
                        event.revenue != null ? event.revenue : 0,
                        new String(event.currency),
                        new String(event.advertiserRefId),
                        new String(event.receipt),
                        new String(event.receiptSignature),
                        new String(event.attribute1),
                        new String(event.attribute2),
                        new String(event.attribute3),
                        new String(event.attribute4),
                        new String(event.attribute5),
                        new String(event.contentId),
                        new String(event.contentType),
                        new String(event.date1),
                        new String(event.date2),
                        event.level != null ? event.level : 0,
                        event.quantity != null ? event.quantity : 0,
                        event.rating != null ? event.rating : 0,
                        new String(event.searchString)
            );
        }

        public function startAppToAppTracking(targetAppId:String, advertiserId:String, offerId:String, publisherId:String, shouldRedirect:Boolean):void
        {
            trace("MATAS.startAppToAppTracking()");
            extContext.call(NativeMethods.startAppToAppTracking, targetAppId, advertiserId, offerId, publisherId, shouldRedirect);
        }
        
        public function setAge(age:int):void
        {
            trace("MATAS.setAge(" + age + ")");
            extContext.call(NativeMethods.setAge, age);
        }

        public function setAllowDuplicates(allowDuplicates:Boolean):void
        {
            trace("MATAS.setAllowDuplicates(" + allowDuplicates + ")");
            extContext.call(NativeMethods.setAllowDuplicates, allowDuplicates);
        }

        public function setAndroidId(enable:Boolean):void
        {
            trace("MATAS.setAndroidId(" + enable + ")");
            extContext.call(NativeMethods.setAndroidId, enable);
        }

        public function setAppAdTracking(enable:Boolean):void
        {
            trace("MATAS.setAppAdTracking(" + enable + ")");
            extContext.call(NativeMethods.setAppAdTracking, enable);
        }
        
        public function setAppleAdvertisingIdentifier(appleAdvertisingIdentifier:String, advertisingTrackingEnabled:Boolean):void
        {
            trace("MATAS.setAppleAdvertisingIdentifier(" + appleAdvertisingIdentifier + ", " + advertisingTrackingEnabled + ")");
            extContext.call(NativeMethods.setAppleAdvertisingIdentifier, appleAdvertisingIdentifier, advertisingTrackingEnabled);
        }
        
        public function setAppleVendorIdentifier(appleVendorId:String):void
        {
            trace("MATAS.setAppleVendorIdentifier(" + appleVendorId + ")");
            extContext.call(NativeMethods.setAppleVendorIdentifier, appleVendorId);
        }

        public function setCurrencyCode(currencyCode:String):void
        {
            trace("MATAS.setCurrencyCode(" + currencyCode + ")");
            extContext.call(NativeMethods.setCurrencyCode, currencyCode);
        }

        public function setDeepLink(deepLinkUrl:String):void
        {
            trace("MATAS.setDeepLink(" + deepLinkUrl + ")");
            extContext.call(NativeMethods.setDeepLink, deepLinkUrl);
        }

        public function setDebugMode(enable:Boolean):void
        {
            trace("MATAS.setDebugMode(" + enable + ")");
            extContext.call(NativeMethods.setDebugMode, enable);
        }
        
        public function setDelegate(enable:Boolean):void
        {
            trace("MATAS.setDelegate(" + enable + ")");
            extContext.call(NativeMethods.setDelegate, enable);
        }
        
        public function setExistingUser(existingUser:Boolean):void
        {
            trace("MATAS.setExistingUser(" + existingUser + ")");
            extContext.call(NativeMethods.setExistingUser, existingUser);
        }

        public function setFacebookEventLogging(enable:Boolean, limitUsage:Boolean):void
        {
            trace("MATAS.setFacebookEventLogging(" + enable + ", " + limitUsage + ")");
            extContext.call(NativeMethods.setFacebookEventLogging, enable, limitUsage);
        }
        
        public function setFacebookUserId(facebookUserId:String):void
        {
            trace("MATAS.setFacebookUserId(" + facebookUserId + ")");
            extContext.call(NativeMethods.setFacebookUserId, facebookUserId);
        }
        
        public function setGender(gender:int):void
        {
            trace("MATAS.setGender(" + gender + ")");
            extContext.call(NativeMethods.setGender, gender);
        }
        
        public function setGoogleAdvertisingId(googleAid:String, limitAdTracking:Boolean):void
        {
            trace("MATAS.setGoogleAdvertisingId(" + googleAid + ", " + limitAdTracking + ")");
            extContext.call(NativeMethods.setGoogleAdvertisingId, googleAid, limitAdTracking);
        }

        public function setGoogleUserId(googleUserId:String):void
        {
            trace("MATAS.setGoogleUserId(" + googleUserId + ")");
            extContext.call(NativeMethods.setGoogleUserId, googleUserId);
        }
        
        public function setJailbroken(isJailbroken:Boolean):void
        {
            trace("MATAS.setJailbroken(" + isJailbroken + ")");
            extContext.call(NativeMethods.setJailbroken, isJailbroken);
        }
        
        public function setLocation(latitude:Number,longitude:Number,altitude:Number):void
        {
            trace("MATAS.setLocation(" + latitude + ", " + longitude + ", " + altitude + ")");
            extContext.call(NativeMethods.setLocation, latitude, longitude, altitude);
        }

        public function setPackageName(packageName:String):void
        {
            trace("MATAS.setPackageName(" + packageName + ")");
            extContext.call(NativeMethods.setPackageName, packageName);
        }

        public function setRedirectUrl(redirectUrl:String):void
        {
            trace("MATAS.setRedirectUrl(" + redirectUrl + ")");
            extContext.call(NativeMethods.setRedirectUrl, redirectUrl);
        }
        
        public function setShouldAutoDetectJailbroken(shouldAutoDetect:Boolean):void
        {
            trace("MATAS.setShouldAutoDetectJailbroken(" + shouldAutoDetect + ")");
            extContext.call(NativeMethods.setShouldAutoDetectJailbroken, shouldAutoDetect);
        }
        
        public function setShouldAutoGenerateAppleVendorIdentifier(shouldAutoGenerate:Boolean):void
        {
            trace("MATAS.setShouldAutoGenerateAppleVendorIdentifier(" + shouldAutoGenerate + ")");
            extContext.call(NativeMethods.setShouldAutoGenerateAppleVendorIdentifier, shouldAutoGenerate);
        }

        public function setSiteId(siteId:String):void
        {
            trace("MATAS.setSiteId(" + siteId + ")");
            extContext.call(NativeMethods.setSiteId, siteId);
        }

        public function setTRUSTeId(tpid:String):void
        {
            trace("MATAS.setTRUSTeId(" + tpid + ")");
            extContext.call(NativeMethods.setTRUSTeId, tpid);
        }
        
        public function setTwitterUserId(twitterUserId:String):void
        {
            trace("MATAS.setTwitterUserId(" + twitterUserId + ")");
            extContext.call(NativeMethods.setTwitterUserId, twitterUserId);
        }
        
        public function setUseCookieTracking(useCookieTracking:Boolean):void
        {
            trace("MATAS.setUseCookieTracking(" + useCookieTracking + ")");
            extContext.call(NativeMethods.setUseCookieTracking, useCookieTracking);
        }
        
        public function setUserEmail(userEmail:String):void
        {
            trace("MATAS.setUserEmail(" + userEmail + ")");
            extContext.call(NativeMethods.setUserEmail, userEmail);
        }

        public function setUserId(userId:String):void
        {
            trace("MATAS.setUserId(" + userId + ")");
            extContext.call(NativeMethods.setUserId, userId);
        }
        
        public function setUserName(userName:String):void
        {
            trace("MATAS.setUserName(" + userName + ")");
            extContext.call(NativeMethods.setUserName, userName);
        }
        
        public function setPhoneNumber(phoneNumber:String):void
        {
            trace("MATAS.setPhoneNumber(" + phoneNumber + ")");
            extContext.call(NativeMethods.setPhoneNumber, phoneNumber);
        }
        
        public function setPayingUser(payingUser:Boolean):void
        {
            trace("MATAS.setPayingUser(" + payingUser + ")");
            extContext.call(NativeMethods.setPayingUser, payingUser);
        }
        
        public function getAdvertisingId():String
        {
            trace("MATAS.getAdvertisingId()");
            return extContext.call(NativeMethods.getAdvertisingId) as String;
        }
        
        public function getMatId():String
        {
            trace("MATAS.getMatId()");
            return extContext.call(NativeMethods.getMatId) as String;
        }
        
        public function getOpenLogId():String
        {
            trace("MATAS.getOpenLogId()");
            return extContext.call(NativeMethods.getOpenLogId) as String;
        }
        
        public function getIsPayingUser():Boolean
        {
            trace("MATAS.getIsPayingUser()");
            return extContext.call(NativeMethods.getIsPayingUser) as Boolean;
        }
        
        public function getReferrer():String
        {
            trace("MATAS.getReferrer()");
            return extContext.call(NativeMethods.getReferrer) as String;
        }

        public function showBanner(placement:String):void
        {
            trace("MATAS.showBanner(" + placement + ")");
            extContext.call(NativeMethods.showBanner, placement);
        }

        public function showBannerWithMetadata(placement:String, metadata:Dictionary):void
        {
            trace("MATAS.showBannerWithMetadata(" + placement + ", " + metadata + ")");
            showBannerWithMetadataAndPosition(placement, metadata, 0);
        }

        public function showBannerWithMetadataAndPosition(placement:String, metadata:Dictionary, position:int):void
        {
            trace("MATAS.showBannerWithMetadataAndPosition(" + placement + ", " + metadata + ", " + position + ")");
            // Convert metadata's customTargets to array to iterate through on native
            var customTargetsArr:Array = new Array();
            for (var key:Object in metadata.customTargets) {
                var value:Object = metadata.customTargets[key];
                customTargetsArr.push(key, value);
            }
            metadata.customTargets = customTargetsArr;
            extContext.call(NativeMethods.showBanner, placement, metadata, position);
        }
        
        public function hideBanner():void
        {
            trace("MATAS.hideBanner()");
            extContext.call(NativeMethods.hideBanner);
        }

        public function destroyBanner():void
        {
            trace("MATAS.destroyBanner()");
            extContext.call(NativeMethods.destroyBanner);
        }

        public function cacheInterstitial(placement:String):void
        {
            trace("MATAS.cacheInterstitial(" + placement + ")");
            extContext.call(NativeMethods.cacheInterstitial, placement);
        }

        public function cacheInterstitialWithMetadata(placement:String, metadata:Dictionary):void
        {
            trace("MATAS.cacheInterstitial(" + placement + ", " + metadata + ")");
            extContext.call(NativeMethods.cacheInterstitial, placement, metadata);
        }

        public function showInterstitial(placement:String):void
        {
            trace("MATAS.showInterstitial(" + placement + ")");
            extContext.call(NativeMethods.showInterstitial, placement);
        }

        public function showInterstitialWithMetadata(placement:String, metadata:Dictionary):void
        {
            trace("MATAS.showInterstitialWithMetadata(" + placement + ", " + metadata + ")");
            // Convert metadata's customTargets to array to iterate through on native
            var customTargetsArr:Array = new Array();
            for (var key:Object in metadata.customTargets) {
                var value:Object = metadata.customTargets[key];
                customTargetsArr.push(key, value);
            }
            metadata.customTargets = customTargetsArr;
            extContext.call(NativeMethods.showInterstitial, placement, metadata);
        }
        
        public function destroyInterstitial():void
        {
            trace("MATAS.destroyInterstitial()");
            extContext.call(NativeMethods.destroyInterstitial);
        }

        public function onStatusEvent(event:StatusEvent):void
        {
            trace("MATAS.statusHandler(): " + event);
            if("success" == event.code)
            {
                trackerDidSucceed(event.level);
            }
            else if("failure" == event.code)
            {
                trackerDidFail(event.level);
            }
            else if("enqueued" == event.code)
            {
                trackerDidEnqueueRequest(event.level);
            }
            dispatchEvent(new StatusEvent(event.code, false, false, event.code, event.level));
        }

        public static function trackerDidSucceed(data:String):void
        {
            trace("MATAS.trackerDidSucceed()");
            trace("MATAS.data = " + data);
        }

        public static function trackerDidFail(error:String):void
        {
            trace("MATAS.trackerDidFail()");
            trace("MATAS.error = " + error);
        }
        
        public static function trackerDidEnqueueRequest(referenceId:String):void
        {
            trace("MATAS.trackerDidEnqueueRequest()");
            trace("MATAS.referenceId = " + referenceId);
        }
    }
}
