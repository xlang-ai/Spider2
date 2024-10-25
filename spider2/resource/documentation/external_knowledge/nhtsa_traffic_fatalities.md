### Overview 

Within the nhtsa_traffic_fatalities dataset there are 40 different tables. Interestingly, each table has a suffix of either _2015 or _2016 denoting the year the events in the table occured in. Essentially, there are then only 20 tables. We decided for this project to use only the tables with the _2016 suffix in order to take into account the most recent data. 

Within all tables there are columns for state_number and consecutive_number. State_number identifies the state in which the crash occured. Consecutive_number is a unique case number that is assigned to each crash.

In general here are each table and the information that the table contains.

* accident_2016 - one record per a crash, contains details on crash characteristics and environmental conditions
* cevent_2016 - one record per event, contains a description of the event or object contacted, vehicles involved, and where the vehicle was impacted
* damage_2016 - one record per damaged area, contains details on the areas on a vehicle that were damaged in the crash
* distract_2016 - at least one record per in-transport motor vehicle, each distraction is a seperate record, contains details on driver distractions
* drimpair_2016 - at least one record for each driver of an in-transport motor vehicle, one record per impairment, contains details on physical impairments of drivers of motor vehicles
* factor_2016 - at least one record per in-transport motor vehicle, each factor is a seperate record, contains details about vehicle circumstances which may have contributed to the crash
* maneuver_2016 - at least one record per in-transport motor vehicle, each maneuver is a seperate record, contains details regarding actions taken by the driver to avoid something/someone in the road
* nmcrash_2016 - at least one record for each person who is not an occupant of a motor vehicle, one record per action, contains details about any contributing circumstances or improper actions of people who are not occupants of motor vehicles
* nmimpair_2016 - at least one record for each person who is not an occupant of a motor vehicle, one record per impairment, contains details about physical impairements of people who are not occupants of motor vehicles
* nmprior_2016 - at least one record for each person who is not an occupant of a motor vehicle, one record per action, contains details about the actions of people who are not occupants of motor vehicles at the time of their involvment in the crash
* parkwork_2016 - one record per parked/working vehicle, contains details about parked or working vehicles involved in FARS (Fatality Analysis Reporting System) crashes
* pbtype_2016 - one record for each pedestrian, bicyclist or person on a personal conveyance, contains details about crashes between motor vehicles and pedestrians, people on personal conveyances and bicyclists.
* person_2016 - one record per person, contains details describing all persons involved in the crash like age, sex, vehicle occupant restraint use, and injury severity
* safetyeq_2016 - at least one record for each person who is not an occupant of a motor vehicle, one record per equipment item, contains details about safety equipment used by people who are not occupants of motor vehicles.
* vehicle_2016 - one record per in-transport motor vehicle, contains details describing the in-transport motor vehicles and the drivers of in-transport motor vehicles who are involved in the crash.
* vevent_2016 - one record for each event for each in-transport motor vehicle, contains details on the sequence of events for each intransport motor vehicle involved in the crash. (Same data elements as Cevent data but also records the sequential event number for each vehicle)
* vindecode_2016 - one record per vehicle, contains details describing a vehicle based on the vehicle's VIN.
* violatn_2016 - at least one record per in-transport motor vehicle, each violation is a seperate record, contains details about violations which were charged to drivers.
* vision_2016 - at least one record per in-transport motor vehicle, each obstruction is a seperate record, contains details about circumstances which may have obscured the driver's vision.
* vsoe_2016 - one record for each event for each in-transport motor vehicle, contains the sequence of events for each intransport motor vehicle involved in the crash. (Simplified Vevent)

### Redundant Data/Tables

There is redundant data. For example, vsoe_2016 is an abridged version of vevent_2016. We can see that both tables have one record for each event for each in-transport motor vehicle and contains details on the sequence of events for each intransport motor vehicle. Furthermore, we can go another layer and see that vevent_2016 has redundant data with cevent_2016 as vevent_2016 has the same data elements but also record the VIN as an identifier for data. 

If we compare vehicle_2016 and accident_2016 we can see many redundant columns such as: timestamp_of_crash, first_harmful_event, first_harmful_event_name, and (day/month/hour/minute)_of_crash, etc. This is interesting as vehicle_2016 contains one record per in-transport motor vehicle and accident_2016 contains one record per crash which may contain multiple in-transport motor vehicles. Therefore, this data could be redundant multiple times. 

Moreover, many tables include the raw timestamp as well as year, month, day, hour, minute columns which is redundant as timestamp tells all this information.

In general we see some redundant data, and we believe the purpose is to make querying easier for the user. So for example, if they want to determine the hour of events they do not need to manually calculate the hour from the timestamp, or if they want information about the first_harmful_event in a specific vehicle now they don't need to join accident_2016 to get the data. 

### Edge Cases

- The dataset we choose only contains accidents in which there is at least 1 fatality;
- When you use `travel_speed`, its value should be constrained because certain codes represent speeds beyond a threshold or unknown values, e.g.,
    - 997 indicates speeds greater than 96
    - 998 indicates speeds greater than 151
    - 999 represents unknown speeds
- When you use `speed_limit`, it should be similarly constrained because certain codes indicate that:
    - the speed limit was not reported (98), or
    - the value is unknown (99)