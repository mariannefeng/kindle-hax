export interface BusArrival {
  departingIn: string;
  destination: string;
  route: string;
  time: string;
  capacity: string | null;
  __typename: string;
}

export interface StopIDResponse {
  data: {
    getBusArrivalsByStopID: BusArrival[];
  };
}

export interface RouteResponse {
  data: {
    getBusArrivals: BusArrival[];
  };
}
