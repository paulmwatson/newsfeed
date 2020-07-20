// Send A HREF over XHR GET using Stimulus
// Usage: <a href="https://aget.test/path" data-controller="aget" data-action="click->aget#get">A link</a>

import { Controller } from 'stimulus'

export default class extends Controller {
  async get(e) {
    e.preventDefault()
    const icon = this.element.querySelector('.icon i')
    icon.classList.toggle('far')
    icon.classList.toggle('fas')
    icon.parentNode.classList.remove('animate__animated')
    icon.parentNode.classList.remove('animate__heartBeat')
    void icon.parentNode.offsetWidth
    icon.parentNode.classList.add('animate__animated')
    icon.parentNode.classList.add('animate__heartBeat')
    await fetch(this.element.href, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
      },
    })
    if (this.element.href.includes('add-')) {
      this.element.href = this.element.href.replace('add-', 'remove-')
    } else {
      this.element.href = this.element.href.replace('remove-', 'add-')
    }
  }
}
