class AccidentPrediction {
  final double latitude;
  final double longitude;
  final String weather;
  final int age;
  final String typeOfVehicle;
  final String roadType;
  final String timeOfDay;
  final double trafficDensity;
  final int speedLimit;
  final int numberOfVehicles;
  final double driverAlcohol;
  final String accidentSeverity;
  final String roadCondition;
  final String vehicleType;
  final int driverAge;
  final int driverExperience;
  final String roadLightCondition;
  final int hour;
  final int day;
  final int month;
  final int dayOfWeek;

  AccidentPrediction({
    required this.latitude,
    required this.longitude,
    required this.weather,
    required this.age,
    required this.typeOfVehicle,
    required this.roadType,
    required this.timeOfDay,
    required this.trafficDensity,
    required this.speedLimit,
    required this.numberOfVehicles,
    required this.driverAlcohol,
    required this.accidentSeverity,
    required this.roadCondition,
    required this.vehicleType,
    required this.driverAge,
    required this.driverExperience,
    required this.roadLightCondition,
    required this.hour,
    required this.day,
    required this.month,
    required this.dayOfWeek,
  });

  Map<String, dynamic> toJson() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
      'Weather': weather,
      'Age': age,
      'Type_of_Vehicle': typeOfVehicle,
      'Road_Type': roadType,
      'Time_of_Day': timeOfDay,
      'Traffic_Density': trafficDensity,
      'Speed_Limit': speedLimit,
      'Number_of_Vehicles': numberOfVehicles,
      'Driver_Alcohol': driverAlcohol,
      'Accident_Severity': accidentSeverity,
      'Road_Condition': roadCondition,
      'Vehicle_Type': vehicleType,
      'Driver_Age': driverAge,
      'Driver_Experience': driverExperience,
      'Road_Light_Condition': roadLightCondition,
      'Hour': hour,
      'Day': day,
      'Month': month,
      'DayOfWeek': dayOfWeek,
    };
  }

  factory AccidentPrediction.fromJson(Map<String, dynamic> json) {
    return AccidentPrediction(
      latitude: json['Latitude'].toDouble(),
      longitude: json['Longitude'].toDouble(),
      weather: json['Weather'],
      age: json['Age'],
      typeOfVehicle: json['Type_of_Vehicle'],
      roadType: json['Road_Type'],
      timeOfDay: json['Time_of_Day'],
      trafficDensity: json['Traffic_Density'].toDouble(),
      speedLimit: json['Speed_Limit'],
      numberOfVehicles: json['Number_of_Vehicles'],
      driverAlcohol: json['Driver_Alcohol'].toDouble(),
      accidentSeverity: json['Accident_Severity'],
      roadCondition: json['Road_Condition'],
      vehicleType: json['Vehicle_Type'],
      driverAge: json['Driver_Age'],
      driverExperience: json['Driver_Experience'],
      roadLightCondition: json['Road_Light_Condition'],
      hour: json['Hour'],
      day: json['Day'],
      month: json['Month'],
      dayOfWeek: json['DayOfWeek'],
    );
  }
}
