export interface BusArrival {
  departingIn: string;
  destination: string;
  route: string;
  time: string;
  capacity: string | null;
  __typename: string;
}

export interface GraphQLResponse {
  data: {
    getBusArrivalsByStopID: BusArrival[];
  };
}
