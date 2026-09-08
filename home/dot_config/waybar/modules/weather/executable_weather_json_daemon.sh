#!/bin/sh
# vim:set expandtab shiftwidth=4 filetype=sh:
# SPDX-License-Identifier: GPL-3.0-only

#
#
# ~chewygumxx/dotfiles.git
# ::: :/home/dot_config/waybar/modules/weather/executable_weather_json_daemon.sh
#
#

MODULE_DIR="$XDG_CONFIG_HOME/waybar/modules/weather"

OUTFILE="$MODULE_DIR/weather_out.json"
APIKEY=$(cat "$MODULE_DIR/open_weather_map.apikey")

CITY_NAME='Melbourne'
COUNTRY_CODE='AU'
OWM_LANG="en"
UNITS="metric"

# Display the weather description. yes/no
DISPLAY_LABEL="yes"

# Define name of city
if [ -z "$CITY_NAME" ]; then
    IP=$(curl -s --max-time 10 ifconfig.me)  # == ip
    IPCURL=$(curl -s --max-time 10 "https://ipinfo.io/$IP")
    CITY_NAME=$(echo "$IPCURL" | jq -r ".city")
    COUNTRY_CODE=$(echo "$IPCURL" | jq -r ".country")
fi

# Define units parameter for API query
if [ "$UNITS" = "kelvin" ]; then
    UNIT_URL=""
else
    UNIT_URL="&units=$UNITS"
fi

# Execute API request
RESPONSE=""
ERROR=0
ERR_MSG=""
URL="api.openweathermap.org/data/2.5/weather?appid=$APIKEY$UNIT_URL&lang=$OWM_LANG&q=$(echo "$CITY_NAME" | sed 's/ /%20/g'),${COUNTRY_CODE}"
getData() {
    ERROR=0

    RESPONSE=$(curl -s --max-time 10 "$URL")
    CODE="$?"
    if [ "$1" = "-d" ]; then
        echo "$RESPONSE"
        echo ""
    fi

    RESPONSECODE=0
    if [ "$CODE" -eq 0 ]; then
        RESPONSECODE=$(echo "$RESPONSE" | jq .cod)
    fi
    if [ "$CODE" -ne 0 ] || [ "${RESPONSECODE:=429}" -ne 200 ]; then
        if [ "$CODE" -ne 0 ]; then
            ERR_MSG="curl Error $CODE"
        else
            ERR_MSG="Conn. Err. $RESPONSECODE"
        fi
        ERROR=1
    fi
}

CSS_CLASS=""
# Define output format
setIcons() {
    if [ "$WID" -le 232 ]; then
        CSS_CLASS="thunder"
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ "$WID" -le 311 ]; then
        CSS_CLASS="light_rain"
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ "$WID" -le 321 ]; then
        CSS_CLASS="heavy_rain"
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ "$WID" -le 531 ]; then
        CSS_CLASS="rain"
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ "$WID" -le 622 ]; then
        CSS_CLASS="snow"
        ICON=""
    elif [ "$WID" -le 771 ]; then
        CSS_CLASS="fog"
        ICON=""
    elif [ "$WID" -eq 781 ]; then
        CSS_CLASS="tornado"
        ICON=""
    elif [ "$WID" -eq 800 ]; then
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            CSS_CLASS="sun"
            ICON=""
        else
            CSS_CLASS="moon"
            ICON=""
        fi
    elif [ "$WID" -eq 801 ]; then
        # Few clouds
        if [ "$DATE" -ge "$SUNRISE" ] && [ "$DATE" -le "$SUNSET" ]; then
            CSS_CLASS="sun"
            ICON=""
        else
            CSS_CLASS="moon"
            ICON=""
        fi
    elif [ "$WID" -le 804 ]; then
        CSS_CLASS="cloud"
        ICON=""
    else
        CSS_CLASS="error"
        ICON=""
    fi

    TEMP=$(echo "$TEMP" | cut -d "." -f 1)
}

outputCompact() {
    DESC_JSON="{\"text\": \"$DESCRIPTION\"}"
    ICON_JSON="{\"text\": \"$ICON\", \"class\": \"$CSS_CLASS\"}"
    TEMP_JSON="{\"text\": \"$TEMP°C\"}"

    echo "$DESC_JSON" > "$OUTFILE"
    echo "$ICON_JSON" >> "$OUTFILE"
    echo "$TEMP_JSON" >> "$OUTFILE"
}

weather_to_json() {
    getData "$1"
    if [ "$ERROR" -eq 0 ]; then
        MAIN=$(echo "$RESPONSE" | jq .weather[0].main)
        WID=$(echo "$RESPONSE" | jq .weather[0].id)
        DESC=$(echo "$RESPONSE" | jq .weather[0].description)
        SUNRISE=$(echo "$RESPONSE" | jq .sys.sunrise)
        SUNSET=$(echo "$RESPONSE" | jq .sys.sunset)
        DATE=$(date +%s)
        TEMP=$(echo "$RESPONSE" | jq .main.temp)
        if [ "$DISPLAY_LABEL" = "yes" ]; then
            DESCRIPTION="$(echo "$RESPONSE" | jq .weather[0].description | tr -d '"' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1') "
        else
            DESCRIPTION=""
        fi
        PRESSURE=$(echo "$RESPONSE" | jq .main.pressure)
        HUMIDITY=$(echo "$RESPONSE" | jq .main.humidity)
        setIcons
        outputCompact
        pkill -RTMIN+8 waybar >/dev/null 2>&1 || true
    else
        echo " "
    fi
}

while true; do
    echo "Executing API request"
    weather_to_json

    sleep 900
done
