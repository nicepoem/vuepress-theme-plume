import { defineClientConfig, onContentUpdated } from 'vuepress/client'
import { setupCustomScrollbars } from './theme/customScrollbar'
import Layout from './layouts/Layout.vue'
import Bulletin from './theme/components/Bulletin.vue'

import './theme/styles/custom.css'
import './theme/styles/vars.css'

export default defineClientConfig({
  setup() {
    onContentUpdated((reason) => {
      if (reason === 'beforeUnmount')
        return
      requestAnimationFrame(setupCustomScrollbars)
    })
  },
  layouts: {
    Layout,
  },
  enhance({ app }) {
    app.component('Bulletin', Bulletin)
  },
})
