# OpenStreetMap Data in Layered GIS Format

## Point Features

### 1. Places (“places”)

Location for cities, towns, etc. Typically somewhere in the centre of the town.

Additional attributes:

| Attribute  | PostGIS Type | Description                           | OSM Tags     |
| ---------- | ------------ | ------------------------------------- | ------------ |
| population | INTEGER      | Number of people living in this place | population=* |

Note that for many places the population is not available and will be set to 0. For islands the population is always 0.

The following feature classes exist in this layer:

| code | Layer | fclass | Description                                                  | OSM Tags                  |
| ---- | ----- | ------ | ------------------------------------------------------------ | ------------------------- |
| 1000 | place |        |                                                              |                           |
| 1001 | place | city   | As defined by national/state/provincial government. Often over 100,000 people | place=city (but see 1005) |                       |
| 1002 | place | town   | As defined by national/state/provincial government. Generally smaller than a city, between 10,000 and 100,000 people | place=town                |

| code | Layer | fclass           | Description                                                  | OSM Tags                                                     |
| ---- | ----- | ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1003 | place | village          | As defined by national/state/provincial government. Generally smaller than a town, below 10,000 people | place=village                                                |                                                          |
| 1004 | place | hamlet           | As defined by national/state/provincial government. Generally smaller than a village, just a few houses | place=hamlet                                                 |                                                           |
| 1005 | place | national_capital | A national capital                                           | place=city<br />- is_capital=country or<br />- admin_level=2 or<br />- capital=yes and no <br />admin_level set |                                                           |
| 1010 | place | suburb           | Named area of town or city                                   | place=suburb                                                 |
| 1020 | place | island           | Identifies an island                                         | place=island                                                 |
| 1030 | place | farm             | Named farm                                                   | place=farm                                                   |
| 1031 | place | dwelling         | Isolated dwelling (1 or 2 houses, smaller than hamlet)       | place=isolated_dwelling                                      |
| 1040 | place | region           | A region label (used in some areas only)                     | place=region                                                 |
| 1041 | place | county           | A county label (used in some areas only)                     | place=county                                                 |
| 1050 | place | locality         | Other kind of named place                                    | place=locality                                               |

### 2. Points of Interest

The following feature classes exist in this layer:

| code | layer  | fclass           | Description                                                  | OSM Tags                               |
| ---- | ------ | ---------------- | ------------------------------------------------------------ | -------------------------------------- |
| 20xx | public |                  |                                                              |                                        |
| 2001 |        | police           | A police post or station.                                    | amenity=police                         |
| 2002 |        | fire_station     | A fire station.                                              | amenity=fire_station                   |
| 2004 |        | post_box         | A post box (for letters).                                    | amenity=post_box                       |
| 2005 |        | post_office      | A post office.                                               | amenity=post_office                    |
| 2006 |        | telephone        | A public telephone booth.                                    | amenity=telephone                      |
| 2007 |        | library          | A library.                                                   | amenity=library                        |
| 2008 |        | town_hall        | A town hall.                                                 | amenity=townhall                       |
| 2009 |        | courthouse       | A court house.                                               | amenity=courthouse                     |
| 2010 |        | prison           | A prison.                                                    | amenity=prison                         |
| 2011 |        | embassy          | An embassy or consulate.                                     | amenity=embassy or office=diplomatic   |
| 2012 |        | community_centre | A public facility which is mostly used by local associations for events and festivities. | amenity=community_centre               |
| 2013 |        | nursing_home     | A home for disabled or elderly persons who need permanent care. | amenity=nursing_home                   |
| 2014 |        | arts_centre      | A venue at which a variety of arts are performed or conducted, and may well be involved with the creation of those works, and run occasional courses. | amenity=arts_centre                    |
| 2015 |        | graveyard        | A graveyard.                                                 | amenity=grave_yard or landuse=cemetery |

