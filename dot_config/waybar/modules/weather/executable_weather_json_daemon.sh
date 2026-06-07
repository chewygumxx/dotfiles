#!/bin/bash

# SETTINGS

MODULE_DIR="$XDG_CONFIG_HOME/waybar/modules/weather"

OUTFILE="$MODULE_DIR/weather_out.json"
APIKEY=`cat $MODULE_DIR/open_weather_map.apikey`

# if you leave these empty location will be picked based on your ip-adres
CITY_NAME='Melbourne'
COUNTRY_CODE='AU'

# Desired output language
LANG="en"

# UNITS can be "metric", "imperial" or "kelvin".
UNITS="metric"

# Color Settings ______________________________________________________________

COLOR_CLOUD="#aaaaaa"
COLOR_THUNDER="#d3b987"
COLOR_LIGHT_RAIN="#7171d3"
COLOR_HEAVY_RAIN="#b3deef"
COLOR_SNOW="#FFFFFF"
COLOR_FOG="#aaaaaa"
COLOR_TORNADO="#d3b987"
COLOR_SUN="#ffc24b"
COLOR_MOON="#cad6ff"
COLOR_ERR="#f43753"
COLOR_WIND="#73cef4"
COLOR_COLD="#b3deef"
COLOR_HOT="#f43753"
COLOR_NORMAL_TEMP="#cad6ff"

# Leave "" if you want the default polybar color
COLOR_TEXT=""
# Polybar settings ____________________________________________________________

# Font for the weather icons
WEATHER_FONT_CODE=4

# Font for the thermometer icon
TEMP_FONT_CODE=1

# Wind settings _______________________________________________________________

# Display info about the wind or not. yes/no
DISPLAY_WIND="no"

# Show beaufort level in windicon
BEAUFORTICON="yes"

# Display in knots. yes/no
KNOTS="yes"

# How many decimals after the floating point
DECIMALS=0

# Min. wind force required to display wind info (it depends on what
# measurement unit you have set: knots, m/s or mph). Set to 0 if you always
# want to display wind info. It's ignored if DISPLAY_WIND is false.

MIN_WIND=11

# Display the numeric wind force or not. If not, only the wind icon will
# appear. yes/no

DISPLAY_FORCE="yes"

# Display the wind unit if wind force is displayed. yes/no
DISPLAY_WIND_UNIT="yes"

# Thermometer settings ________________________________________________________

# When the thermometer icon turns red
HOT_TEMP=25

# When the thermometer icon turns blue
COLD_TEMP=10

# Other settings ______________________________________________________________

# Display the weather description. yes/no
DISPLAY_LABEL="yes"

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# Define text colour code
if [ "$COLOR_TEXT" != "" ]; then
    COLOR_TEXT_BEGIN="%{F$COLOR_TEXT}"
    COLOR_TEXT_END="%{F-}"
fi

