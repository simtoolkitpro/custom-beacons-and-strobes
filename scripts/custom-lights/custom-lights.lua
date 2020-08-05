-- Daniel Gallacher 2020 - Public domain
-- custom-lights.lua for Customisable 

-- Strobe Pattern and Times
-- pattern_length should be automatically determined from table.getn(strobe_time_between) or #strobe_time_between but both values are returning 0
-- Will happily accept pull requests for a fix 
strobe_time_between = { 0.1, 3 } -- Alternates between these 2 values for the spacing between strobe pulses
pattern_length = 2 -- Number of entries above - essentially the length of strobe_time_between
strobe_time_on = 0.05 -- How long the strobe is lit for

-- Beacon Pattern and Times
beacon_time_between = 1 -- Time between beacon pulses
beacon_time_on = 1 -- Time the beacon is lit for

-- --------------------------------------------------------- 
-- All configuration should be done above this block
-- ---------------------------------------------------------

internal_timer = 0
strobe_pattern_index = 1
next_strobe_on_time = 0
next_strobe_off_time = 0
next_beacon_on_time = 0
next_beacon_off_time = 0

-- SIM_PERIOD 	- frame duration
-- IN_REPLAY 	- is in replay mode

-- Find and setup datarefs
override_beacons_and_strobes = find_dataref("sim/flightmodel2/lights/override_beacons_and_strobes")
strobe_on = find_dataref("sim/flightmodel2/lights/strobe_flash_now")

-- Checks made against this value as `if battery_on then / if battery_on == 1 then` both cause the script to fail 
battery_on = find_dataref("sim/cockpit/electrical/battery_on")

-- Switch states
switch_strobe_lights_on = find_dataref("sim/cockpit/electrical/strobe_lights_on")
switch_beacon_lights_on = find_dataref("sim/cockpit/electrical/beacon_lights_on")

-- Light value datarefs
strobe_brightness_ratio_1 = find_dataref("sim/flightmodel2/lights/strobe_brightness_ratio[0]")
strobe_brightness_ratio_2 = find_dataref("sim/flightmodel2/lights/strobe_brightness_ratio[1]")
strobe_brightness_ratio_3 = find_dataref("sim/flightmodel2/lights/strobe_brightness_ratio[2]")
strobe_brightness_ratio_4 = find_dataref("sim/flightmodel2/lights/strobe_brightness_ratio[3]")
beacon_brightness_ratio_1 = find_dataref("sim/flightmodel2/lights/beacon_brightness_ratio[0]")
beacon_brightness_ratio_2 = find_dataref("sim/flightmodel2/lights/beacon_brightness_ratio[1]")
beacon_brightness_ratio_3 = find_dataref("sim/flightmodel2/lights/beacon_brightness_ratio[2]")
beacon_brightness_ratio_4 = find_dataref("sim/flightmodel2/lights/beacon_brightness_ratio[3]")

-- Sim Callbacks
function flight_start()
end

function flight_crash()
end

function before_physics() -- Per Frame#
    if switch_strobe_lights_on == 1 then
        if internal_timer > next_strobe_on_time then
            strobe_brightness_ratio_1 = 1
            strobe_brightness_ratio_2 = 1
            strobe_brightness_ratio_3 = 1
            strobe_brightness_ratio_4 = 1
            strobe_on = 1
            next_strobe_on_time = internal_timer + strobe_time_between[strobe_pattern_index] + strobe_time_on
        end
        if internal_timer > next_strobe_off_time then
            strobe_brightness_ratio_1 = 0
            strobe_brightness_ratio_2 = 0
            strobe_brightness_ratio_3 = 0
            strobe_brightness_ratio_4 = 0
            strobe_on = 0
            next_strobe_off_time = internal_timer + strobe_time_between[strobe_pattern_index] + strobe_time_on

            strobe_pattern_index = strobe_pattern_index + 1
            if strobe_pattern_index > pattern_length then
                strobe_pattern_index = 1
            end
            
        end
    else 
        strobe_brightness_ratio_1 = 0
        strobe_brightness_ratio_2 = 0
        strobe_brightness_ratio_3 = 0
        strobe_brightness_ratio_4 = 0
        strobe_on = 0
    end
    
    if switch_beacon_lights_on then
        if internal_timer > next_beacon_on_time then
            beacon_brightness_ratio_1 = 1
            beacon_brightness_ratio_2 = 1
            beacon_brightness_ratio_3 = 1
            beacon_brightness_ratio_4 = 1
            next_beacon_on_time = internal_timer + beacon_time_between + beacon_time_on
        end
        if internal_timer > next_beacon_off_time then
            beacon_brightness_ratio_1 = 0
            beacon_brightness_ratio_2 = 0
            beacon_brightness_ratio_3 = 0
            beacon_brightness_ratio_4 = 0
            next_beacon_off_time = internal_timer + beacon_time_between + beacon_time_on
        end
    else 
        beacon_brightness_ratio_1 = 0
        beacon_brightness_ratio_2 = 0
        beacon_brightness_ratio_3 = 0
        beacon_brightness_ratio_4 = 0
    end
end

function after_physics() -- Per Frame
    -- log an internal timer
    internal_timer = internal_timer + SIM_PERIOD
end

function aircraft_load()
    -- Enable override
    override_beacons_and_strobes = 1

    -- Set the initial times for the lights
    next_strobe_on_time = internal_timer + 2
    next_strobe_off_time = next_strobe_on_time + strobe_time_on
    next_beacon_on_time = internal_timer + beacon_time_between
    next_beacon_off_time = next_beacon_on_time + beacon_time_on
end

function aircraft_unload()
    -- Disable override
    override_beacons_and_strobes = 0
end