| code | layer   | fclass            | Description                                                  | OSM Tags                                                     |
| ---- | ------- | ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 2016 |         | market_place      | A place where markets are held.                              | amenity=marketplace                                          |
| 2030 |         | recycling         | A place (usually a container) where you can drop waste for recycling. | amenity=recycling                                            |
| 2031 |         | recycling_glass   | A place for recycling glass.                                 | recycling:glass=yes or recycling:glass_bottles=yes           |
| 2032 |         | recycling_paper   | A place for recycling paper.                                 | recycling:paper=yes                                          |
| 2033 |         | recycling_clothes | A place for recycling clothes.                               | recycling:clothes=yes                                        |
| 2034 |         | recycling_metal   | A place for recycling metal.                                 | recycling:scrap_metal=yes                                    |
| 208x |         |                   | Education                                                    |                                                              |
| 2081 |         | university        | A university.                                                | amenity=university                                           |
| 2082 |         | school            | A school.                                                    | amenity=school                                               |
| 2083 |         | kindergarten      | A kindergarten (nursery).                                    | amenity=kindergarten                                         |
| 2084 |         | college           | A college.                                                   | amenity=college                                              |
| 2099 |         | public_building   | An unspecified public building.                              | amenity=public_building                                      |
| 21xx | health  |                   |                                                              |                                                              |
| 2101 |         | pharmacy          | A pharmacy.                                                  | amenity=pharmacy                                             |
| 2110 |         | hospital          | A hospital.                                                  | amenity=hospital                                             |
| 2111 |         | clinic            | A medical centre that does not admit inpatients.             | amenity=clinic                                               |
| 2120 |         | doctors           | A medical practice.                                          | amenity=doctors                                              |
| 2121 |         | dentist           | A dentist's practice.                                        | amenity=dentist                                              |
| 2129 |         | veterinary        | A veterinary (animal doctor).                                | amenity=veterinary                                           |
| 22xx | leisure |                   |                                                              |                                                              |
| 2201 |         | theatre           | A theatre.                                                   | amenity=theatre                                              |
| 2202 |         | nightclub         | A night club, or disco.                                      | amenity=nightclub                                            |
| 2203 |         | cinema            | A cinema.                                                    | amenity=cinema                                               |
| 2204 |         | park              | A park.                                                      | leisure=park                                                 |
| 2205 |         | playground        | A playground for children.                                   | leisure=playground                                           |
| 2206 |         | dog_park          | An area where dogs are allowed to run free without a leash.  | leisure=dog_park                                             |
| 225x |         |                   | Sports                                                       |                                                              |
| 2251 |         | sports_centre     | A facility where a range of sports activities can be pursued. | leisure=sports_centre                                        |
| 2252 |         | pitch             | An area set aside for a specific sport.                      | leisure=pitch                                                |
| 2253 |         | swimming_pool     | A swimming pool or water park.                               | amenity=swimming_pool,leisure=swimming_pool,sport=swimming, leisure=water_park |
| 2254 |         | tennis_court      | A tennis court.                                              | sport=tennis                                                 |
| 2255 |         | golf_course       | A golf course.                                               | leisure=golf_course                                          |
| 2256 |         | stadium           | A stadium. The area of the stadium may contain one or several pitches. | leisure=stadium                                              |
| 2257 |         | ice_rink          | An ice rink.                                                 | leisure=ice_rink                                             |

