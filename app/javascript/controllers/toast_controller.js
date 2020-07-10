// Bulma Toast HTML helper using Stimulus
// Simple: <div data-controller="toast">I love toast, what genius took bread and said cook it again</div>
// Usage:
// <div data-controller="toast"
//   data-toast-type="notice"           // Defaults to 'alert'
//   data-toast-position="bottom-right" // Defaults to 'top-center'
//   data-toast-close-on-click="false"  // Defaults to true
//   data-toast-duration="100"          // Defaults to 5000
//   >
//   Your toast message
// </div>

import { Controller } from 'stimulus'

export default class extends Controller {
  connect() {
    const message = this.element.innerText
    if (message) {
      const message_class =
        this.data.get('type') == 'alert' ? 'is-warning' : 'is-success'
      const message_position = this.data.get('position') || 'top-center'
      const close_on_click = this.data.get('close-on-click') != 'false'
      const message_duration = parseInt(this.data.get('duration')) || 5000

      bulmaToast.toast({
        message: message,
        type: message_class,
        position: message_position,
        closeOnClick: close_on_click,
        duration: message_duration,
      })
    }
    this.element.remove()
  }
}