# Define name of city
if [ -z "$CITY_NAME" ]; then
    IP=`curl -s ifconfig.me`  # == ip
    IPCURL=$(curl -s https://ipinfo.io/$IP)
    CITY_NAME=$(echo $IPCURL | jq -r ".city")
    COUNTRY_CODE=$(echo $IPCURL | jq -r ".country")
fi

# Define units parameter for API query
if [ $UNITS = "kelvin" ]; then
    UNIT_URL=""
else
    UNIT_URL="&units=$UNITS"
fi

# Execute API request
RESPONSE=""
ERROR=0
ERR_MSG=""
URL="api.openweathermap.org/data/2.5/weather?appid=$APIKEY$UNIT_URL&lang=$LANG&q=$(echo $CITY_NAME| sed 's/ /%20/g'),${COUNTRY_CODE}"
function getData {
    ERROR=0
	
    # Logging
    RESPONSE=`curl -s $URL`
    CODE="$?"
    if [ "$1" = "-d" ]; then
        echo $RESPONSE
        echo ""
    fi

    RESPONSECODE=0
    if [ $CODE -eq 0 ]; then
        RESPONSECODE=`echo $RESPONSE | jq .cod`
    fi
    if [ $CODE -ne 0 ] || [ ${RESPONSECODE:=429} -ne 200 ]; then
        if [ $CODE -ne 0 ]; then
            ERR_MSG="curl Error $CODE"
        else
            ERR_MSG="Conn. Err. $RESPONSECODE"
        fi
        ERROR=1
    fi
}

CSS_CLASS=""
# Define output format
function setIcons {
    if [ $WID -le 232 ]; then
        CSS_CLASS="thunder"
        if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ $WID -le 311 ]; then
        CSS_CLASS="light_rain"
        if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ $WID -le 321 ]; then
		CSS_CLASS="heavy_rain"
        if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ $WID -le 531 ]; then
		CSS_CLASS="rain"
        if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
            ICON=""
        else
            ICON=""
        fi
    elif [ $WID -le 622 ]; then
		CSS_CLASS="snow"
        ICON=""
    elif [ $WID -le 771 ]; then
		CSS_CLASS="fog"
        ICON=""
    elif [ $WID -eq 781 ]; then
		CSS_CLASS="tornado"
        ICON=""
    elif [ $WID -eq 800 ]; then
        if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
		CSS_CLASS="sun"
            ICON_COLOR=$COLOR_SUN
            ICON=""
        else
		CSS_CLASS="moon"
            ICON_COLOR=$COLOR_MOON
            ICON=""
        fi
    elif [ $WID -eq 801 ]; then
        # Few clouds
        if [ $DATE -ge $SUNRISE -a $DATE -le $SUNSET ]; then
			CSS_CLASS="sun"
            ICON=""
        else
			CSS_CLASS="moon"
            ICON=""
        fi
    elif [ $WID -le 804 ]; then
		CSS_CLASS="cloud"
        ICON=""
    else
		CSS_CLASS="error"
        ICON=""
    fi
    WIND=""
    WINDFORCE=`echo "$RESPONSE" | jq .wind.speed`
    WINDICON=""
    if [ $BEAUFORTICON == "yes" ];then
        WINDFORCE2=`echo "scale=$DECIMALS;$WINDFORCE * 3.6 / 1" | bc`
        if [ $WINDFORCE2 -le 1 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 1 ] && [ $WINDFORCE2 -le 5 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 5 ] && [ $WINDFORCE2 -le 11 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 11 ] && [ $WINDFORCE2 -le 19 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 19 ] && [ $WINDFORCE2 -le 28 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 28 ] && [ $WINDFORCE2 -le 38 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 38 ] && [ $WINDFORCE2 -le 49 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 49 ] && [ $WINDFORCE2 -le 61 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 61 ] && [ $WINDFORCE2 -le 74 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 74 ] && [ $WINDFORCE2 -le 88 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 88 ] && [ $WINDFORCE2 -le 102 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 102 ] && [ $WINDFORCE2 -le 117 ]; then
            WINDICON=""
        elif [ $WINDFORCE2 -gt 117 ]; then
            WINDICON=""
        fi
    fi
    if [ $KNOTS = "yes" ]; then
        case $UNITS in
            "imperial") 
                # The division by one is necessary because scale works only for divisions. bc is stupid.
                WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE * 0.8689762419 / 1" | bc`
                ;;
            *)
                WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE * 1.943844 / 1" | bc`
                ;;
        esac
    else
        if [ $UNITS != "imperial" ]; then
            # Conversion from m/s to km/h
            WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE * 3.6 / 1" | bc`
        else
            WINDFORCE=`echo "scale=$DECIMALS;$WINDFORCE / 1" | bc`
        fi
    fi
    if [ "$DISPLAY_WIND" = "yes" ] && [ `echo "$WINDFORCE >= $MIN_WIND" |bc -l` -eq 1 ]; then
        WIND="%{T$WEATHER_FONT_CODE}%{F$COLOR_WIND}$WINDICON%{F-}%{T-}"
        if [ $DISPLAY_FORCE = "yes" ]; then
            WIND="$WIND $COLOR_TEXT_BEGIN$WINDFORCE$COLOR_TEXT_END"
            if [ $DISPLAY_WIND_UNIT = "yes" ]; then
                if [ $KNOTS = "yes" ]; then
                    WIND="$WIND ${COLOR_TEXT_BEGIN}kn$COLOR_TEXT_END"
                elif [ $UNITS = "imperial" ]; then
                    WIND="$WIND ${COLOR_TEXT_BEGIN}mph$COLOR_TEXT_END"
                else
                    WIND="$WIND ${COLOR_TEXT_BEGIN}km/h$COLOR_TEXT_END"
                fi
            fi
        fi
        WIND="$WIND |"
    fi
    
    TEMP=`echo "$TEMP" | cut -d "." -f 1`
    
}
function outputCompact {
	DESC_JSON="{\"text\": \"$DESCRIPTION\"}"
	ICON_JSON="{\"text\": \"$ICON\", \"class\": \"$CSS_CLASS\"}"
	TEMP_JSON="{\"text\": \"$TEMP°C\"}"


	echo "$DESC_JSON" >  $OUTFILE
	echo "$ICON_JSON" >> $OUTFILE
	echo "$TEMP_JSON" >> $OUTFILE
}

function weather_to_json {
	getData $1
	if [ $ERROR -eq 0 ]; then
	    MAIN=`echo $RESPONSE | jq .weather[0].main`
	    WID=`echo $RESPONSE | jq .weather[0].id`
	    DESC=`echo $RESPONSE | jq .weather[0].description`
	    SUNRISE=`echo $RESPONSE | jq .sys.sunrise`
	    SUNSET=`echo $RESPONSE | jq .sys.sunset`
	    DATE=`date +%s`
	    WIND=""
	    TEMP=`echo $RESPONSE | jq .main.temp`
	    if [ $DISPLAY_LABEL = "yes" ]; then
	        DESCRIPTION=`echo "$RESPONSE" | jq .weather[0].description | tr -d '"' | awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'`" "
	    else
	        DESCRIPTION=""
	    fi
	    PRESSURE=`echo $RESPONSE | jq .main.pressure`
	    HUMIDITY=`echo $RESPONSE | jq .main.humidity`
	    setIcons
	    outputCompact
	else
	    echo " "
	fi
}

while true; do
	echo "Executing API request"
	weather_to_json

	sleep 900
done