| code | layer         | fclass            | Description                                                  | OSM Tags                  |
| ---- | ------------- | ----------------- | ------------------------------------------------------------ | ------------------------- |
| 23xx | catering      |                   | Catering services                                            |                           |
| 2301 |               | restaurant        | A normal restaurant.                                         | amenity=restaurant        |
| 2302 |               | fast_food         | A fast-food restaurant.                                      | amenity=fast_food         |
| 2303 |               | cafe              | A cafe.                                                      | amenity=cafe              |
| 2304 |               | pub               | A pub.                                                       | amenity=pub               |
| 2305 |               | bar               | A bar. The difference between a pub and a bar is not clear but pubs tend to offer food while bars do not. | amenity=bar               |
| 2306 |               | food_court        | A common seating area with various fast-food vendors.        | amenity=food_court        |
| 2307 |               | biergarten        | An open-air area where food and drinks are served.           | amenity=biergarten        |
| 24xx | accommodation |                   | (indoor)                                                     |                           |
| 2401 |               | hotel             | A hotel.                                                     | tourism=hotel             |
| 2402 |               | motel             | A motel.                                                     | tourism=motel             |
| 2403 |               | bed_and_breakfast | A facility offering bed and breakfast.                       | tourism=bed_and_breakfast |
| 2404 |               | guesthouse        | A guesthouse. The difference between hotel, bed and breakfast, and guest houses is not a strict one and OSM tends to use whatever the facility calls itself. | tourism=guest_house       |
| 2405 |               | hostel            | A hostel (offering cheap accommodation, often bunk beds in dormitories). | tourism=hostel            |
| 2406 |               | chalet            | A detached cottage, usually self-catering.                   | tourism=chalet            |
| 2420 |               |                   | (outdoor)                                                    |                           |
| 2421 |               | shelter           | All sorts of small shelters to protect against bad weather conditions. | amenity=shelter           |
| 2422 |               | camp_site         | A camp site or camping ground.                               | tourism=camp_site         |
| 2423 |               | alpine_hut        | An alpine hut is a building typically situated in mountains providing shelter and often food and beverages to visitors. | tourism=alpine_hut        |
| 2424 |               | caravan_site      | A place where people with caravans or motorhomes can stay overnight or longer. | tourism=caravan_site      |
| 25xx | shopping      |                   |                                                              |                           |
| 2501 |               | supermarket       | A supermarket.                                               | shop=supermarket          |
| 2502 |               | bakery            | A bakery.                                                    | shop=bakery               |
| 2503 |               | kiosk             | A very small shop usually selling cigarettes, newspapers, sweets, snacks and beverages. | shop=kiosk                |
| 2504 |               | mall              | A shopping mall.                                             | shop=mall                 |
| 2505 |               | department_store  | A department store.                                          | shop=department_store     |

| code | layer | fclass            | Description                                                  | OSM Tags                         |
| ---- | ----- | ----------------- | ------------------------------------------------------------ | -------------------------------- |
| 2510 |       | general           | A general store, offering a broad range of products on a small area. Exists usually in rural and remote areas. | shop=general                     |
| 2511 |       | convenience       | A convenience store is a small shop selling a subset of items you might find at a supermarket. | shop=convenience                 |
| 2512 |       | clothes           | A clothes or fashion store.                                  | shop=clothes                     |
| 2513 |       | florist           | A store selling flowers.                                     | shop=florist                     |
| 2514 |       | chemist           | A shop selling articles of personal hygiene, cosmetics, and household cleaning products. | shop=chemist                     |
| 2515 |       | bookshop          | A book shop.                                                 | shop=books                       |
| 2516 |       | butcher           | A butcher.                                                   | shop=butcher                     |
| 2517 |       | shoe_shop         | A shoe shop.                                                 | shop=shoes                       |
| 2518 |       | beverages         | A place where you can buy alcoholic and non-alcoholic beverages. | shop=alcohol, shop=beverages     |
| 2519 |       | optician          | A place where you can buy glasses.                           | shop=optician                    |
| 2520 |       | jeweller          | A jewelry shop.                                              | shop=jewelry                     |
| 2521 |       | gift_shop         | A gift shop.                                                 | shop=gift                        |
| 2522 |       | sports_shop       | A shop selling sports equipment.                             | shop=sports                      |
| 2523 |       | stationery        | A shop selling stationery for private and office use.        | shop=stationery                  |
| 2524 |       | outdoor_shop      | A shop selling outdoor equipment.                            | shop=outdoor                     |
| 2525 |       | mobile_phone_shop | A shop for mobile phones.                                    | shop=mobile_phone                |
| 2526 |       | toy_shop          | A toy store.                                                 | shop=toys                        |
| 2527 |       | newsagent         | A shop selling mainly newspapers and magazines.              | shop=newsagent                   |
| 2528 |       | greengrocer       | A shop selling fruit and vegetables.                         | shop=greengrocer                 |
| 2529 |       | beauty_shop       | A shop that provides personal beauty services like a nail salon or tanning salon. | shop=beauty                      |
| 2530 |       | video_shop        | A place where you can buy films.                             | shop=video                       |
| 2541 |       | car_dealership    | A car dealership.                                            | shop=car                         |
| 2542 |       | bicycle_shop      | A bicycle shop.                                              | shop=bicycle                     |
| 2543 |       | doityourself      | A do-it-yourself shop where you can buy tools and building materials. | shop=doityourself, shop=hardware |
| 2544 |       | furniture_shop    | A furniture store.                                           | shop=furniture                   |
| 2546 |       | computer_shop     | A computer shop.                                             | shop=computer                    |
| 2547 |       | garden_centre     | A place selling plants and gardening goods.                  | shop=garden_centre               |
| 2561 |       | hairdresser       | A hair salon.                                                | shop=hairdresser                 |
| 2562 |       | car_repair        | A car garage.                                                | shop=car_repair                  |
| 2563 |       | car_rental        | A place where you can rent a car.                            | amenity=car_rental               |
| 2564 |       | car_wash          | A car wash.                                                  | amenity=car_wash                 |
| 2565 |       | car_sharing       | A car sharing station.                                       | amenity=car_sharing              |

