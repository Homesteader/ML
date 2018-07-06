
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 2

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = true

-- for module display
CC_DESIGN_RESOLUTION = {
    width = 960,
    height = 640,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio > 1140/640 then -- 非主流分辨率
            return {autoscale = "SHOW_ALL"}
        elseif ratio < 960/768 then -- 非主流分辨率
            return { autoscale = "SHOW_ALL" }
        elseif ratio >= 1140/768 and ratio <= 1140/640 then
            return { height = 640, autoscale = "FIXED_HEIGHT" }
        elseif ratio >= 960/768 and ratio <= 960/640 then
            return { width = 960, autoscale = "FIXED_WIDTH" }
        else
            return { autoscale = "SHOW_ALL" }
        end
    end
    --FIXED_HEIGHT 高方向需要撑满，宽方向可裁减
    --FIXED_WIDTH  宽方向需要撑满，高方向可裁减
}
