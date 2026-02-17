#!/usr/bin/env python3
"""
Custom Weather Widget with owfont icons for Qtile
"""

import requests
import json
import datetime
from libqtile.widget import base
from owfont_weather import get_owfont_icon


class OwfontWeatherWidget(base.ThreadPoolText):
    """Custom weather widget using owfont icons"""
    
    defaults = [
        ('app_key', None, 'OpenWeatherMap API key'),
        ('cityid', None, 'City ID for OpenWeatherMap'),
        ('metric', False, 'True for Celsius, False for Fahrenheit'),
        ('update_interval', 1800, 'Update interval in seconds (30 minutes)'),
        ('font', 'owfont', 'Font family'),
        ('fontsize', 16, 'Font size'),
    ]
    
    def __init__(self, **config):
        base.ThreadPoolText.__init__(self, "", **config)
        self.add_defaults(OwfontWeatherWidget.defaults)
        
    def poll(self):
        """Poll weather data from OpenWeatherMap API"""
        try:
            if not self.app_key or not self.cityid:
                return "Weather: Missing API key or city ID"
            
            # Build API URL
            units = "metric" if self.metric else "imperial"
            temp_unit = "°C" if self.metric else "°F"
            
            url = f"http://api.openweathermap.org/data/2.5/weather?id={self.cityid}&appid={self.app_key}&units={units}"
            
            # Make API request
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            
            data = response.json()
            
            # Extract data
            temp = round(data['main']['temp'])
            condition_code = data['weather'][0]['id']
            description = data['weather'][0]['description'].title()
            
            # Determine if it's day or night
            current_time = datetime.datetime.now().timestamp()
            sunrise = data['sys']['sunrise']
            sunset = data['sys']['sunset']
            is_day = sunrise <= current_time <= sunset
            
            # Get owfont icon
            icon = get_owfont_icon(condition_code, is_day)
            
            return f"{icon} {temp}{temp_unit} {description}"
            
        except requests.RequestException as e:
            return f"Weather: Network error - {str(e)[:20]}..."
        except KeyError as e:
            return f"Weather: Data error - {str(e)[:20]}..."
        except Exception as e:
            return f"Weather: Error - {str(e)[:20]}..."