import React from 'react'
import {hot} from 'react-hot-loader'
// import ALL_GAMES from './gamelist_full'
// import './styles.css'
import './sass/main.scss'
// import './tailwind.css'
import ALL_GAMES from './data/games3.json'
// const ALL_GAMES = JSON.parse(json);

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
function SearchBar({props}) {
  function handleFilter(filterKey) {
    // console.log(`Set filter type to: ${filterKey}`)
    // console.log(`Set filter value to ${e.target.value}`)
    return (e) => props.onFilterChange(filterKey, e.target.value)
  }

  function handleClear(e) {
    props.onClearFilter()
  }

  const MONTHS = [''].concat([...Array(12).keys()])
  const DAYS = [''].concat([...Array(32).keys()].slice(1))
  const YEARS = [''].concat(
    [...Array(props.year + 1).keys()].slice(1887).reverse()
  )

  const years = YEARS.map((year) => {
    return (
      <option key={year} value={year}>
        {year}
      </option>
    )
  })
  const months = MONTHS.map((month) => (
    <option key={month} value={month}>
      {Number.isNaN(parseInt(month)) ? month : month + 1}
    </option>
  ))
  const days = DAYS.map((day) => (
    <option key={day} value={day}>
      {day}
    </option>
  ))

  const sites = props.sites.map((site) => {
    return (
      <option key={site.site} value={site.site.toLowerCase()}>
        {site.site}
      </option>
    )
  })
  sites.unshift(<option key="" value="" />)

  const ndCoaches = props.ndCoaches.map((coach) => {
    // let by_last_name = `${coach.last_name}, ${coach.first_name} ${coach.middle_name} ${coach.suffix}`
    let by_last_name = `${coach.last_name}, ${[
      coach.first_name,
      coach.middle_name,
      coach.suffix,
    ]
      .filter(Boolean)
      .join(' ')}`
    let by_first_name = [
      coach.first_name,
      coach.middle_name,
      coach.last_name,
      coach.suffix,
    ]
      .filter(Boolean)
      .join(' ')
    return (
      <option key={by_last_name} value={by_first_name.toLowerCase()}>
        {by_last_name}
      </option>
    )
  })

  ndCoaches.unshift(<option key="" value="" />)

  const oppCoaches = props.oppCoaches.map((coach) => {
    // let by_last_name = `${coach.last_name}, ${coach.first_name} ${coach.middle_name} ${coach.suffix}`
    let by_last_name = `${coach.last_name}, ${[
      coach.first_name,
      coach.middle_name,
      coach.suffix,
    ]
      .filter(Boolean)
      .join(' ')}`
    let by_first_name = [
      coach.first_name,
      coach.middle_name,
      coach.last_name,
      coach.suffix,
    ]
      .filter(Boolean)
      .join(' ')
    return (
      <option key={by_last_name} value={by_first_name.toLowerCase()}>
        {by_last_name}
      </option>
    )
  })

  oppCoaches.unshift(<option key="" value="" />)

  const opponents = props.teams.map((team) => (
    <option key={team.name} value={team.name.toLowerCase()}>
      {team.name}
    </option>
  ))

  opponents.unshift(<option key="" value="" />)
  const filters = props.filters

  const results = [
    {name: '', abbrev: ''},
    {name: 'Win', abbrev: 'w'},
    {name: 'Loss', abbrev: 'l'},
    {name: 'Tie', abbrev: 't'},
  ].map((result) => (
    <option key={result.name} value={result.abbrev}>
      {result.name}
    </option>
  ))

  const vacated = ['True', 'False'].map((b) => (
    <option key={b} value={b.toLowerCase()}>
      {b}
    </option>
  ))
  vacated.unshift(<option key="" value="" />)

  const wonBy = [...Array(131).keys()]
    .map((i) => 80 - i)
    .map((i) => (
      <option key={i} value={i}>
        {i}
      </option>
    ))
  wonBy.unshift(<option key="" value="" />)

  const wonByNoMoreThan = [...Array(131).keys()]
    .map((i) => 80 - i)
    .map((i) => (
      <option key={i} value={i}>
        {i}
      </option>
    ))
  wonByNoMoreThan.unshift(<option key="" value="" />)

  const wonByExactly = [...Array(131).keys()]
    .map((i) => 80 - i)
    .map((i) => (
      <option key={i} value={i}>
        {i}
      </option>
    ))
  wonByExactly.unshift(<option key="" value="" />)

  return (
    <div className="search-bar">
      <header className="search-bar-header">
        <h1>Notre Dame Football All-Time Game Results</h1>
      </header>
      <main class="main">
        <div class="filter-table">
          <div className="filter-table__row">
            <div className="filter-table__column">Site:</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('site')}
                value={'site' in filters ? filters.site : ''}
              >
                {sites}
              </select>
            </div>
          </div>
          <div className="filter-table__row">
            <div className="filter-table__column">Include vacated wins?:</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('vacate')}
                value={'vacate' in filters ? filters.vacate : ''}
              >
                {vacated}
              </select>
            </div>
          </div>
          <div className="filter-table__row">
            <div className="filter-table__column">Result:</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('result')}
                value={'result' in filters ? filters.result : ''}
              >
                {results}
              </select>
            </div>
          </div>
          <div className="filter-table__row">
            <div className="filter-table__column">Notre Dame Coach:</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('nd_coach')}
                value={'nd_coach' in filters ? filters.nd_coach : ''}
              >
                {ndCoaches}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column">Opponent:</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('opponent')}
                value={'opponent' in filters ? filters.opponent : ''}
              >
                {opponents}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column">Opponent Coach</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('opp_coach')}
                value={'opp_coach' in filters ? filters.opp_coach : ''}
              >
                {oppCoaches}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column">Won/Lost by at least:</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('won_by')}
                value={'won_by' in filters ? filters.won_by : ''}
              >
                {wonBy}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column">
              Won/Lost by no more than:
            </div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('won_by_no_more_than')}
                value={
                  'won_by_no_more_than' in filters
                    ? filters.won_by_no_more_than
                    : ''
                }
              >
                {wonByNoMoreThan}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column">Won/Lost by exactly</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('won_by_exactly')}
                value={
                  'won_by_exactly' in filters ? filters.won_by_exactly : ''
                }
              >
                {wonByExactly}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column filter-table__column--span2">
              <div class="filter-table__date">
                <div className="filter-table__date--text">Year:</div>
                <div className="filter-table__date--input">
                  <select
                    onChange={handleFilter('year')}
                    value={'year' in filters ? filters.year : ''}
                  >
                    {years}
                  </select>
                </div>

                <div className="filter-table__date--text">Month:</div>
                <div className="filter-table__date--input">
                  <select
                    onChange={handleFilter('month')}
                    value={'month' in filters ? filters.month : ''}
                  >
                    {months}
                  </select>
                </div>

                <div className="filter-table__date--text">Day:</div>
                <div className="filter-table__date--input">
                  <select
                    onChange={handleFilter('day')}
                    value={'day' in filters ? filters.day : ''}
                  >
                    {days}
                  </select>
                </div>
              </div>
            </div>
          </div>
        </div>

        <section className="section">
          <div className="row">
            <div className="col-1-of-2">
              <div className="filters__notre-dame">
                <div className="u-center-div-small"></div>
                <div className="u-center-div-medium"></div>
              </div>
            </div>
            <div className="col-1-of-2">
              <div className="filters__opponents">
                <div></div>
                <div></div>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* <fieldset className="top-level">
        <fieldset>
          <legend>Date</legend>
          <label>
            Year:{' '}
            <select
              onChange={handleFilter('year')}
              value={'year' in filters ? filters.year : ''}
            >
              {years}
            </select>
          </label>
          <label>
            {' '}
            Month:{' '}
            <select
              onChange={handleFilter('month')}
              value={'month' in filters ? filters.month : ''}
            >
              {months}
            </select>
          </label>
          <label>
            {' '}
            Day:{' '}
            <select
              onChange={handleFilter('day')}
              value={'day' in filters ? filters.day : ''}
            >
              {days}
            </select>
          </label>
        </fieldset>

        <fieldset>
          <legend>Teams</legend>
          <select
            onChange={handleFilter('opponent')}
            value={'opponent' in filters ? filters.opponent : ''}
          >
            {opponents}
          </select>
        </fieldset>

        <fieldset>
          <legend>Coaches</legend>
          <label>
            Notre Dame
            <select
              onChange={handleFilter('nd_coach')}
              value={'nd_coach' in filters ? filters.nd_coach : ''}
            >
              {ndCoaches}
            </select>
          </label>
          <label>
            Opponent
            <select
              onChange={handleFilter('opp_coach')}
              value={'opp_coach' in filters ? filters.opp_coach : ''}
            >
              {oppCoaches}
            </select>
          </label>
        </fieldset>
        <div className="start-over">
          <button className="btn btn--color" onClick={handleClear}>
            Start Over
          </button>
        </div>
        <br />
      </fieldset> */}
      <div className="start-over">
        <button className="btn btn--color" onClick={handleClear}>
          Start Over
        </button>
      </div>
      <br />
    </div>
  )
}

