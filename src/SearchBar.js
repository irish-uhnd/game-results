import React from 'react'

export default function SearchBar({props}) {
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

  const vacated = [
    {key: 'Yes', value: 'true'},
    {key: 'No', value: 'false'},
  ].map(({key, value}) => (
    <option key={key} value={value}>
      {key}
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
        <h1>
          <span className="search-bar-header__title1">Notre Dame Football</span>{' '}
          <span className="search-bar-header__title2">Game Results</span>
        </h1>
      </header>
      <main className="main">
        <div className="filter-table">
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
            <div className="filter-table__column">Bowl Game?</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('is_bowl')}
                value={'is_bowl' in filters ? filters.isBowl : ''}
              >
                {vacated}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column">Season</div>
            <div className="filter-table__column">
              <select
                onChange={handleFilter('season')}
                value={'season' in filters ? filters.season : ''}
              >
                {years}
              </select>
            </div>
          </div>

          <div className="filter-table__row">
            <div className="filter-table__column filter-table__column--span2">
              <div className="filter-table__date">
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

      <div className="start-over">
        <button className="btn btn--color" onClick={handleClear}>
          Start Over
        </button>
      </div>
      <br />
    </div>
  )
}
