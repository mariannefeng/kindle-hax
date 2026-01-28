import { GraphQLResponse, BusArrival } from "./types";

const GRAPHQL_ENDPOINT = "https://www.njtransit.com/api/graphql/graphql";
const STOP_ID = "21922";

const GRAPHQL_QUERY = `
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

export async function fetchBusArrivals(): Promise<BusArrival[]> {
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
        stopID: STOP_ID,
      },
      query: GRAPHQL_QUERY,
    }),
  });

  if (!response.ok) {
    throw new Error(
      `GraphQL request failed: ${response.status} ${response.statusText}`,
    );
  }

  const data = (await response.json()) as GraphQLResponse;

  if (!data.data || !data.data.getBusArrivalsByStopID) {
    throw new Error("Invalid GraphQL response structure");
  }

  return data.data.getBusArrivalsByStopID;
}
