type ScrollAxis = 'x' | 'y'

const MIN_THUMB_SIZE = 32

interface ScrollMetrics {
  scrollSize: number
  clientSize: number
  scrollPos: number
}

interface MountScrollbarOptions {
  container: HTMLElement
  mountTarget: HTMLElement
  axis: ScrollAxis
  trackExtraClass?: string
  getMetrics: () => ScrollMetrics
  setScroll: (pos: number) => void
  bindScroll: (handler: () => void) => void
  observeTargets: Element[]
}

function mountScrollbar(options: MountScrollbarOptions) {
  const {
    container,
    mountTarget,
    axis,
    trackExtraClass = '',
    getMetrics,
    setScroll,
    bindScroll,
    observeTargets,
  } = options

  if (container.dataset.customScrollbarInit === 'true')
    return

  container.dataset.customScrollbarInit = 'true'
  container.classList.add('has-custom-scrollbar')

  const track = document.createElement('div')
  track.className = `vp-custom-scrollbar is-${axis === 'x' ? 'horizontal' : 'vertical'} ${trackExtraClass}`.trim()
  track.setAttribute('aria-hidden', 'true')

  const thumb = document.createElement('div')
  thumb.className = 'vp-custom-scrollbar-thumb'
  track.appendChild(thumb)
  mountTarget.appendChild(track)

  let hideTimer: ReturnType<typeof setTimeout> | undefined
  let dragging = false
  let dragStart = 0
  let dragStartScroll = 0

  const showBar = () => {
    container.classList.add('is-scrollbar-active')
    if (hideTimer)
      clearTimeout(hideTimer)
    hideTimer = setTimeout(() => {
      if (!dragging)
        container.classList.remove('is-scrollbar-active')
    }, 1000)
  }

  const update = () => {
    const { scrollSize, clientSize, scrollPos } = getMetrics()

    if (scrollSize <= clientSize + 1) {
      track.hidden = true
      return
    }

    track.hidden = false

    if (axis === 'x') {
      const trackSize = track.clientWidth
      const thumbSize = Math.max(MIN_THUMB_SIZE, (clientSize / scrollSize) * trackSize)
      const maxScroll = scrollSize - clientSize
      const maxTravel = trackSize - thumbSize
      const offset = maxScroll > 0 ? (scrollPos / maxScroll) * maxTravel : 0

      thumb.style.width = `${thumbSize}px`
      thumb.style.height = ''
      thumb.style.transform = `translateX(${offset}px)`
    }
    else {
      const trackSize = track.clientHeight
      const thumbSize = Math.max(MIN_THUMB_SIZE, (clientSize / scrollSize) * trackSize)
      const maxScroll = scrollSize - clientSize
      const maxTravel = trackSize - thumbSize
      const offset = maxScroll > 0 ? (scrollPos / maxScroll) * maxTravel : 0

      thumb.style.height = `${thumbSize}px`
      thumb.style.width = ''
      thumb.style.transform = `translateY(${offset}px)`
    }
  }

  bindScroll(() => {
    update()
    showBar()
  })

  container.addEventListener('mouseenter', showBar)

  track.addEventListener('mousedown', (event) => {
    if (event.target === thumb)
      return

    const rect = track.getBoundingClientRect()
    const metrics = getMetrics()

    if (axis === 'x') {
      const clickPos = event.clientX - rect.left
      const thumbSize = thumb.clientWidth
      const trackSize = track.clientWidth
      const maxScroll = metrics.scrollSize - metrics.clientSize
      const maxTravel = trackSize - thumbSize
      const target = clickPos - thumbSize / 2
      const ratio = maxTravel > 0 ? Math.max(0, Math.min(1, target / maxTravel)) : 0
      setScroll(ratio * maxScroll)
    }
    else {
      const clickPos = event.clientY - rect.top
      const thumbSize = thumb.clientHeight
      const trackSize = track.clientHeight
      const maxScroll = metrics.scrollSize - metrics.clientSize
      const maxTravel = trackSize - thumbSize
      const target = clickPos - thumbSize / 2
      const ratio = maxTravel > 0 ? Math.max(0, Math.min(1, target / maxTravel)) : 0
      setScroll(ratio * maxScroll)
    }

    showBar()
  })

  thumb.addEventListener('mousedown', (event) => {
    dragging = true
    dragStart = axis === 'x' ? event.clientX : event.clientY
    dragStartScroll = getMetrics().scrollPos
    document.body.classList.add('vp-custom-scrollbar-dragging')
    event.preventDefault()
  })

  const onMouseMove = (event: MouseEvent) => {
    if (!dragging)
      return

    const metrics = getMetrics()

    if (axis === 'x') {
      const trackSize = track.clientWidth
      const thumbSize = thumb.clientWidth
      const maxScroll = metrics.scrollSize - metrics.clientSize
      const maxTravel = trackSize - thumbSize
      if (maxTravel <= 0)
        return

      const delta = event.clientX - dragStart
      setScroll(dragStartScroll + (delta / maxTravel) * maxScroll)
    }
    else {
      const trackSize = track.clientHeight
      const thumbSize = thumb.clientHeight
      const maxScroll = metrics.scrollSize - metrics.clientSize
      const maxTravel = trackSize - thumbSize
      if (maxTravel <= 0)
        return

      const delta = event.clientY - dragStart
      setScroll(dragStartScroll + (delta / maxTravel) * maxScroll)
    }
  }

  const onMouseUp = () => {
    if (!dragging)
      return

    dragging = false
    document.body.classList.remove('vp-custom-scrollbar-dragging')
    showBar()
  }

  document.addEventListener('mousemove', onMouseMove)
  document.addEventListener('mouseup', onMouseUp)

  const resizeObserver = new ResizeObserver(() => update())
  observeTargets.forEach(target => resizeObserver.observe(target))

  const mutationObserver = new MutationObserver(() => update())
  observeTargets.forEach((target) => {
    if (target instanceof HTMLElement)
      mutationObserver.observe(target, { childList: true, subtree: true, characterData: true })
  })

  window.addEventListener('resize', update, { passive: true })

  requestAnimationFrame(update)
}

