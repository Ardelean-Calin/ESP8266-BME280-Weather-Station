Instructions
------------
*Before executing the instructions below, make sure you created an account on
[**Ubidots**](http://www.ubidots.com) with three variables on it.*

The BME280 is, by default, assumed to be connected this way: 

**VCC** -> 3.3V

**SDA** -> GPIO13(aka pin no. 7)

**SCL** -> GPIO14(aka pin no. 5)

**GND** -> GND
<br>

Make sure your ESP8266 has a version of NodeMCU with the following modules installed:
*bme280, file, gpio, http, i2c, net, node, tmr, uart, wifi*.
Some, such as *http* might not be needed, however this is the configuration I had on my ESP8266.


Using the Lua interactive prompt, **make sure you configure your Wi-Fi connectivity**
so that the settings get saved on the ESP8266 flash. This can be done with the following commands:

```lua
wifi.setmode(wifi.STATION)
-- wifi.setphymode(wifi.PHYMODE_B)  -- Optional, longer range but less battery life
wifi.sta.config(your_ssid, ssid_password, 0)  -- 0 means no autoconnect
```

***NOTE:*** All the above settings are **persistent**. Even after restart, these commands do not need to be set again.
This is why you don't see them anywhere in the *init.lua* again. 
See [**the wifi module's documentation**](https://nodemcu.readthedocs.io/en/master/en/modules/wifi/)
for more info.


Edit the *init.lua* file with your details. To get the *temp_url*, *pres_url* and *humi_url* for
your case, navigate to your Ubidots dashboard and click the **API credentials** button:

![API Credentials button](https://i.imgur.com/aTj6vp0.png)

Then copy your default Token from there:

![Token](https://i.imgur.com/LepFlxl.png)

You also need the **label** of your **variable source**:

![Variable source](https://i.imgur.com/0fdP7lr.png)

As well as the **label** of each variable:

![Variable label](https://i.imgur.com/cOeCtJf.png)

Now form the **URL** for each variable like this:

<pre><code>
<i>http://things.ubidots.com/api/1.6/devices/</i><b>device_label</b><i>/</i><b>variable_label</b><i>/values?token=</i><b>your_token</b>
</code></pre>

Replace each URL in the *init.lua* file. For more details, see [**how to send data to Ubidots**](https://ubidots.com/docs/api/#send-values).


**Finally**, using a tool like [**NodeMCU Uploader**](https://github.com/kmpm/nodemcu-uploader), 
upload the *init.lua* file to the ESP8266 and then restart the device. 

```bash
nodemcu-uploader upload init.lua
```

Your weather station should now work.
