local prototype = class("eSkyPlayerCameraEffectTrackData", require("eSkyPlayer/eSkyPlayerTrackDataBase"));
local definations = require("eSkyPlayer/eSkyPlayerDefinations");


function prototype:ctor()
    self.base:ctor();
    self.trackType_ = definations.TRACK_TYPE.CAMERA_EFFECT;
    self.trackFileType_ = definations.TRACK_FILE_TYPE.CAMERA_MOTION;
end

function prototype:getResources()
    local resList_ = {};
    if #self.events_ == 0 then
        return nil;
    end
    
    for i = 1,#self.events_ do
        local res = self.events_[i].eventObj:getResources();
        if res ~= nil then
            for j = 1,#res do
                resList_[#resList_ + 1] = res[j];
            end
        end
    end
    return resList_;
end
return prototype;