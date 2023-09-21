//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Jonathan Clem on 9/21/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var isNight = false
    @State var mainWeatherItem = WeatherItem.startingWeatherSet()[0]
    @State var weatherItems = WeatherItem.startingWeatherSet() {
        didSet {
            mainWeatherItem = weatherItems[0]
        }
    }

    var body: some View {
        ZStack {
            BackgroundView(isNight: $isNight)
            VStack {
                CityTextView(cityName: "Kyle, TX")
                MainWeatherStatusView(isNight: $isNight, weatherItem: mainWeatherItem)
                
                HStack(spacing: 20) {
                    ForEach(weatherItems) { item in
                        WeatherDayView(dayOfWeek: item.dayOfWeek,
                                       imageName: item.imageName,
                                       temperature: item.temperature)
                    }
                }

                Spacer()
                
                Button {
                    isNight.toggle()
                } label: {
                    WeatherButton(title: "Change Day Time",
                                  textColor: .blue,
                                  backgroundColor: .white)
                }
                
                Button {
                    Task {
                        await weatherItems = try WeatherItem.getUpdatedWeather()
                    }
                } label: {
                    WeatherButton(title: "Update Weather",
                                  textColor: .blue,
                                  backgroundColor: .white)
                }
                
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct WeatherDayView: View {
    
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text(dayOfWeek)
                .foregroundColor(.white)
                .font(.system(size:16, weight: .medium))
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temperature)°")
                .foregroundColor(.white)
                .font(.system(size: 28, weight: .medium))
        }
    }
}

struct BackgroundView: View {
    
    @Binding var isNight: Bool
    
    var body: some View {
        LinearGradient(colors: [isNight ? .black : .blue, isNight ? .gray : Color("lightBlue")],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
        .edgesIgnoringSafeArea(.all)
    }
}

struct CityTextView: View {
    
    var cityName: String
    
    var body: some View {
        Text(cityName)
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}

struct MainWeatherStatusView: View {
    
    @Binding var isNight: Bool
    var weatherItem: WeatherItem
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: isNight ? "moon.fill" : weatherItem.imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            Text("\(weatherItem.temperature)°")
                .font(.system(size: 70, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40)
    }
}
