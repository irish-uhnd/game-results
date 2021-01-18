import React from 'react'
import { hot } from 'react-hot-loader'
import ALL_GAMES from './gamelist_full'
import './styles.css'
// import './tailwind.css'

const MONTHS = [''].concat([...Array(12).keys()])
const YEARS = [''].concat([...Array(2021).keys()].slice(1887).reverse())
const DAYS = [''].concat([...Array(30).keys()].slice(1))
const ND_COACHES = [''].concat(
  [...new Set(ALL_GAMES.map((game) => game.nd_coach))].sort()
)
const OPP_COACHES = [''].concat(
  [...new Set(ALL_GAMES.map((game) => game.opp_coach))].sort()
)

class SearchBar extends React.Component {
  // constructor(props) {
  //   super(props);
  //   // this.handleYear = this.handleYear.bind(this);
  // }

  handleFilter(filterKey, e) {
    // console.log(`Set filter type to: ${filterKey}`);
    // console.log(`Set filter value to ${e.target.value}`);
    this.props.onFilterChange(filterKey, e.target.value)
  }

  handleClear(e) {
    this.props.onClearFilter()
  }

  render() {
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

    const nd_coaches = ND_COACHES.map((coach) => (
      <option key={coach} value={coach.toLowerCase()}>
        {coach}
      </option>
    ))
    const opp_coaches = OPP_COACHES.map((coach) => (
      <option key={coach} value={coach.toLowerCase()}>
        {coach}
      </option>
    ))

    // let filters = Object.keys(this.props.filters).map((filter) => {
    //   return <p key={filter}>{filter}</p>;
    // });

    const filters = this.props.filters

    return (
      <div>
        <fieldset>
          <fieldset>
            <legend>Date</legend>
            <label>
              Year:{' '}
              <select
                onChange={this.handleFilter.bind(this, 'year')}
                value={'year' in filters ? filters.year : ''}
              >
                {years}
              </select>
            </label>
            <label>
              {' '}
              Month:{' '}
              <select
                onChange={this.handleFilter.bind(this, 'month')}
                value={'month' in filters ? filters.month : ''}
              >
                {months}
              </select>
            </label>
            <label>
              {' '}
              Day:{' '}
              <select
                onChange={this.handleFilter.bind(this, 'day')}
                value={'day' in filters ? filters.day : ''}
              >
                {days}
              </select>
            </label>
          </fieldset>

          <fieldset>
            <legend>Coaches</legend>
            <label>
              Notre Dame
              <select
                onChange={this.handleFilter.bind(this, 'nd_coach')}
                value={'nd_coach' in filters ? filters.nd_coach : ''}
              >
                {nd_coaches}
              </select>
            </label>
            <label>
              Opponent
              <select
                onChange={this.handleFilter.bind(this, 'opp_coach')}
                value={'opp_coach' in filters ? filters.opp_coach : ''}
              >
                {opp_coaches}
              </select>
            </label>
          </fieldset>
          <button onClick={this.handleClear.bind(this)}>Start Over</button>
          <br />
        </fieldset>
      </div>
    )
  }
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
      let coach = game.nd_coach.toLowerCase()
      if (coach !== filters.nd_coach) return false
    }

    if ('opp_coach' in filters) {
      let coach = game.opp_coach.toLowerCase()
      if (coach !== filters.opp_coach) return false
    }

    return true
  }

  calculateRecord(games) {
    console.log('did I get here?')
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
        <tr key={game.date}>
          <td>{game.date}</td>
          <td>{game.result}</td>
          <td>{game.site}</td>
          <td>{game.nd_coach}</td>
          <td>{game.nd_score}</td>
          <td>{game.opp_score}</td>
          <td>{game.opponent}</td>
        </tr>
      )
    })

    this.calculateRecord(matchingGames)

    // setInterval(() => this.props.onResultsUpdated(1, 2, 3), 0)

    return (
      <div>
        <fieldset>
          <legend>Results</legend>
          <span>Wins: {this.wins} </span>
          <span>Losses: {this.losses} </span>
          <span>Ties: {this.ties} </span>
        </fieldset>
        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Result</th>
              <th>Site</th>
              <th>ND Coach</th>
              <th>ND Score</th>
              <th>Opponent Score</th>
              <th>Opponent</th>
            </tr>
          </thead>
          <tbody>{resultRows}</tbody>
        </table>
      </div>
    )
  }
}

class FilterableGameTable extends React.Component {
  constructor(props) {
    super(props)
    this.handleChangedFilter = this.handleChangedFilter.bind(this)
    this.handleClearFilters = this.handleClearFilters.bind(this)
    this.handleResultsUpdated = this.handleResultsUpdated.bind(this)
    this.state = {
      filters: {},
      wins: 0,
      losses: 0,
      ties: 0,
    }
  }

  handleChangedFilter(filterKey, filterValue) {
    const currentFilters = Object.assign({}, this.state.filters)
    if (filterValue === '') {
      delete currentFilters[filterKey]
    } else {
      currentFilters[filterKey] = filterValue
    }
    this.setState({ filters: currentFilters })
  }

  handleClearFilters() {
    const currentFilters = Object.assign({}, this.state.filters)

    // console.log(this.state.filters)
    // const filters = {}
    Object.keys(currentFilters).forEach((key) => {
      delete currentFilters[key]
    })
    // this.setState({ filters: filters})
    this.setState({ filters: currentFilters })
  }

  handleResultsUpdated(wins, losses, ties) {
    this.setState({ wins: wins, losses: losses, ties: ties })
  }

  render() {
    return (
      <div>
        <SearchBar
          filters={this.state.filters}
          onFilterChange={this.handleChangedFilter}
          onClearFilter={this.handleClearFilters}
        />
        <GameResultsTable
          games={this.props.games}
          filters={this.state.filters}
          onResultsUpdated={this.handleResultsUpdated}
        />
      </div>
    )
  }
}

function App() {
  return (
    <div>
      <FilterableGameTable games={ALL_GAMES} />
    </div>
  )
}

// export default function App() {
//   return <FilterableGameTable games={ALL_GAMES} />
// }

export default hot(module)(App)
