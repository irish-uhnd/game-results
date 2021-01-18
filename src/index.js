import React from 'react'
import ReactDOM from 'react-dom'
import '@babel/polyfill'
import App from './App'

const rootElement = document.getElementById('root')
// ReactDOM.render(
//   <React.StrictMode>
//     <App />
//   </React.StrictMode>,
//   rootElement
// );

ReactDOM.render(<App />, document.getElementById('root'))
