import { NativeModules, Platform } from 'react-native';
import type { DataGateway, DataSensor } from './Data/DataDevice';
import type { DataLocation } from './Data/DataLocation';
import type { DataCustomer } from './Data/DataCustomer';
import type { DataAppInfo } from './Data/DataAppInfo';

const LINKING_ERROR =
  `The package 'sentinelsdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const AuthModule = NativeModules.AuthModule
  ? NativeModules.AuthModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

// AUTH MODULE

export function isLoggedIn(): Promise<Boolean> {
  return AuthModule.isLoggedIn();
}

export function signIn(userName: string, password: string): Promise<Boolean> {
  return AuthModule.signIn(userName, password);
}

export function recoverPassword(email: string): Promise<Boolean> {
  return AuthModule.recoverPassword(email);
}

export function signOut(): Promise<Boolean> {
  return AuthModule.signOut();
}

export function accountType(): Promise<string> {
  return AuthModule.accountType();
}

// DEVICES MODULE

const DevicesModule = NativeModules.DevicesModule
  ? NativeModules.DevicesModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function getSensors(filter: string): Promise<Array<DataSensor>> {
  return DevicesModule.getSensors(filter);
}

export function deleteSensors(ids: string): Promise<Array<number>> {
  return DevicesModule.deleteSensors(ids);
}

export function editSensorName(id: string, name: string): Promise<string> {
  return DevicesModule.editSensorName(id, name);
}

export function getGateways(filter: string): Promise<Array<DataGateway>> {
  return DevicesModule.getGateways(filter);
}

export function deleteGateway(id: string): Promise<number> {
  return DevicesModule.deleteGateway(id);
}

export function editGatewayName(id: string, name: string): Promise<Boolean> {
  return DevicesModule.editGatewayName(id, name);
}

export function refreshGateways(filter: string) {
  return DevicesModule.refreshGateways(filter);
}

export function refreshSensors(filter: string) {
  return DevicesModule.refreshSensors(filter);
}

// LOCATIONS MODULE

const LocationsModule = NativeModules.LocationsModule
  ? NativeModules.LocationsModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function getLocations(customerId: string): Promise<Array<DataLocation>> {
  return LocationsModule.getLocations(customerId);
}

export function getFilterLocationList(
  filterValue: string,
  customerId: string
): Promise<Array<DataLocation>> {
  return LocationsModule.getFilterLocationList(filterValue, customerId);
}

export function deleteLocation(
  locationId: string,
  transferLocationId: string
): Promise<string> {
  return LocationsModule.deleteLocation(locationId, transferLocationId);
}

export function getSensorsLocation(
  locationId: string,
  filterValue: string
): Promise<Array<DataSensor>> {
  return LocationsModule.getSensors(locationId, filterValue);
}

export function getGatewaysLocation(
  locationId: string,
  filterValue: string
): Promise<Array<DataGateway>> {
  return LocationsModule.getGateways(locationId, filterValue);
}

export function addLocation(
  name: string,
  description: string,
  latitude: number,
  longitude: number,
  customerId: number | null
): Promise<Array<DataLocation>> {
  return LocationsModule.addLocation(
    name,
    description,
    latitude,
    longitude,
    customerId
  );
}

// CUSTOMER MODULE

const CustomersModule = NativeModules.CustomersModule
  ? NativeModules.CustomersModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function getCustomerList(): Promise<Array<DataCustomer>> {
  return CustomersModule.getCustomerList();
}

export function getFilterCustomerList(
  filterValue: string
): Promise<Array<DataCustomer>> {
  return CustomersModule.getFilterCustomerList(filterValue);
}

export function refreshCustomers() {
  return CustomersModule.refreshCustomers();
}

// APP INFO MODULE

const AppInfoModule = NativeModules.AppInfoModule
  ? NativeModules.AppInfoModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function readInfo(): Promise<DataAppInfo> {
  return AppInfoModule.readInfo();
}

// FIRMWARE MODULE

const FirmwareModule = NativeModules.FirmwareModule
  ? NativeModules.FirmwareModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function updateFirmware(devices: string): Promise<Array<string>> {
  return FirmwareModule.updateFirmware(devices);
}