class GameResultsTable extends React.Component {
  constructor(props) {
    super(props)
    this.wins = 0
    this.losses = 0
    this.ties = 0
  }

  includeGame(game) {
    // Check if year matches
    let gameDate = new Date(game.date.replace('-', '/'))
    let filters = this.props.filters

    // if (gameDate.getFullYear() == '2016') {
    //   console.log(gameDate)
    // }

    if ('year' in filters) {
      // console.log('Check Year')
      let year = gameDate.getFullYear()
      if (Number(year) !== Number(filters.year)) return false
    }

    if ('month' in filters) {
      // console.log('Check Month')
      let month = gameDate.getMonth()
      if (Number(month) !== Number(filters.month)) return false
    }

    if ('day' in filters) {
      // console.log('Check Day')
      let day = gameDate.getDate()
      if (Number(day) !== Number(filters.day)) return false
    }

    if ('nd_coach' in filters) {
      let coach = game.ndCoach.full_name.toLowerCase()
      if (coach !== filters.nd_coach) return false
    }

    if ('opp_coach' in filters) {
      let coach = game.oppCoach.full_name.toLowerCase()
      if (coach !== filters.opp_coach) return false
    }

    if ('opponent' in filters) {
      let opponent = game.opponent.name.toLowerCase()
      if (opponent !== filters.opponent) return false
    }

    if ('result' in filters) {
      let result = game.result.toLowerCase()
      if (result !== filters.result) return false
    }

    if ('site' in filters) {
      let site = game.site.toLowerCase()
      if (site !== filters.site) return false
    }

    if ('vacate' in filters && filters.vacate == 'false') {
      let year = gameDate.getFullYear()
      let result = game.result.toLowerCase()
      if ((year == '2012' || year == '2013') && result == 'w') {
        return false
      }
    }

    if ('won_by' in filters) {
      let wonBy = filters.won_by
      let ndScore = game.nd_score
      let oppScore = game.opp_score
      let scoreDiff = ndScore - oppScore
      let gameResult = game.result

      if (wonBy > 0) {
        if (scoreDiff <= 0 || scoreDiff < wonBy) {
          return false
        }
      } else if (wonBy < 0) {
        if (scoreDiff > 0 || scoreDiff > wonBy) {
          return false
        }
      } else {
        if (gameResult != 'T') {
          return false
        }
      }

      // let year = gameDate.getFullYear()
      // let result = game.result.toLowerCase()
      // if ((year == '2012' || year == '2013') && result == 'w') {
      //   return false
      // }
    }

    if ('won_by_no_more_than' in filters) {
      let wonByNoMoreThan = filters.won_by_no_more_than
      let ndScore = game.nd_score
      let oppScore = game.opp_score
      let scoreDiff = ndScore - oppScore
      let gameResult = game.result

      if (wonByNoMoreThan > 0) {
        if (scoreDiff <= 0 || scoreDiff > wonByNoMoreThan) {
          return false
        }
      } else if (wonByNoMoreThan < 0) {
        if (scoreDiff > 0 || scoreDiff < wonByNoMoreThan) {
          return false
        }
      } else {
        if (gameResult != 'T') {
          return false
        }
      }
    }

    if ('won_by_exactly' in filters) {
      let wonByExactly = filters.won_by_exactly
      let ndScore = game.nd_score
      let oppScore = game.opp_score
      let scoreDiff = ndScore - oppScore
      let gameResult = game.result

      if (scoreDiff != wonByExactly) {
        return false
      }

      // if (wonByExactly > 0) {
      //   if (scoreDiff != wonByExactly) {
      //     return false
      //   }
      // } else if (wonByExactly < 0) {
      //   if (scoreDiff != wonByExactly) {
      //     return false
      //   }
      // } else {
      //   if (gameResult != 'T') {
      //     return false
      //   }
      // }
    }

    return true
  }

