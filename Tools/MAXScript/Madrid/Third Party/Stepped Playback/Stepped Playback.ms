-- Jean-Sebastien Nicaise
-- with the help of denisT of cgsociety.org's forums
-- jsnicaise@gmail.com
-- Dec. 16, 2009 23:00

---------------------------------------------------------------------------------
-- This script plays back the animation in stepped mode
--
-- something to remember: when playing, the last frame is not
-- played, as it is when playing an animation with
-- 3ds max.
--
-- also: it is not as precise as normal stepped mode playback.
-- It will slow down the more keys you have and the larger
-- the animation range is.
---------------------------------------------------------------------------------

-- display for debug:    display all keys inside trackbar
--                         display delay (in frames) for each keys


try (destroyDialog steppingUI) catch()

-- spSettings[1] = Current/Custom FPS on/off
-- spSettings[2] = Custom FPS integer
-- spSettings[3] = Loop on/off
-- spSettings[4] = 1 = forward, 2 = backward
global spSettings = if spSettings == undefined then #(off, 60, on, 1) else spSettings

-- UI
rollout steppingUI "Stepped Keys"
(
    group "Frame Rate:"
    (
        label curr_lb "Current: " across:2 align:#right offset:[21,0] enabled:(not spSettings[1]);
        spinner curr_sp "" enabled:off range:[1,1000,frameRate] type:#integer fieldwidth:56 offset:[1,0];
        checkbox cust_ch "" across:2 checked:spSettings[1] width:15 offset:[0,-1];
        spinner cust_sp "Use Custom Rate: " range:[1,1000,spSettings[2]] type:#integer fieldwidth:56 enabled:spSettings[1] offset:[1,0];
    )
    group "Playback:"
    (
        checkbox loop_ch "Loop" across:2 checked:spSettings[3] enabled:true;
        radiobuttons dir "Direction:" labels:#("Forward", "Reverse") columns:2 default:spSettings[4] align:#left offset:[-36,1];
        checkbutton play "Play Animation" width:180 offset:[0,4];
    )
   
   
     timer playTm active:false;
   
   
    ------------------------------
    -- functions set
    ------------------------------
    -- REWORKED
    -- returns an array of keys for the selected object(s). The values inside the array are Time classes. (-12f, 8f, etc.)
    function getKeys dir =
    (
        if $ != undefined then
        (
            a = #();
            case dir of
            (
                1:
                if (nextK = at time currentTime trackbar.getNextKeyTime()) == undefined and (at time (currentTime - 1f) trackbar.getNextKeyTime()) != undefined then
                (
                    append a (at time (currentTime - 1f) trackbar.getNextKeyTime());
                )
                else
                (
                    while (findItem a nextK) == 0 and nextK != undefined do
                    (
                        append a nextK;
                        nextK = at time nextK trackbar.getNextKeyTime();
                    )
                    if a.count == 0 then return undefined;
                    else return a;
                )
                2:
                if (nextK = at time currentTime trackbar.getPreviousKeyTime()) == undefined and (at time (currentTime + 1f) trackbar.getPreviousKeyTime()) != undefined then
                (
                    append a (at time (currentTime + 1f) trackbar.getPreviousKeyTime());
                )
                else
                (
                    while (findItem a nextK) == 0 and nextK != undefined do
                    (
                        append a nextK;
                        nextK = at time nextK trackbar.getPreviousKeyTime();
                    )
                    if a.count == 0 then return undefined;
                    else return a;
                )
            )
        )
    )
    -- REWORKED
    -- filter an array of keys depending if keys are inside given range (inclusively)
    function filterKeys arr start end =
    (
        a = #();
        if arr != undefined then
        (
            for i in 1 to arr.count by 1 do
            (
                if arr[i] < start or arr[i] > end then ()
                else append a arr[i];
            )
        )
        if a.count == 0 then return undefined;
        else return a;
    )
   
    -- REWORKED
    -- returns true if it finds val value inside arr array, false if not and undefined if arr is undefined
    function isInside arr val =
    (
        if arr != undefined then
        (
            if (r =(findItem arr val)) != 0 then return true;
            else return false;
        )
    )
    -- REWORKED
    -- returns the previous key of given key within array
    function returnPrev arr key =
    (
        if key != undefined and arr != undefined and arr.count > 1 and (isInside arr key) then
        (
            if ((findItem arr key) - 1) < 1 then return arr[arr.count];
            else return arr[((findItem arr key) - 1)];
        )
    )
    -- REWORKED
    -- returns the next key of given key within array
    function returnNext arr key =
    (
        if key != undefined and arr != undefined and arr.count > 1 and (isInside arr key) then
        (
            if ((findItem arr key) + 1) > arr.count then return arr[1];
            else return arr[((findItem arr key) + 1)];
        )
    )
    -- REWORKED
    -- returns wait time in frames between two frames, depending of the given animation range and the direction the animation is going
    -- dir = 1 = forward, 2 = backward
    function getDelay arr first second start end dir =
    (
        if first != undefined and second != undefined and arr != undefined then
        (
            case dir of
            (
                1: if (isInside arr first) and (isInside arr second) then
                (
                    if first > second then
                    (
                        wait = (end - first) + (second - start);
                    )
                    else if first < second then
                    (
                        wait = second - first;
                    )
                    else wait = undefined;
                )
               
                2:    if (isInside arr first) and (isInside arr second) then
                (
                    if first > second then
                    (
                        wait = first - second;
                       
                    )
                    else if first < second then
                    (
                        wait = (first - start) + (end - second);
                    )
                    else wait = undefined;
                )
            )
        return wait;
        )
    )
    ------------------------------
    -- END functions set
    ------------------------------
   

--     format "next: %\n" next

    local playArray = #();
    local nextDelay;
    local nextK;
    local fps;
    local steps;
    local t2;
    local t;
   
    -- UI checkboxes, sliders and radio buttons events
    on cust_ch changed state do
    (
        curr_lb.enabled = not (cust_sp.enabled = spSettings[1] = state);
        if spSettings[1] then fps = spSettings[2]; else fps = frameRate;
    )
    on dir changed state do
    (
        case (spSettings[4] = state) of
        (
            1: playArray = filterKeys (getKeys 1) animationRange.start (animationRange.end - 1);
            2: playArray = filterKeys (getKeys 2) (animationRange.start + 1) (animationRange.end);
        )
    )
    on cust_sp changed val do fps = spSettings[2] = val;
    on loop_ch changed state do spSettings[3] = state;
       
   
    -- main
    function startPlay =
    (
        d = (nextDelay.frame) * 1000 / fps
        if t != undefined and t2 != undefined then
        (
            if (d - (t2 - t)) <= 0 then playTm.interval = 1;
            else playTm.interval = d - (t2 - t);
        )
        else playTm.interval = d;
        playTm.active = true;
        print (format "wait time for next key: %\n" PlayTm.interval);
    )
    fn stopPlay =
    (
        play.state = playTm.active = false;
        playTm.ticks = 0;
        nextK = undefined;
        nextDelay = undefined;
    )
   
    -- to do: optimize
    on play changed state do
    (
        case spSettings[4] of
        (
            1:    if state and not isAnimPlaying() and (playArray = filterKeys (getKeys 1) animationRange.start (animationRange.end - 1)) != undefined then
            (
                if spSettings[1] then fps = spSettings[2]; else fps = frameRate;
                sliderTime = playArray[1];
                if (nextK = returnNext playArray currentTime) != undifined and (nextDelay = getDelay playArray currentTime nextK animationRange.start animationRange.end 1) != undefined then startPlay(); else stopPlay();
                steps = playArray.count;
            )
            else stopPlay();
           
            2:    if state and not isAnimPlaying() and (playArray = filterKeys (getKeys 2) (animationRange.start + 1) (animationRange.end)) != undefined then
            (
                if spSettings[1] then fps = spSettings[2]; else fps = frameRate;
                sliderTime = playArray[1];
                if (nextK = returnNext playArray currentTime) != undifined and (nextDelay = getDelay playArray currentTime nextK animationRange.start animationRange.end 2) != undefined then startPlay(); else stopPlay();
                steps = playArray.count;
            )
            else stopPlay();
        )
    )   
   
     on playTm tick do
     (
        if play.state then
        (
            if not(spSettings[3]) and playTm.ticks >= steps then stopPlay();
            else
            (
                playTm.active = false;
                t = timeStamp();
                slidertime = nextK;
                t2 = timeStamp();
                if (nextK = returnNext playArray currentTime) != undefined and (nextDelay = getDelay playArray currentTime nextK animationRange.start animationRange.end spSettings[4]) != undefined then startPlay(); else stopPlay();
                print (format "It took this time for render: %\n" (t2 - t));
            )
        )
        else stopPlay();
     )
   
    on steppingUI open do ()
    on steppingUI close do ( playTm.active = false; )
)


 createDialog steppingUI width:200 height:166;

