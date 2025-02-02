% SPDX-License-Identifier: Apache-2.0

# Optimization

## Introduction

The `/optimize` API optimizes energy management based on inputs such as electricity prices, battery storage, PV forecast, and temperature data.

## Input Payload Overview

### Sample payload:
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
The residual value of the energy in the battery. Adjust as needed for your optimization.

### Feed-in Tariff per Wh
`einspeiseverguetung_euro_pro_wh`  
Compensation per Wh of excess energy fed into the grid.

### Projected Total Load
`gesamtlast: [500, 500, ..., 500, 500]`
- First value: 00:00 today
- Last Value: 11:00 day after tomorrow
- Amount of values: 48
- Unit: W

Expected average energy consumption per hour excluding optimized device loads. So exclude your car, battery charge from grid or dishwasher if possible. Otherwise the system consider these values as fixed loads. If you charged your car yesterday from 07:00 to 10:00 it does not mean that you will do this tomorrow as well. The system will calulate when the car should be charged.

#### Data sources
##### A) EOS standard load profile prediction
Use [GET /v1/prediction/list?key=load_mean](https://akkudoktor-eos.readthedocs.io/en/latest/akkudoktoreos/prediction.html#load-prediction)

##### B) EOS adjusted load profile
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
The `initial_soc_percentage` can only be provided by third-party implementations. EOS does not provide an interface for this.

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

Currently has no effect on optimization.

# Output Payload
The optimization result is formatted as follows:
```
{
  "ac_charge": [0.625, 0, 0.625, 0, 1,...0, 0.75, 0],
  "dc_charge": [1, 1, 1, 1,..., 1, 1, 1, 1, 1, 1],
  "discharge_allowed": [ 0, 0, 1, 0, ..., 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
  "eautocharge_hours_float": [0.625, 0, 0.625, 0, 1,...0, 0.75, 0],
  "result":
  { 
    "Last_Wh_pro_Stunde": [ 1014.3167452298054, 994.5016754424094, 1015.668919999559, ... 709.8047127909249,  1018.4826684188788 ],
    "EAuto_SoC_pro_Stunde": [ 98, 98, 98, 98, 98, ..., 98, 98, 98, 98, 98, 98, 98, 98, 98 ],
    "Einnahmen_Euro_pro_Stunde": [ 0, 0, 0, 0.28840447132108926, ..., 0.18214419122244094, 0, 0 ],
    "Gesamt_Verluste": 1514.9566941829153,
    "Gesamtbilanz_Euro": 2.510665005057431,
    "Gesamteinnahmen_Euro": 2.882466921639813,
    "Gesamtkosten_Euro": 5.393131926697244,
    "Home_appliance_wh_per_hour": [ null, null, null, null, null, ..., null, null, null ],
    "Kosten_Euro_pro_Stunde": [ 0, 0.5310514366908033, ..., 0.0000953632355384613, 0.0014098107544239743, 0, 0, ],
    "Netzbezug_Wh_pro_Stunde": [ 0, 0, 0, 0, 1440.57711224113, 0, 1232.047396734616,..., 0, 1018.4826684188788 ],
    "Netzeinspeisung_Wh_pro_Stunde": [ 0, 0, 0, 0,  4120.063876015562, ..., 2602.059874606299, 0, 0, 0, 0, 0, 0, 0 ],
    "Verluste_Pro_Stunde": [ 88.20145610693964, 86.47840656020935, 0, ..., 345.1483049065923, 9.323789733278293e-11, 0, 0 ],
    "akku_soc_pro_stunde": [ 59, 49.81234832219379, 40.80418097217197,..., 66.92328744645944, 100, 100, 100, 100],
    "Electricity_price": [ 0.00040586619999999997, ..., 0.00039730252, 0.00038850095999999997, 0.00037042208 ]
  },
  "eauto_obj":
  { 
    "charge_array": [ 1, 1, 1, 1, 1, 1, 1, 1, 1, ... 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
    "discharge_array": [ 1, 1, 1, 1, 1, 1, 1, 1, ... 1, 1, 1, 1, 1, 1, 1, 1, 1 ],
    "discharging_efficiency": 0.88,
    "hours": 48,
    "capacity_wh": 64000,
    "charging_efficiency": 0.88,
    "max_charge_power_w": 11040,
    "soc_wh": 62720,
    "initial_soc_percentage": 98
  },
  "start_solution": [ 17, 14, 17, 9, 15, 9, 14, 13, 16, 17, 14, 20 ,...,10, 3, 12, 10, 7, 13, 10, 12, 12, 4, 1, 3, 1, 3, 4, 5
  ],
  "washingstart": null
}
```

### Home storage grid charge
`ac_charge`

Array of values between 0 (no charge) and 1 (charge with full load). This value, combined with the planned SOC (akku_soc_pro_stunde) and the current SOC can be used to control grid load in your inverter.

Array which contains values from the hour of the optimization start to the end of the day after tomorrow (min 25, max 48 entries)

### Home storage grid discharge
`dc_charge`

Array which contains values from the hour of the optimization start to the end of the day after tomorrow (min 25, max 48 entries)

### Allow home storage discharge
`discharge_allowed`
This array contains values 0 (no discharge) or 1 (discharge)

Array which contains values from the hour of the optimization start to the end of the day after tomorrow (min 25, max 48 entries)

### EV car charging
`eautocharge_hours_float`

The value can between 0 (no charge) and 1 (charge with full load). This value, combined with the planned SOC (akku_soc_pro_stunde) and the current SOC can be used to control grid load in your inverter.

Array which contains values from the hour of the optimization start to the end of the day after tomorrow (min 25, max 48 entries)
