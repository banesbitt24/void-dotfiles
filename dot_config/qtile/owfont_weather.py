#!/usr/bin/env python3
"""
OpenWeather font (owfont) integration for Qtile weather widget
Maps OpenWeatherMap API condition codes to owfont Unicode characters
"""

def get_owfont_icon(condition_code, is_day=True):
    """
    Get owfont Unicode character for weather condition code
    
    Args:
        condition_code (int): OpenWeatherMap weather condition code
        is_day (bool): Whether it's daytime (affects some icons)
    
    Returns:
        str: Unicode character for the weather icon
    """
    
    # Map condition codes to Unicode characters (from owfont CSS)
    icon_map = {
        # Thunderstorm
        200: "\uEB28",  # thunderstorm with light rain
        201: "\uEB29",  # thunderstorm with rain
        202: "\uEB2A",  # thunderstorm with heavy rain
        210: "\uEB32",  # light thunderstorm
        211: "\uEB33",  # thunderstorm
        212: "\uEB34",  # heavy thunderstorm
        221: "\uEB3D",  # ragged thunderstorm
        230: "\uEB46",  # thunderstorm with light drizzle
        231: "\uEB47",  # thunderstorm with drizzle
        232: "\uEB48",  # thunderstorm with heavy drizzle
        
        # Drizzle
        300: "\uEB8C",  # light intensity drizzle
        301: "\uEB8D",  # drizzle
        302: "\uEB8E",  # heavy intensity drizzle
        310: "\uEB96",  # light intensity drizzle rain
        311: "\uEB97",  # drizzle rain
        312: "\uEB98",  # heavy intensity drizzle rain
        313: "\uEB99",  # shower rain and drizzle
        314: "\uEB9A",  # heavy shower rain and drizzle
        321: "\uEBA1",  # shower drizzle
        
        # Rain
        500: "\uEC54",  # light rain
        501: "\uEC55",  # moderate rain
        502: "\uEC56",  # heavy intensity rain
        503: "\uEC57",  # very heavy rain
        504: "\uEC58",  # extreme rain
        511: "\uEC5F",  # freezing rain
        520: "\uEC68",  # light intensity shower rain
        521: "\uEC69",  # shower rain
        522: "\uEC6A",  # heavy intensity shower rain
        531: "\uEC73",  # ragged shower rain
        
        # Snow
        600: "\uECB8",  # light snow
        601: "\uECB9",  # snow
        602: "\uECBA",  # heavy snow
        611: "\uECC3",  # sleet
        612: "\uECC4",  # shower sleet
        615: "\uECC7",  # light rain and snow
        616: "\uECC8",  # rain and snow
        620: "\uECCC",  # light shower snow
        621: "\uECCD",  # shower snow
        622: "\uECCE",  # heavy shower snow
        
        # Atmosphere
        701: "\uED1D",  # mist
        711: "\uED27",  # smoke
        721: "\uED31",  # haze
        731: "\uED3B",  # sand/dust whirls
        741: "\uED45",  # fog
        751: "\uED4F",  # sand
        761: "\uED59",  # dust
        762: "\uED5A",  # volcanic ash
        771: "\uED63",  # squalls
        781: "\uED6D",  # tornado
        
        # Clear/Clouds - day/night variants
        800: "\uED80" if is_day else "\uF168",  # clear sky
        801: "\uED81" if is_day else "\uF169",  # few clouds
        802: "\uED82" if is_day else "\uF16A",  # scattered clouds
        803: "\uED83",  # broken clouds (same for day/night)
        804: "\uED84",  # overcast clouds (same for day/night)
        
        # Extreme
        900: "\uEDE4",  # tornado
        901: "\uEDE5",  # tropical storm
        902: "\uEDE6",  # hurricane
        903: "\uEDE7",  # cold
        904: "\uEDE8",  # hot
        905: "\uEDE9",  # windy
        906: "\uEDEA",  # hail
        
        # Additional
        950: "\uEE16",  # setting
        951: "\uED80" if is_day else "\uF168",  # calm (same as clear)
        952: "\uEE18",  # light breeze
        953: "\uEE19",  # gentle breeze
        954: "\uEE1A",  # moderate breeze
        955: "\uEE1B",  # fresh breeze
        956: "\uEE1C",  # strong breeze
        957: "\uEE1D",  # high wind, near gale
        958: "\uEE1E",  # gale
        959: "\uEE1F",  # severe gale
        960: "\uEE20",  # storm
        961: "\uEE21",  # violent storm
        962: "\uEE22",  # hurricane
    }
    
    return icon_map.get(condition_code, "\uED80")  # default to clear sky


def custom_weather_format(weather_data):
    """
    Custom formatter for Qtile OpenWeather widget using owfont icons
    
    Args:
        weather_data: Weather data from OpenWeather API
    
    Returns:
        str: Formatted weather string with owfont icon
    """
    if not weather_data:
        return "No weather data"
    
    # Extract condition code and determine if it's day
    try:
        condition_code = int(weather_data.get('id', 800))
        # OpenWeather API typically provides sunrise/sunset times
        # For now, we'll use a simple time-based approach
        import datetime
        current_hour = datetime.datetime.now().hour
        is_day = 6 <= current_hour < 20  # Rough day/night approximation
        
        icon = get_owfont_icon(condition_code, is_day)
        temp = weather_data.get('temp', 'N/A')
        description = weather_data.get('weather_details', weather_data.get('main', 'Unknown'))
        
        return f"{icon} {temp}°F {description}"
    
    except (ValueError, KeyError) as e:
        return f"Weather error: {e}"


if __name__ == "__main__":
    # Test the function
    test_data = {'id': 800, 'temp': 72, 'main': 'Clear', 'weather_details': 'Clear sky'}
    print(custom_weather_format(test_data))