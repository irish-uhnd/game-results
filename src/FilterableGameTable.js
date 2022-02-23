import React from 'react'
import SearchBar from './SearchBar'
import GameResultsTable from './GameResultsTable'
import {SplashScreen} from '@capacitor/splash-screen'

export default function FilterableGameTable({props}) {
  // const lastGame = props.games.at(-1)
  const lastGame = props.games[props.games.length - 1]
  console.log('last game is')
  console.log(lastGame)
  console.log(props)
  const currentYear = new Date(lastGame.date).getFullYear()

  // https://capacitorjs.com/docs/apis/splash-screen
  // Would rather put this Splash screen hiding in the App component, but it's
  // causing a hook-related error.
  React.useEffect(() => {
    if (!props.loading) {
      hideSplash()
      console.log('yay')
    }
  }, [])

  const hideSplash = async () => {
    await SplashScreen.hide()
  }

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
