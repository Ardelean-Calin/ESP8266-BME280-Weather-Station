P = nil
T = nil
H = nil

temperature = nil
pressure = nil
humidity = nil

-- See https://ubidots.com/docs/api/#send-values for YOUR URLs
temp_url = "http://your-temperature-url-and-token-here"
pres_url = "http://your-pressure-url-and-token-here"
humi_url = "http://your-humidity-url-and-token-here"


function goto_sleep()
    -- Puts the ESP8266 into DeepSleep mode
    node.dsleep(1800000000) -- 30 minutes
end


function post_humi()
    http.post(humi_url, 'Content-Type: application/json\r\n', humidity, function() node.task.post(goto_sleep) end)
end


function post_pres()
    http.post(pres_url, 'Content-Type: application/json\r\n', pressure, function() node.task.post(post_humi) end)
end


function start_posting()
    http.post(temp_url, 'Content-Type: application/json\r\n', temperature, function() node.task.post(post_pres) end)
end


function connected()
    -- Managed to connect to WiFi Network
    -- Send data to Ubidots
    temperature = string.format('{"value": "%.2f"}', T)
    pressure = string.format('{"value": "%.1f"}', P)
    humidity = string.format('{"value": "%.2f"}', H)

    start_posting()
end


function diconnected()
    -- Didn't manage to connect to WiFi Network => deepsleep
    -- This callback gets called every second or so if no
    -- connection can be created as the ESP tries continously
    -- to establish a connection => I could implement a "tries"
    -- mechanism
    goto_sleep()
end


function parse_data()
    H, T = bme280.humi()
    P, T = bme280.baro()

    P = P/1000 -- Pressure in kPa
    H = H/1000 -- Humidity in %
    T = T/100 -- Temperature in degrees C
    -- Register WiFi events
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, connected)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, disconnected)
    -- And attempt to connect to send Data
    wifi.sta.connect()
end


-- First take measurment => heating of ESP won't affect
bme280.init(7, 5, 5, 5, 5, 2, 0, 0) -- Forced, 16x over, no_delay, filter off
-- Giving it a delay of 0 <=> 113ms delay
bme280.startreadout(0, parse_data)
