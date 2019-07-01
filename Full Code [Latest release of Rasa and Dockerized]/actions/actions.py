import requests
import json
from rasa_sdk import Action


class ActionWeather(Action):
    def name(self):
        return 'action_weather4'

    def run(self, dispatcher, tracker, domain):
        api_key = '<YOUR API KEY>'

        location = tracker.get_slot('location')
        response = requests.get("http://api.apixu.com/v1/current.json?key={}&q={}".format(api_key, location)).json()

        country = response['location']['country']
        city = response['location']['name']
        condition = response['current']['condition']['text']
        temperature = response['current']['temp_c']
        humidity = response['current']['humidity']
        wind_mph = response['current']['wind_mph']

        message = """It is {} in {} at the moment. The temperature is {} degrees,
                     the humidity is {}% and the wind speed is {} mph.""".format(condition, city, temperature, humidity, wind_mph)

        dispatcher.utter_message(message)

        return []

