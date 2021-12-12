import React from 'react'
import {hot} from 'react-hot-loader'
// import ALL_GAMES from './gamelist_full'
// import './styles.css'
import './sass/main.scss'
// import './tailwind.css'
import ALL_GAMES from './data/games3.json'
// const ALL_GAMES = JSON.parse(json);

import FilterableGameTable from './FilterableGameTable'
import SearchBar from './SearchBar'
import GameResultsTable from './GameResultsTable'

// import {
//   ApolloClient,
//   InMemoryCache,
//   ApolloProvider,
//   useQuery,
//   gql,
// } from '@apollo/client'

// const client = new ApolloClient({
//   uri: 'https://tidy-basilisk-31.hasura.app/v1/graphql',
//   cache: new InMemoryCache(),
// })

import {
  ApolloClient,
  ApolloProvider,
  createHttpLink,
  InMemoryCache,
  gql,
  useQuery,
} from '@apollo/client'
import {setContext} from '@apollo/client/link/context'
import {isTaggedTemplateExpression} from 'typescript'

const httpLink = createHttpLink({
  // uri: 'https://tidy-basilisk-31.hasura.app/v1/graphql',
  // uri: 'http://localhost:8080/v1/graphql',
  // uri: process.env.HASURA_GRAPHQL_URL,
  uri: 'https://bold-dragon-46.hasura.app/v1/graphql',
})

const authLink = setContext((_, {headers}) => {
  return {
    headers: {
      ...headers,
    },
  }
})

const client = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache(),
})

const ALL_DATA = gql`
  query AllData {
    nd: coaches(
      where: {is_notre_dame: {_eq: "true"}}
      order_by: {last_name: asc}
    ) {
      id
      first_name
      middle_name
      last_name
      suffix
      full_name
    }

    opponents: coaches(
      where: {is_opponent: {_eq: "true"}}
      order_by: {last_name: asc}
    ) {
      id
      first_name
      middle_name
      last_name
      suffix
      full_name
    }

    teams: teams {
      id
      name
    }

    games: games(order_by: {date: asc}) {
      id
      date
      nd_rank
      result
      site
      ndCoach {
        id
        full_name
      }
      nd_score
      opp_score
      opponent {
        name
      }
      opp_rank
      opp_final_rank
      oppCoach {
        id
        full_name
      }
    }

    sites: games(distinct_on: site) {
      site
    }
  }
`

// const DISTINCT_ND_COACHES = [''].concat(
//   [...new Set(ALL_GAMES.map((game) => game.nd_coach))].sort()
// )
// const ND_COACHES = DISTINCT_ND_COACHES.map((name) => ({
//   by_first: name,
//   by_last: name.split(' ').reverse().join(', '),
// })).sort((a, b) => (a.by_last > b.by_last && 1) || -1)

// const OPP_COACHES = [''].concat(
//   [...new Set(ALL_GAMES.map((game) => game.opp_coach))].sort()
// )

// const OPPONENTS = [''].concat(
//   [...new Set(ALL_GAMES.map((game) => game.opponent))].sort()
// )

function App() {
  const {loading, error, data} = useQuery(ALL_DATA)
  if (loading) return 'Loading...'
  if (error) return `Error! ${error.message}`

  return (
    <div className="filterable-game-table">
      <FilterableGameTable
        props={{
          oppCoaches: data.opponents,
          ndCoaches: data.nd,
          teams: data.teams,
          games: data.games,
          sites: data.sites,
        }}
      />
    </div>
  )
}

function WrappedApp() {
  return (
    <ApolloProvider client={client}>
      <App />
    </ApolloProvider>
  )
}

// export default function App() {
//   return <FilterableGameTable games={ALL_GAMES} />
// }

export default hot(module)(WrappedApp)
