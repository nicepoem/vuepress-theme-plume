<script setup lang="ts">
import { computed } from 'vue'
import { useBulletinControl } from 'vuepress-theme-plume/composables'
import '@vuepress/helper/transition/fade-in-scale-up.css'

const { bulletin, showBulletin, enableBulletin, close } = useBulletinControl()

const layoutClass = computed(() => bulletin.value?.layout || 'top-right')
const visible = computed(() => !!(bulletin.value && enableBulletin.value && showBulletin.value))
</script>

<template>
  <Transition name="fade-in-scale-up">
    <aside
      v-if="visible"
      class="site-bulletin"
      :class="layoutClass"
      role="dialog"
      aria-label="站点公告"
    >
      <header class="site-bulletin__head">
        <div class="site-bulletin__title-wrap">
          <span class="site-bulletin__dot" aria-hidden="true" />
          <h2
            v-if="bulletin?.title"
            class="site-bulletin__title"
            v-html="bulletin.title"
          />
        </div>
        <button
          type="button"
          class="site-bulletin__close"
          aria-label="关闭公告"
          @click="close"
        >
          <span class="vpi-close" />
        </button>
      </header>

      <div
        v-if="bulletin?.content"
        class="site-bulletin__body"
        v-html="bulletin.content"
      />
    </aside>
  </Transition>
</template>

<style scoped>
.site-bulletin {
  position: fixed;
  z-index: var(--vp-z-index-bulletin, 60);
  display: flex;
  flex-direction: column;
  width: min(292px, calc(100vw - 32px));
  padding: 0;
  overflow: hidden;
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  box-shadow: 0 12px 40px rgba(20, 16, 16, 0.1);
}

.site-bulletin.top-right {
  top: calc(var(--vp-nav-height, 64px) + 16px);
  right: 16px;
}

.site-bulletin.top-left {
  top: calc(var(--vp-nav-height, 64px) + 16px);
  left: 16px;
}

.site-bulletin.bottom-right {
  right: 16px;
  bottom: 16px;
}

.site-bulletin.bottom-left {
  bottom: 16px;
  left: 16px;
}

.site-bulletin.center {
  top: calc(var(--vp-nav-height, 64px) + 16px);
  left: 50%;
  transform: translateX(-50%);
}

.site-bulletin__head {
  display: flex;
  gap: 12px;
  align-items: flex-start;
  justify-content: space-between;
  padding: 14px 14px 0;
}

.site-bulletin__title-wrap {
  display: flex;
  gap: 8px;
  align-items: center;
  min-width: 0;
}

.site-bulletin__dot {
  flex-shrink: 0;
  width: 7px;
  height: 7px;
  background: var(--vp-c-brand-1);
  border-radius: 50%;
  box-shadow: 0 0 0 3px var(--vp-c-brand-soft);
}

.site-bulletin__title {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  line-height: 1.35;
  color: var(--vp-c-text-1);
}

.site-bulletin__close {
  display: inline-flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  margin: -2px -2px 0 0;
  padding: 0;
  color: var(--vp-c-text-3);
  cursor: pointer;
  background: transparent;
  border: 0;
  border-radius: 6px;
  transition:
    color 0.15s ease,
    background-color 0.15s ease;
}

.site-bulletin__close:hover {
  color: var(--vp-c-text-1);
  background: var(--vp-c-bg-soft);
}

.site-bulletin__body {
  padding: 10px 14px 14px 29px;
  font-size: 13px;
  line-height: 1.65;
  color: var(--vp-c-text-2);
}

.site-bulletin__body :deep(> :first-child) {
  margin-top: 0;
}

.site-bulletin__body :deep(> :last-child) {
  margin-bottom: 0;
}

.site-bulletin__body :deep(p) {
  margin: 0;
}

.site-bulletin__body :deep(p + p) {
  margin-top: 8px;
}

.site-bulletin__body :deep(ul),
.site-bulletin__body :deep(ol) {
  padding-left: 1.1em;
  margin: 8px 0 0;
}

.site-bulletin__body :deep(li + li) {
  margin-top: 4px;
}

.site-bulletin__body :deep(a) {
  color: var(--vp-c-brand-1);
  text-decoration: none;
}

.site-bulletin__body :deep(a:hover) {
  text-decoration: underline;
  text-underline-offset: 2px;
}

@media (max-width: 640px) {
  .site-bulletin.top-right,
  .site-bulletin.top-left,
  .site-bulletin.center {
    right: 12px;
    left: 12px;
    width: auto;
    transform: none;
  }
}
</style>
