import { StopIDResponse, RouteResponse, BusArrival } from "./types";

const GRAPHQL_ENDPOINT = "https://www.njtransit.com/api/graphql/graphql";
const DEFAULT_STOP_ID = "21922";

const GRAPHQL_STOP_ID_QUERY = `
  query BusArrivalsByStopID($stopID: ID!) {
    getBusArrivalsByStopID(stopID: $stopID) {
      departingIn
      destination
      route
      time
      capacity
      __typename
    }
  }
`;

const GRAPHQL_ROUTE_QUERY = `
  query BusArrivals($route: String!, $direction: String!, $stop: String!, $showAll: Boolean = true) {
    getBusArrivals(
      route: $route,
      direction: $direction,
      stop: $stop,
      showAll: $showAll
    ) {
      departingIn
      destination
      route
      time
      capacity
      __typename
    }
  }
`;

export async function fetchBusArrivals(
  stop: string,
  route: string,
  direction: string,
): Promise<BusArrival[]> {
  const response = await fetch(GRAPHQL_ENDPOINT, {
    method: "POST",
    headers: {
      accept: "*/*",
      "accept-language": "en-US,en;q=0.9",
      "cache-control": "no-cache",
      "content-type": "application/json",
      pragma: "no-cache",
    },
    body: JSON.stringify({
      operationName: "BusArrivals",
      variables: {
        stop: stop,
        route: route,
        direction: direction,
        showAll: false,
      },
      query: GRAPHQL_ROUTE_QUERY,
    }),
  });

  if (!response.ok) {
    throw new Error(
      `GraphQL request failed: ${response.status} ${response.statusText}`,
    );
  }

  const data = (await response.json()) as RouteResponse;

  if (!data.data || !data.data.getBusArrivals) {
    throw new Error("Invalid GraphQL response structure");
  }

  return data.data.getBusArrivals;
}

export async function fetchBusArrivalByStopID(
  stopID: string = DEFAULT_STOP_ID,
): Promise<BusArrival[]> {
  const response = await fetch(GRAPHQL_ENDPOINT, {
    method: "POST",
    headers: {
      accept: "*/*",
      "accept-language": "en-US,en;q=0.9",
      "cache-control": "no-cache",
      "content-type": "application/json",
      pragma: "no-cache",
    },
    body: JSON.stringify({
      operationName: "BusArrivalsByStopID",
      variables: {
        stopID: stopID,
      },
      query: GRAPHQL_STOP_ID_QUERY,
    }),
  });

  if (!response.ok) {
    throw new Error(
      `GraphQL request failed: ${response.status} ${response.statusText}`,
    );
  }

  const data = (await response.json()) as StopIDResponse;

  if (!data.data || !data.data.getBusArrivalsByStopID) {
    throw new Error("Invalid GraphQL response structure");
  }

  return data.data.getBusArrivalsByStopID;
}