function mountElementScrollbar(scrollEl: HTMLElement, axis: ScrollAxis, trackExtraClass = '') {
  const container = axis === 'x' ? (scrollEl.parentElement ?? scrollEl) : scrollEl

  mountScrollbar({
    container,
    mountTarget: container,
    axis,
    trackExtraClass,
    getMetrics: () => ({
      scrollSize: axis === 'x' ? scrollEl.scrollWidth : scrollEl.scrollHeight,
      clientSize: axis === 'x' ? scrollEl.clientWidth : scrollEl.clientHeight,
      scrollPos: axis === 'x' ? scrollEl.scrollLeft : scrollEl.scrollTop,
    }),
    setScroll: pos => {
      if (axis === 'x')
        scrollEl.scrollLeft = pos
      else
        scrollEl.scrollTop = pos
    },
    bindScroll: handler => scrollEl.addEventListener('scroll', handler, { passive: true }),
    observeTargets: [scrollEl],
  })
}

export function setupGlobalScrollbar() {
  if (typeof window === 'undefined')
    return

  const root = document.documentElement

  mountScrollbar({
    container: root,
    mountTarget: document.body,
    axis: 'y',
    trackExtraClass: 'is-global',
    getMetrics: () => ({
      scrollSize: root.scrollHeight,
      clientSize: window.innerHeight,
      scrollPos: window.scrollY,
    }),
    setScroll: pos => window.scrollTo({ top: pos, behavior: 'auto' }),
    bindScroll: handler => window.addEventListener('scroll', handler, { passive: true }),
    observeTargets: [root, document.body],
  })
}

export function setupCodeScrollbars() {
  if (typeof window === 'undefined')
    return

  document.querySelectorAll('.vp-doc div[class*="language-"] > pre').forEach((element) => {
    if (element instanceof HTMLPreElement)
      mountElementScrollbar(element, 'x')
  })
}

export function setupSidebarScrollbars() {
  if (typeof window === 'undefined')
    return

  document.querySelectorAll('aside.vp-sidebar, .aside-container').forEach((element) => {
    if (element instanceof HTMLElement)
      mountElementScrollbar(element, 'y')
  })
}

export function setupCustomScrollbars() {
  setupGlobalScrollbar()
  setupCodeScrollbars()
  setupSidebarScrollbars()
}
