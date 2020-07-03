import Rails from '@rails/ujs'

const checkboxSubmit = () => {
  for (let checkbox of document.querySelectorAll(
    'input[type="checkbox"].on-change-submit-form'
  )) {
    checkbox.addEventListener('change', function (event) {
      Rails.fire(event.target.closest('form'), 'submit')
    })
  }
}

const turboLinksLoad = () => {
  for (let form of document.querySelectorAll(
    'form[method=get][data-remote=true]'
  )) {
    form.addEventListener('ajax:beforeSend', function (event) {
      event.preventDefault()
      Turbolinks.visit(event.detail[1].url)
    })
  }
}

document.addEventListener('turbolinks:load', turboLinksLoad)
document.addEventListener('turbolinks:load', checkboxSubmit)