| code | layer   | fclass            | Description                                                  | OSM Tags                                   |
| ---- | ------- | ----------------- | ------------------------------------------------------------ | ------------------------------------------ |
| 2566 |         | bicycle_rental    | A place where you can rent bicycles.                         | amenity=bicycle_rental                     |
| 2567 |         | travel_agent      | A travel agency.                                             | shop=travel_agency                         |
| 2568 |         | laundry           | A place where you can wash clothes or have them cleaned.     | shop=laundry, shop=dry_cleaning            |
| 2590 |         | vending_machine   | An unspecified vending machine with none of the specifics below. | amenity=vending_machine                    |
| 2591 |         | vending_cigarette | A cigarette vending machine.                                 | vending=cigarettes                         |
| 2592 |         | vending_parking   | A vending machine for parking tickets.                       | vending=parking_tickets                    |
| 2600 | money   |                   |                                                              |                                            |
| 2601 |         | bank              | A bank.                                                      | amenity=bank                               |
| 2602 |         | atm               | A machine that lets you withdraw cash from your bank account. | amenity=atm                                |
| 2700 | tourism |                   | information                                                  |                                            |
| 2701 |         | tourist_info      | Something that provides information to tourists; may or may not be manned. | tourism=information                        |
| 2704 |         | tourist_map       | A map displayed to inform tourists.                          | tourism=information, information=map       |
| 2705 |         | tourist_board     | A board with explanations aimed at tourists.                 | tourism=information, information=board     |
| 2706 |         | tourist_guidepost | A guide post.                                                | tourism=information, information=guidepost |
|      |         |                   | destinations                                                 |                                            |
| 2721 |         | attraction        | A tourist attraction.                                        | tourism=attraction                         |
| 2722 |         | museum            | A museum.                                                    | tourism=museum                             |
| 2723 |         | monument          | A monument.                                                  | historic=monument                          |
| 2724 |         | memorial          | A memorial.                                                  | historic=memorial                          |
| 2725 |         | art               | A permanent work of art.                                     | tourism=artwork                            |
| 2731 |         | castle            | A castle.                                                    | historic=castle                            |
| 2732 |         | ruins             | Ruins of historic significance.                              | historic=ruins                             |
| 2733 |         | archaeological    | An excavation site.                                          | historic=archaeological_site               |
| 2734 |         | wayside_cross     | A wayside cross, not necessarily old.                        | historic=wayside_cross                     |
| 2735 |         | wayside_shrine    | A wayside shrine.                                            | historic=wayside_shrine                    |
| 2736 |         | battlefield       | A historic battlefield.                                      | historic=battlefield                       |
| 2737 |         | fort              | A fort.                                                      | historic=fort                              |
| 2741 |         | picnic_site       | A picnic site.                                               | tourism=picnic_site                        |
| 2742 |         | viewpoint         | A viewpoint.                                                 | tourism=viewpoint                          |
| 2743 |         | zoo               | A zoo.                                                       | tourism=zoo                                |
| 2744 |         | theme_park        | A theme park.                                                | tourism=theme_park                         |
| 2900 | miscpoi |                   |                                                              |                                            |
| 2901 |         | toilet            | Public toilets.                                              | amenity=toilets                            |
| 2902 |         | bench             | A public bench.                                              | amenity=bench                              |
| 2903 |         | drinking_water    | A tap or other source of drinking water.                     | amenity=drinking_water                     |