  calculateRecord(games) {
    // const wins = games.filter(x => x.result === 'W').length
    // const losses = games.filter(x => x.result === 'W').length

    let wins = 0,
      losses = 0,
      ties = 0

    games.forEach((game) => {
      if (game.result === 'W') wins += 1
      else if (game.result === 'L') losses += 1
      else if (game.result === 'T') ties += 1
    })
    // this.props.onResultsUpdated(wins, losses, ties)
    this.wins = wins
    this.losses = losses
    this.ties = ties
  }

  // componentDidMount() {
  //   console.log('mounted...')
  // }

  // componentWillUpdate() {
  // //   console.log('updated...')
  // //   let [wins, losses, ties] = this.calculateRecord(this.getMatchingGames())
  // //   this.props.onResultsUpdated(wins, losses, ties)
  //   this.calculateRecord(this.getMatchingGames())

  // }

  // componentWillReceiveProps() {
  //   console.log('receiving props')
  //   this.props.onResultsUpdated(1, 2, 3)
  // }

  getMatchingGames() {
    const matchingGames = []
    this.props.games.forEach((game) => {
      let filterCount = Object.keys(this.props.filters).length
      if (filterCount > 0 && this.includeGame(game)) {
        matchingGames.push(game)
      }
    })
    return matchingGames
  }

