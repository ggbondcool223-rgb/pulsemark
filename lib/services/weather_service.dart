import 'package:dio/dio.dart';

class WeatherService {
  static final Dio _dio = Dio();

  static const String _apiKey =
      '8eac5ab815355391afcfe604f5b71590';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>> getWeatherByCoords(
    double latitude,
    double longitude,
  ) async {
    try {
      print('WeatherService: Fetching weather for $latitude, $longitude');

      if (_apiKey == 'YOUR_API_KEY_HERE') {
        print('WeatherService: Using mock data (API key not set)');
        return _getMockWeather();
      }

      if (latitude == 0.0 && longitude == 0.0) {
        print('WeatherService: Invalid coordinates, using mock data');
        return _getMockWeather();
      }

      final response = await _dio.get(
        '$_baseUrl/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': _apiKey,
          'units': 'metric',
          'lang': 'en',
        },
      );

      print('WeatherService: API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final weatherData = {
          'success': true,
          'temperature': data['main']['temp'].round(),
          'weatherMain': data['weather'][0]['main'],
          'weatherDescription': data['weather'][0]['description'],
          'weatherIcon': data['weather'][0]['icon'],
          'humidity': data['main']['humidity'],
          'windSpeed': data['wind']['speed'],
        };
        print('WeatherService: Weather data fetched successfully');
        return weatherData;
      }

      print('WeatherService: API call failed, using mock data');
      return _getMockWeather();
    } catch (e) {
      print('WeatherService: Error: $e');
      return _getMockWeather();
    }
  }

  static Map<String, dynamic> _getMockWeather() {
    return {
      'success': true,
      'temperature': 22,
      'weatherMain': 'Clear',
      'weatherDescription': 'clear sky',
      'weatherIcon': '01d',
      'humidity': 65,
      'windSpeed': 3.5,
    };
  }

  static String getWeatherEmoji(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return '☀️';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌦️';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  static String getWeatherText(Map<String, dynamic> weatherData) {
    if (!weatherData['success']) {
      return 'Weather unavailable';
    }

    final temp = weatherData['temperature'];
    final emoji = getWeatherEmoji(weatherData['weatherIcon']);

    return '$emoji $temp°C';
  }
}
