local prototype = class("eSkyPlayerCameraEffectTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");
local misc = require("eSkyPlayer/misc/eSkyPlayerMisc");

function prototype:ctor()
    prototype.super.ctor(self);       --由于多重继承，只能用prototype.super这种写法
    self.trackType_ = definations.TRACK_TYPE.CAMERA_EFFECT;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA_MOTION;
    self.eventsSupportted_ = {definations.EVENT_TYPE.CAMERA_EFFECT};
    self.createParameters = {};
end


function prototype:_loadFromBuff(buff)
    if buff == nil then 
        return false; 
    end

    local trackTitle = buff:ReadString();
    local eventCount = buff:ReadShort();
    if eventCount == 0 then
        return true;
    end

    for e = 1, eventCount do
        local eventFile = {};
        local eventObj = nil;

        if self.eventsSupportted_ == nil then
            return false;
        end
        eventFile.beginTime_ = buff:ReadFloat();
        eventFile.name_ = buff:ReadString();
        eventFile.storeType_ = buff:ReadByte();
        eventFile.isLoopPlay_ = misc.getBoolByByte(buff:ReadByte());
        buff:ReadByte();--labelID

        local path = nil;
        if eventFile.storeType_ == 0 then
            path = Util.AppDataRoot .. "/mod/events/cameraMotion" .. eventFile.name_ .. ".byte";
        else
            if self.pathHeader_ == nil then 
                path = Util.AppDataRoot .. "/mod/plans/camera/" .. self.title_ .. "/cameraMotion/" .. eventFile.name_ .. ".byte";
            else 
                path = Util.AppDataRoot .. "/" .. self.pathHeader_ .. "cameraMotion/" .. eventFile.name_ .. ".byte";
            end
        end
        local buff = misc.readAllBytes(path);
        buff:SetReaderPosition(9);
        local temp = buff:ReadByte();
        if temp == definations.CAMERA_EFFECT_TYPE.BLOOM then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectBloomEventData");
        elseif temp == definations.CAMERA_EFFECT_TYPE.CHROMATIC_ABERRATION then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectChromaticAberrationEventData");
        elseif temp == definations.CAMERA_EFFECT_TYPE.DEPTH_OF_FIELD then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectDepthOfFieldEventData");
        elseif temp == definations.CAMERA_EFFECT_TYPE.VIGNETTE then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectVignetteEventData");
        elseif temp == definations.CAMERA_EFFECT_TYPE.FIELD_OF_VIEW then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectFieldOfViewEventData");
        elseif temp == definations.CAMERA_EFFECT_TYPE.BLACK then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectBlackEventData");
        elseif temp == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
            eventObj = newClass("eSkyPlayer/eSkyPlayerCameraEffectCrossFadeEventData");
        end
        eventObj:initialize();
        if self:isSupported(eventObj) == false then
            return false;
        end
        eventObj.eventData_ = {};
        local temp = buff:SetReaderPosition(0);
        if eventObj:_loadHeaderFromBuff(buff) == false then
            return false;
        end
        if eventObj:_loadFromBuff(buff) == false then
            return false;
        end
        self:_insertEvent(eventFile,eventObj);
    end
    return true;
end


function prototype.createObject(param)
    local obj = prototype:create();
    if obj:_setParam(param) == false then
        return nil;
    end
    return obj;
end

function prototype:_setParam(param)
    if misc.checkParam(self.createParameters,param) == false then
        return false;
    end
    return true;
end

function prototype:getResources()
    local resList = {};
    if #self.events_ == 0 then
        return nil;
    end
    
    for i = 1,#self.events_ do
        local res = self.events_[i].eventObj_:getResources();
        if res ~= nil then
            for j = 1,#res do
                resList[#resList + 1] = res[j];
            end
        end
    end
    return resList;
end

function prototype:isNeedAdditionalCamera()
    for i = 1, #self.events_ do
        if self.events_[i].eventObj_.motionType_ == definations.CAMERA_EFFECT_TYPE.CROSS_FADE then
            return true;
        end
    end
    return false;
end

return prototype;