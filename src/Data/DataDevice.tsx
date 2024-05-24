interface DataDevice {
  id: string;
  name: string;
  serialNumber: string;
  uuid: string;
  customerId: string;
  status: number;
  locationName: string;
  locationId: string;
  code: string;
  model: string;
  firmwareVersion: string;
  firmwareUpdateStatus: string;
}

interface DataCustomerDevices {
  gateways: Array<DataDevice>[];
  sensors: Array<DataSensor>[];
}

interface DataGateway extends DataDevice {}

interface SensorReport {
  value: number;
  date: number;
}

interface DataSensor extends DataDevice {
  gatewayName: string;
  measureUnit: string;
  latestReport: SensorReport;
  loraWanPendingStatus: string;
  attributes: Map<string, string>;
}

class Sensor implements DataSensor {
  gatewayName: string;

  measureUnit: string;

  latestReport: SensorReport;

  loraWanPendingStatus: string;

  attributes: Map<string, string>;

  id: string;

  name: string;

  serialNumber: string;

  customerId: string;

  status: number;

  locationName: string;

  locationId: string;

  code: string;

  uuid: string;

  model: string;

  firmwareVersion: string;

  firmwareUpdateStatus: string;

  constructor(
    gatewayName: string,
    measureUnit: string,
    latestReport: SensorReport,
    loraWanPendingStatus: string,
    attributes: Map<string, string>,
    id: string,
    name: string,
    serialNumber: string,
    customerId: string,
    status: number,
    locationName: string,
    locationId: string,
    uuid: string,
    model: string,
    firmwareVersion: string,
    firmwareUpdateStatus: string
  ) {
    this.gatewayName = gatewayName;
    this.measureUnit = measureUnit;
    this.latestReport = latestReport;
    this.loraWanPendingStatus = loraWanPendingStatus;
    this.attributes = attributes;
    this.id = id;
    this.name = name;
    this.serialNumber = serialNumber;
    this.customerId = customerId;
    this.status = status;
    this.locationName = locationName;
    this.locationId = locationId;
    this.code = '';
    this.uuid = uuid;
    this.model = model;
    this.firmwareVersion = firmwareVersion;
    this.firmwareUpdateStatus = firmwareUpdateStatus;
  }
}

export type { DataDevice, DataSensor, DataGateway, DataCustomerDevices };

export { Sensor };
