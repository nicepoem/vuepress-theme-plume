<script setup lang="ts">
import { useReadingTimeLocale } from '@vuepress/plugin-reading-time/client'
import { computed, nextTick, onMounted, ref, watch } from 'vue'
import {
  usePageFrontmatter,
  useRoute,
} from 'vuepress/client'

const matter = usePageFrontmatter()
const readingTime = useReadingTimeLocale()
const route = useRoute()
const pageViews = ref('-')

const author = computed(() => {
  const fromMatter = (matter.value as Record<string, unknown>).author
  if (fromMatter === false)
    return ''
  if (typeof fromMatter === 'string' && fromMatter.trim())
    return fromMatter.trim()
  return '新一'
})

const createTime = computed(() => {
  const raw = (matter.value as Record<string, unknown>).createTime
  if (!raw || raw === false)
    return ''
  return String(raw).split(/\s|T/)[0].replace(/\//g, '-')
})

const words = computed(() => readingTime.value?.words || '')
const time = computed(() => readingTime.value?.time || '')

function fetchPageViews() {
  if (typeof window === 'undefined' || typeof document === 'undefined')
    return

  pageViews.value = '-'
  const callback = `BusuanziCallback_${Date.now()}_${Math.floor(Math.random() * 1e6)}`
  const win = window as any
  const script = document.createElement('script')

  const cleanup = () => {
    try { delete win[callback] } catch {}
    script.remove()
  }

  win[callback] = (data: { page_pv?: number }) => {
    pageViews.value = data?.page_pv != null ? String(data.page_pv) : '-'
    cleanup()
  }

  script.src = `https://busuanzi.ibruce.info/busuanzi?jsonpCallback=${callback}`
  script.defer = true
  script.referrerPolicy = 'no-referrer-when-downgrade'
  script.onerror = cleanup
  document.head.appendChild(script)
}

onMounted(() => nextTick(fetchPageViews))
watch(() => route.path, () => nextTick(fetchPageViews))
</script>

<template>
  <div v-if="author || createTime || time || words" class="doc-meta-bar">
    <span v-if="author" class="meta-item">
      <span class="vpi-user meta-icon" />
      <span class="meta-value">{{ author }}</span>
    </span>

    <span v-if="createTime" class="meta-item">
      <span class="vpi-clock meta-icon" />
      <span class="meta-value">{{ createTime }}</span>
    </span>

    <span v-if="time" class="meta-item">
      <span class="vpi-books meta-icon" />
      <span class="meta-value">{{ time }}</span>
    </span>

    <span class="meta-item meta-views">
      <span class="meta-icon meta-icon-eye" aria-hidden="true" />
      <span class="meta-value">{{ pageViews }}</span>
    </span>

    <span v-if="words" class="meta-item">
      <span class="vpi-square-pen meta-icon" />
      <span class="meta-value">{{ words }}</span>
    </span>
  </div>
</template>
