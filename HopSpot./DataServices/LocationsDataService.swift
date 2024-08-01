//
//  LocationsDataService.swift
//  MapTest
//
//  Created by Nick Sarno on 11/26/21.
//

import Foundation
import MapKit

class LocationsDataService {
    
    static let locations: [Location] = [
        
        Location(
            name: "Pub on King",
            cityName: "Waterloo, On",
            coordinates: CLLocationCoordinate2D(latitude: 43.46786857299198, longitude: -80.5232645128924),
            description: "Pub grub & daily drink specials in a British-style gathering place with dark wood paneling..",
            imageNames: [
                "pubonking1",
                
            ],
            link: "https://www.thepubonking.com/index.html"),
        Location(
            name: "Phil's Grandson",
            cityName: "Waterloo, On",
            coordinates: CLLocationCoordinate2D(latitude: 43.475334511323375, longitude: -80.52403574643947),
            description: "Smaller, hopping nightspot in operation since 1988 with cocktails, DJs & a dance floor.",
            imageNames: [
                "phils",
                
            ],
            link: "https://www.philsgrandsons.com/"),
        Location(
            name: "Kentucky Bourbon & BBQ",
            cityName: "Waterloo, On",
            coordinates: CLLocationCoordinate2D(latitude: 43.468911911447954, longitude: -80.52377773702925),
            description: "Located in the heart of Uptown Waterloo, Kentucky Bourbon and Barbecue brings a taste of the south and all its delicious smokey flavours right to your home town.",
            imageNames: [
                "kentucky",
               
            ],
            link: "https://www.kentuckywaterloo.com/"),
        Location(
            name: "The Drink Uptown",
            cityName: "Waterloo, On",
            coordinates: CLLocationCoordinate2D(latitude: 43.46715271027447, longitude: -80.52246975910477),
            description: "Uptown Waterloo's Student Playground!",
            imageNames: [
                "drinkuptown",
                
            ],
            link: "https://www.thedrinkuptown.com/"),
        Location(
            name: "Prohibtion Warehouse",
            cityName: "Waterloo, On",
            coordinates: CLLocationCoordinate2D(latitude: 43.467153110804084, longitude: -80.5223065168987),
            description: "Back in the roaring twenties, certain entrepreneurial types decided to quench America's Prohibition born-thirst, and the very location of The Prohibition Warehouse was once used to load liquor onto trucks for out-of-town secret destinations. But that's all over now, today you can enjoy twists on classic comfort foods with gourmet wood fired pizzas prepared daily with fresh ingredients. Accompany your meal with a wide selection of 24 rotating craft beers on tap or some delicious whisky inspired cocktails.",
            imageNames: [
                "pro",
                
            ],
            link: "https://www.prohibitionwarehouse.com/"),
    ]
    
}
