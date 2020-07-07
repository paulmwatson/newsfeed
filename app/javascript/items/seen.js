let ticking = false

const checkItemsSeen = () => {
  if (!ticking) {
    ticking = true
    const windowScrollY = window.scrollY
    for (let item of document.querySelectorAll('.is-item:not(.is-seen)')) {
      const itemOffsetTop = item.offsetTop
      if (itemOffsetTop < windowScrollY) {
        item.classList.add('is-seen')
        fetch(`/items/${item.dataset.itemId}/seen`)
      }
    }
    ticking = false
  }
}

window.addEventListener('scroll', checkItemsSeen)