| code | layer | fclass              | Description                                                  | OSM Tags                                       |
| ---- | ----- | ------------------- | ------------------------------------------------------------ | ---------------------------------------------- |
| 2904 |       | fountain            | A fountain for cultural, decorative, or recreational purposes. | amenity=fountain                               |
| 2905 |       | hunting_stand       | A hunting stand.                                             | amenity=hunting_stand                          |
| 2906 |       | waste_basket        | A waste basket.                                              | amenity=waste_basket                           |
| 2907 |       | camera_surveillance | A surveillance camera.                                       | man_made=surveillance                          |
| 2921 |       | emergency_phone     | An emergency telephone.                                      | amenity=emergency_phone, emergency=phone       |
| 2922 |       | fire_hydrant        | A fiery hydrant.                                             | amenity=fire_hydrant, emergency=fire_hydrant   |
| 2923 |       | emergency_access    | An emergency access point (signposted place in e.g., woods the location of which is known to emergency services). | highway=emergency_access_point                 |
| 2950 |       | tower               | A tower of some kind.                                        | man_made=tower and none of the specifics below |
| 2951 |       | tower_comms         | A communications tower.                                      | man_made=tower and tower:type=communication    |
| 2952 |       | water_tower         | A water tower.                                               | man_made=water_tower                           |
| 2953 |       | tower_observation   | An observation tower.                                        | man_made=tower and tower:type=observation      |
| 2954 |       | windmill            | A windmill.                                                  | man_made=windmill                              |
| 2955 |       | lighthouse          | A lighthouse.                                                | man_made=lighthouse                            |
| 2961 |       | wastewater_plant    | A wastewater treatment plant.                                | man_made=wastewater_plant                      |
| 2962 |       | water_well          | A facility to access underground aquifers.                   | man_made=water_well                            |
| 2963 |       | water_mill          | A mill driven by water. Often historic.                      | man_made=watermill                             |
| 2964 |       | water_works         | A place where drinking water is processed.                   | man_made=water_works                           |

### 3. Places of Worship (“pofw”)

The following feature classes exist in this layer:

| code | layer | fclass                | Description                                                  | OSM Tags                                     |
| ---- | ----- | --------------------- | ------------------------------------------------------------ | -------------------------------------------- |
| 3000 | pofw  |                       | Places of worship                                            |                                              |
| 3100 | pofw  | christian             | A christian place of worship (usually a church) without one of the denominations below. | amenity=place_of_worship, religion=christian |
| 3101 | pofw  | christian_anglican    | A christian place of worship where the denomination is known. (Note to German users: “protestant” is “evangelisch” in German; “evangelical” is “evangelikal” in German.) | + denomination=anglican                      |
| 3102 | pofw  | christian_catholic    |                                                              | + denomination=catholic                      |
| 3103 | pofw  | christian_evangelical |                                                              | + denomination=evangelical                   |
| 3104 | pofw  | christian_lutheran    |                                                              | + denomination=lutheran                      |
| 3105 | pofw  | christian_methodist   |                                                              | + denomination=methodist                     |
| 3106 | pofw  | christian_orthodox    |                                                              | + denomination=orthodox                      |
| 3107 | pofw  | christian_protestant  |                                                              | + denomination=protestant                    |
| 3108 | pofw  | christian_baptist     |                                                              | + denomination=baptist                       |
| 3109 | pofw  | christian_mormon      |                                                              | + denomination=mormon                        |

