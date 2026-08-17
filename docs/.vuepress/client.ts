import { defineClientConfig, onContentUpdated } from 'vuepress/client'
import { setupCustomScrollbars } from './theme/customScrollbar'
import Layout from './layouts/Layout.vue'
import Bulletin from './theme/components/Bulletin.vue'
// import RepoCard from 'vuepress-theme-plume/features/RepoCard.vue'
// import NpmBadge from 'vuepress-theme-plume/features/NpmBadge.vue'
// import NpmBadgeGroup from 'vuepress-theme-plume/features/NpmBadgeGroup.vue'
// import Swiper from 'vuepress-theme-plume/features/Swiper.vue'

// import CustomComponent from './theme/components/Custom.vue'

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
    // built-in components
    // app.component('RepoCard', RepoCard)
    // app.component('NpmBadge', NpmBadge)
    // app.component('NpmBadgeGroup', NpmBadgeGroup)
    // app.component('Swiper', Swiper) // you should install `swiper`

    // your custom components
    // app.component('CustomComponent', CustomComponent)
    app.component('Bulletin', Bulletin)
  },
})
