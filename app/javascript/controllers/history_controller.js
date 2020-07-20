// Send A HREF over XHR GET using Stimulus
// Usage: <a href="..." data-controller="history" data-action="click->back">Back</a>

import { Controller } from 'stimulus'

export default class extends Controller {
  back(e) {
    e.preventDefault()
    history.back()
  }
}