| code | layer | fclass       | Description                                                  | OSM Tags                                     |
| ---- | ----- | ------------ | ------------------------------------------------------------ | -------------------------------------------- |
| 3200 | pofw  | jewish       | A Jewish place of worship (usually a synagogue).             | amenity=place_of_worship, religion=jewish    |
| 3300 | pofw  | muslim       | A Muslim place of worship (usually a mosque) without one of the denominations below. | amenity=place_of_worship, religion=muslim    |
| 3301 | pofw  | muslim_sunni | A Sunni Muslim place of worship.                             | + denomination=sunni                         |
| 3302 | pofw  | muslim_shia  | A Shia Muslim place of worship.                              | + denomination=shia                          |
| 3400 | pofw  | buddhist     | A Buddhist place of worship.                                 | amenity=place_of_worship, religion=buddhist  |
| 3500 | pofw  | hindu        | A Hindu place of worship.                                    | amenity=place_of_worship, religion=hindu     |
| 3600 | pofw  | taoist       | A Taoist place of worship.                                   | amenity=place_of_worship, religion=taoist    |
| 3700 | pofw  | shintoist    | A Shintoist place of worship.                                | amenity=place_of_worship, religion=shintoist |
| 3800 | pofw  | sikh         | A Sikh place of worship.                                     | amenity=place_of_worship, religion=sikh      |

### 4. Natural Features (“natural”)

The following feature classes exist in this layer:

| code | layer   | fclass        | Description                                                  | OSM Tags              |
| ---- | ------- | ------------- | ------------------------------------------------------------ | --------------------- |
| 4101 | natural | spring        | A spring, possibly source of a stream.                       | natural=spring        |
| 4103 | natural | glacier       | A glacier.                                                   | natural=glacier       |
| 4111 | natural | peak          | A mountain peak.                                             | natural=peak          |
| 4112 | natural | cliff         | A cliff.                                                     | natural=cliff         |
| 4113 | natural | volcano       | A volcano.                                                   | natural=volcano       |
| 4121 | natural | tree          | A tree.                                                      | natural=tree          |
| 4131 | natural | mine          | A mine.                                                      | natural=mine          |
| 4132 | natural | cave_entrance | A cave entrance.                                             | natural=cave_entrance |
| 4141 | natural | beach         | A beach. (Note that beaches are only rarely mapped as point features.) | natural=beach         |

### 5. Traffic Related (“traffic”)

The following feature classes exist in this layer:

| code | layer   | fclass          | Description                                                  | OSM Tags                                 |
| ---- | ------- | --------------- | ------------------------------------------------------------ | ---------------------------------------- |
| 5201 | traffic | traffic_signals | Traffic lights.                                              | highway=traffic_signals                  |
| 5202 | traffic | mini_roundabout | A small roundabout without physical structure, usually just painted onto the road surface. | highway=mini_roundabout                  |
| 5203 | traffic | stop            | A stop sign.                                                 | highway=stop                             |
| 5204 | traffic | crossing        | A place where the street is crossed by pedestrians or a railway. | highway=crossing, railway=level_crossing |

