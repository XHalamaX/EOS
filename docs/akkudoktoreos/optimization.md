% SPDX-License-Identifier: Apache-2.0

# Optimization

## Introduction

The `/optimize` API is used to optimize energy management by considering various input parameters such as electricity prices, battery storage, PV forecast, and temperature data.

## Input Payload Overview

Below is a sample payload:
```
{
    "ems": {
        "preis_euro_pro_wh_akku": 0.0007,
        "einspeiseverguetung_euro_pro_wh": 0.00007,
        "gesamtlast": [500, 500, ..., 500, 500],
        "pv_prognose_wh": [300, 0, 0, ..., 2160, 1840],
        "strompreis_euro_pro_wh": [
            0.0003784, 0.0003868, 0.0003899, ..., 0.00034102, 0.00033709
        ]
    },
    "pv_akku": {
        "capacity_wh": 12000,
        "charging_efficiency": 0.92,
        "discharging_efficiency": 0.92,
        "max_charge_power_w": 5700,
        "initial_soc_percentage": 66,
        "min_soc_percentage": 5,
        "max_soc_percentage": 100
    },
    "inverter": {
        "max_power_wh": 15500
    },
    "eauto": {
        "capacity_wh": 64000,
        "charging_efficiency": 0.88,
        "discharging_efficiency": 0.88,
        "max_charge_power_w": 11040,
        "initial_soc_percentage": 98,
        "min_soc_percentage": 60,
        "max_soc_percentage": 100
    },
    "temperature_forecast": [18.3, 18, ..., 20.16, 19.84],
    "start_solution": null
}
```

## Energy Storage System (EMS)
### Battery Cost per Wh
`preis_euro_pro_wh_akku: 0.0007`  
Defines the cost associated with stored energy in the battery. This ensures that the system does not treat stored energy as "free" but instead accounts for its value when optimizing energy usage. Use the default value or adjust it slightly so the optimization fits your needs.

### Feed-in Tariff per Wh
`einspeiseverguetung_euro_pro_wh`  
Compensation received per Wh of excess energy fed into the grid.

### Projected Total Load
`gesamtlast: [500, 500, ..., 500, 500]`
- First value: 00:00 today
- Last Value: 11:00 day after tomorrow
- Amount of values: 48
- Unit: W

Expected average energy consumption per hour without loads from devices which should be optimized. So exclude your car, battery charge from grid or dishwasher if possible. Otherwise the system consider these values as fixed loads. If you charged your car yesterday from 07:00 to 10:00 it does not mean that you will do this tomorrow as well. The system will calulate when the car should be charged.

#### Data sources
##### EOS standard load profile prediction
Use [GET /v1/prediction/list?key=load_mean](https://akkudoktor-eos.readthedocs.io/en/latest/akkudoktoreos/prediction.html#load-prediction)

##### EOS adjusted load profile
Use [GET /v1/prediction/list?key=load_mean_adjusted](https://akkudoktor-eos.readthedocs.io/en/latest/akkudoktoreos/prediction.html#load-prediction)

### Photovoltaic (PV) Forecast
`pv_prognose_wh: [300, 0, 0, ..., 2160, 1840]`
- First value: 00:00 today
- Last Value: 11:00 day after tomorrow
- Amount of values: 48
- Unit: W

#### Data sources
##### EOS PV Prediction
Use [GET /v1/prediction/series?key=pvforecast_dc_power](https://akkudoktor-eos.readthedocs.io/en/latest/akkudoktoreos/prediction.html#pv-power-prediction))

### Electricity Price Forecast
`strompreis_euro_pro_wh: [0.0003784, 0.0003868, 0.0003899, ..., 0.00034102, 0.00033709]`
- First value: 00:00 today
- Last Value: 11:00 day after tomorrow
- Amount of values: 48
- Unit: €/Wh

#### Data sources
##### EOS Price Prediction
Use [GET /v1/prediction/list?key=elecprice_marketprice_wh](https://akkudoktor-eos.readthedocs.io/en/latest/akkudoktoreos/prediction.html#electricity-price-prediction)

## Battery Storage
### Capacity 
`"capacity_wh": 12000`  
The total capacity of your home battery.

### Efficiency 
`"charging_efficiency": 0.92`  
`"discharging_efficiency": 0.92`

Consideration of loses while charging or discharging the home battery.

### Max Charging Power
`"max_charge_power_w": 5700`

### State of Charge
`"initial_soc_percentage": 66`  
`"min_soc_percentage": 5`  
`"max_soc_percentage": 100`  

#### Data sources
The current SOC of the home battery `initial_soc_percentage`  can only be provided by third party implementations. EOS does not provide an interface for this at the moment.

## Inverter 
### Max Inverter power
`"max_power_wh": 15500`

## Electric Vehicle
### Capacity 
`"capacity_wh:" 64000`
### Efficiency 
`"charging_efficiency": 0.88`  
`"discharging_efficiency": 0.88`  
### Max Charging Power
`"max_charge_power_w": 11040`
### State of Charge
`"initial_soc_percentage": 98`  
`"min_soc_percentage": 60`  
`"max_soc_percentage": 100`

## Temperature Forecast 
`temperature_forecast: [18.3, 18, ..., 20.16, 19.84]`
- First value: 00:00 today
- Last Value: 11:00 day after tomorrow
- Amount of values: 48
- Unit: °C

#### Data sources
##### EOS Price Prediction
Use [GET /v1/prediction/list?key=weather_temp_air](https://akkudoktor-eos.readthedocs.io/en/latest/akkudoktoreos/prediction.html#weather-prediction)

## Start Solution
`start_solution: null`

Currently no effect on optimization.

# Output Payload