  render() {
    const resultRows = []
    const matchingGames = this.getMatchingGames()

    matchingGames.forEach((game) => {
      resultRows.push(
        <tr key={game.id}>
          <td>{game.date}</td>
          <td>{game.result}</td>
          <td>{game.site}</td>
          <td>{game.ndCoach.full_name}</td>
          <td>{game.oppCoach.full_name}</td>
          <td>{game.nd_score}</td>
          <td>{game.opp_score}</td>
          <td>{game.opponent.name}</td>
        </tr>
      )
    })

    this.calculateRecord(matchingGames)

    // setInterval(() => this.props.onResultsUpdated(1, 2, 3), 0)
    let winningPercentage = this.wins / (this.wins + this.losses + this.ties)
    winningPercentage = winningPercentage ? winningPercentage : 0.0

    return (
      <div className="results">
        <div className="fieldset">
          <fieldset>
            <legend>
              Results ({Number.parseFloat(winningPercentage).toFixed(3)})
            </legend>
            <span>Wins: {this.wins} </span>
            <span>Losses: {this.losses} </span>
            <span>Ties: {this.ties} </span>
          </fieldset>
        </div>
        <div className="results-table">
          <div className="game-list">
            <table>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Result</th>
                  <th>Site</th>
                  <th>ND Coach</th>
                  <th>Opponent Coach</th>
                  <th>ND Score</th>
                  <th>Opponent Score</th>
                  <th>Opponent</th>
                </tr>
              </thead>
              <tbody>{resultRows}</tbody>
            </table>
          </div>
        </div>
      </div>
    )
  }
}

function FilterableGameTable({props}) {
  // const lastGame = props.games.at(-1)
  const lastGame = props.games[props.games.length - 1]
  console.log('last game is')
  console.log(lastGame)
  console.log(props)
  const currentYear = new Date(lastGame.date).getFullYear()

  const [state, setState] = React.useState({
    filters: {},
    wins: 0,
    losses: 0,
    ties: 0,
  })

  function handleChangedFilter(filterKey, filterValue) {
    const currentFilters = Object.assign({}, state.filters)
    if (filterValue === '') {
      delete currentFilters[filterKey]
    } else {
      currentFilters[filterKey] = filterValue
    }
    setState({filters: currentFilters})
  }

  function handleClearFilters() {
    const currentFilters = Object.assign({}, state.filters)

    // console.log(state.filters)
    // const filters = {}
    Object.keys(currentFilters).forEach((key) => {
      delete currentFilters[key]
    })
    // setState({ filters: filters})
    setState({filters: currentFilters})
  }

  function handleResultsUpdated(wins, losses, ties) {
    setState({wins: wins, losses: losses, ties: ties})
  }

  return (
    <div>
      <SearchBar
        props={{
          filters: state.filters,
          onFilterChange: handleChangedFilter,
          onClearFilter: handleClearFilters,
          ndCoaches: props.ndCoaches,
          oppCoaches: props.oppCoaches,
          teams: props.teams,
          sites: props.sites,
          year: currentYear,
        }}
      />
      <GameResultsTable
        games={props.games}
        filters={state.filters}
        onResultsUpdated={handleResultsUpdated}
      />
    </div>
  )
}

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