| code | layer   | fclass              | Description                                             | OSM Tags                      |
| ---- | ------- | ------------------- | ------------------------------------------------------- | ----------------------------- |
| 5205 | traffic | ford                | A place where the road runs through a river or stream.  | highway=ford                  |
| 5206 | traffic | motorway_junction   | The place where a slipway enters or leaves a motorway.  | highway=motorway_junction     |
| 5207 | traffic | turning_circle      | An area at the end of a street where vehicles can turn. | highway=turning_circle        |
| 5208 | traffic | speed_camera        | A camera that photographs speeding vehicles.            | highway=speed_camera          |
| 5209 | traffic | street_lamp         | A lamp illuminating the road.                           | highway=street_lamp           |
|      |         |            |Fuel and Parking||
| 5250 | traffic | fuel                | A gas station.                                          | amenity=fuel                  |
| 5251 | traffic | service             | A service area, usually along motorways.                | highway=services              |
| 5260 | traffic | parking             | A car park of unknown type.                             | amenity=parking               |
| 5261 | traffic | parking_site        | A surface car park.                                     | amenity=parking, parking=site |
| 5262 | traffic | parking_multistorey | A multi-storey car park.                                | parking=multi-storey          |
| 5263 | traffic | parking_underground | An underground car park.                                | parking=underground           |
| 5270 | traffic | parking_bicycle     | A place to park your bicycle.                           | amenity=bicycle_parking       |
|      |         |                     |Water Traffic||
| 5301 | traffic | slipway             | A slipway.                                              | leisure=slipway               |
| 5302 | traffic | marina              | A marina.                                               | leisure=marina                |
| 5303 | traffic | pier                | A pier.                                                 | man_made=pier                 |
| 5311 | traffic | dam                 | A dam.                                                  | waterway=dam                  |
| 5321 | traffic | waterfall           | A waterfall.                                            | waterway=waterfall            |
| 5331 | traffic | lock_gate           | A lock gate.                                            | waterway=lock_gate            |
| 5332 | traffic | weir                | A barrier built across a river or stream.               | waterway=weir                 |

Note: Most of the 53xx type objects do sometimes appear as linear features in OSM as well but those are not yet available in the shape files.

### 6. Transport Infrastructure (“transport”)

The following feature classes exist in this layer:

| code | layer     | fclass          | Description                                          | OSM Tags                                                     |
| ---- | --------- | --------------- | ---------------------------------------------------- | ------------------------------------------------------------ |
| 5601 | transport | railway_station | A larger railway station of mainline rail services.  | railway=station                                              |
| 5602 | transport | railway_halt    | A smaller, local railway station, or subway station. | railway=halt, or public_transport=stop_position + train=yes  |
| 5603 | transport | tram_stop       | A tram stop.                                         | railway=tram_stop, or public_transport=stop_position + tram=yes |
| 5621 | transport | bus_stop        | A bus stop.                                          | highway=bus_stop, or public_transport=stop_position + bus=yes |

| code | layer     | fclass            | Description                                  | OSM Tags                                                     |
| ---- | --------- | ----------------- | -------------------------------------------- | ------------------------------------------------------------ |
| 5622 | transport | bus_station       | A large bus station with multiple platforms. | amenity=bus_station                                          |
| 5641 | transport | taxi_rank         | A taxi rank.                                 | amenity=taxi                                                 |
| 565x |           |                   | Air Traffic                                  |                                                              |
| 5651 | transport | airport           | A large airport.                             | amenity=airport or aeroway=aerodrome unless type=airstrip    |
| 5652 | transport | airfield          | A small airport or airfield.                 | aeroway=airfield, military=airfield, aeroway=aeroway with type=airstrip |
| 5655 | transport | helipad           | A place for landing helicopters.             | aeroway=helipad                                              |
| 5656 | transport | apron             | An apron (area where aircraft are parked)    | aeroway=apron                                                |
| 566x |           |                   | Water Traffic                                |                                                              |
| 5661 | transport | ferry_terminal    | A ferry terminal.                            | amenity=ferry_terminal                                       |
| 567x |           |                   | Other Traffic                                |                                                              |
| 5671 | transport | aerialway_station | A station where cable cars or lifts alight.  | aerialway=station                                            |





