import React from 'react'

export default class GameResultsTable extends React.Component {
  constructor(props) {
    super(props)
    this.wins = 0
    this.losses = 0
    this.ties = 0
    this.state = {order: 'date'}
  }

  includeGame(game) {
    // Check if year matches
    let gameDate = new Date(game.date.replace(/-/g, '/'))
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

    if ('vacate' in filters && filters.vacate.toLowerCase() == 'false') {
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

    if ('season' in filters) {
      let season = game.season

      if (season !== parseInt(filters.season)) {
        return false
      }
    }

    if ('is_bowl' in filters) {
      let isBowl = game.is_bowl.toString()
      let bowlFilter = filters.is_bowl

      if (isBowl !== bowlFilter) {
        return false
      }
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

  orderRowsBy(e) {
    const col = e.target.id
    var direction = this.state.direction === 'asc' ? 'desc' : 'asc'
    this.setState({
      order: col.split('table-').slice(1).join('-'),
      direction: direction,
    })
  }

  // We may need to sort by subkeys (ie: properties) of an object.  A "-" (dash)
  // represents a dereference of an object, while a "__" (dunder) represents
  // a value to be sorted by.  For example:
  // nd-score__full_name is looked up as ndScore.full_name
  // the "ndScore" object is retrieved, and then the "full_name" property on that
  // value is used for sorting.
  // This is done to handle the Hasura naming style.  Objects use camelCase while
  // properties use snake_case.
  compareGames(key, subkey = undefined, ordering = 'asc') {
    var dedunderizedKey = '',
      sawUnder = false,
      key = key.replaceAll('__', '.'),
      numTokens = key.split('.').length - 1,
      currTokens = 0

    if (numTokens === 0) {
      dedunderizedKey = key
    }

    for (var z = 0; z < key.length && numTokens > 0; z++) {
      var val = key[z].toLowerCase()

      if (val === '.') {
        currTokens++
        if (currTokens >= numTokens) {
          dedunderizedKey += key.slice(key.lastIndexOf('.'))
          break
        }
      }

      if (sawUnder) {
        val = val.toUpperCase()
        sawUnder = false
      } else {
        if (val === '-') {
          sawUnder = true
          continue
        }
      }

      dedunderizedKey += val
    }
    console.log(`dedunderizedKey=${dedunderizedKey}`)

    return function innerSort(a, b) {
      var sortOrder = 0
      console.log(a)
      console.log(b)
      console.log(dedunderizedKey)
      console.log('-')
      window.a = a
      window.b = b

      var keys = dedunderizedKey.split('.'),
        aVal = a,
        bVal = b

      keys.forEach((k, i) => {
        // console.log(`k=${k} i=${i}`)
        aVal = aVal[k]
        bVal = bVal[k]
        // console.log(`aVal=${aVal} bVal=${bVal}`)
      })

      if (aVal > bVal) {
        sortOrder = 1
      } else if (aVal < bVal) {
        sortOrder = -1
      }
      // console.log(sortOrder)

      return sortOrder * (ordering === 'asc' ? 1 : -1)
    }
  }

  render() {
    const resultRows = []
    const matchingGames = this.getMatchingGames()

    matchingGames.sort(
      this.compareGames(this.state.order, undefined, this.state.direction)
    )
    console.log(`Sort by ${this.state.order}, dir=${this.state.direction}`)
    // window.g = matchingGames.slice().sort(compare(this.state.order))

    matchingGames.forEach((game) => {
      resultRows.push(
        <tr key={game.id}>
          <td className="results-table__date">{game.date}</td>
          <td className="results-table__result">{game.result}</td>
          <td className="results-table__site">{game.site}</td>
          <td className="results-table__nd-coach">{game.ndCoach.full_name}</td>
          <td className="results-table__opp-coach">
            {game.oppCoach.full_name}
          </td>
          <td className="results-table__nd-score">{game.nd_score}</td>
          <td className="results-table__opp-score">{game.opp_score}</td>
          <td className="results-table__opponent">{game.opponent.name}</td>
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
          <div className="results-table__game-list">
            <table>
              <thead>
                <tr>
                  {Object.entries({
                    date: 'Date',
                    result: 'Result',
                    site: 'Site',
                    'nd-coach__full_name': 'ND Coach',
                    'opp-coach__full_name': 'Opponent Coach',
                    nd_score: 'ND Score',
                    opp_score: 'Opponent Score',
                    opponent__name: 'Opponent',
                  }).map(([k, v]) => (
                    <th
                      id={`table-${k}`}
                      className={`results-table__header results-table__${k}`}
                      key={k}
                      onClick={this.orderRowsBy.bind(this)}
                    >
                      {v}
                    </th>
                  ))}
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
