<script setup lang="ts">
import { onClickOutside } from '@vueuse/core'
import { computed, onMounted, ref } from 'vue'

const BRAND_KEY = 'plume-brand-color'
const SIZE_KEY = 'plume-page-size'

const brands = [
  { id: 'indigo', label: '靛蓝', color: '#3451b2' },
  { id: 'teal', label: '青绿', color: '#5086a1' },
  { id: 'green', label: '翠绿', color: '#299764' },
  { id: 'sky', label: '天蓝', color: '#0284c7' },
  { id: 'violet', label: '紫罗兰', color: '#6f42c1' },
  { id: 'rose', label: '玫红', color: '#e11d48' },
  { id: 'orange', label: '橘橙', color: '#ea580c' },
  { id: 'cyan', label: '青蓝', color: '#0891b2' },
] as const

const sizes = [
  { id: 'small', label: 'Small', desc: '紧凑' },
  { id: 'default', label: 'Default', desc: '默认' },
  { id: 'large', label: 'Large', desc: '宽松' },
  { id: 'wide', label: 'Wide', desc: '全宽' },
] as const

type BrandId = (typeof brands)[number]['id']
type PageSizeId = (typeof sizes)[number]['id']

const open = ref(false)
const brand = ref<BrandId>('indigo')
const pageSize = ref<PageSizeId>('default')
const root = ref<HTMLElement | null>(null)

const currentBrand = computed(
  () => brands.find(b => b.id === brand.value) ?? brands[0],
)

const sizeIndex = computed(() =>
  Math.max(0, sizes.findIndex(s => s.id === pageSize.value)),
)

onClickOutside(root, () => {
  open.value = false
})

onMounted(() => {
  const savedBrand = document.documentElement.getAttribute('data-brand') as BrandId | null
  if (savedBrand && brands.some(b => b.id === savedBrand))
    brand.value = savedBrand

  const savedSize = document.documentElement.getAttribute('data-page-size') as PageSizeId | null
  if (savedSize && sizes.some(s => s.id === savedSize))
    pageSize.value = savedSize
})

function setBrand(id: BrandId) {
  brand.value = id
  document.documentElement.setAttribute('data-brand', id)
  try {
    localStorage.setItem(BRAND_KEY, id)
  }
  catch {}
}

function setSize(id: PageSizeId) {
  pageSize.value = id
  document.documentElement.setAttribute('data-page-size', id)
  try {
    localStorage.setItem(SIZE_KEY, id)
  }
  catch {}
}

function toggle() {
  open.value = !open.value
}
</script>

<template>
  <div ref="root" class="theme-settings">
    <button
      type="button"
      class="trigger"
      :aria-expanded="open"
      aria-haspopup="true"
      aria-label="主题设置"
      title="主题设置"
      @click="toggle"
    >
      <span class="swatch" :style="{ backgroundColor: currentBrand.color }" />
      <span class="vpi-chevron-down chevron" />
    </button>

    <div v-show="open" class="panel" role="dialog" aria-label="主题设置">
      <section class="section">
        <p class="panel-title">
          页面尺寸
        </p>
        <div class="size-options" role="radiogroup" aria-label="页面尺寸">
          <span
            class="size-indicator"
            :style="{ transform: `translateX(${sizeIndex * 100}%)` }"
            aria-hidden="true"
          />
          <button
            v-for="size in sizes"
            :key="size.id"
            type="button"
            class="size-btn"
            role="radio"
            :aria-checked="pageSize === size.id"
            :aria-label="`${size.label}（${size.desc}）`"
            :title="`${size.label} · ${size.desc}`"
            :class="{ active: pageSize === size.id }"
            @click="setSize(size.id)"
          >
            {{ size.label }}
          </button>
        </div>
      </section>

      <section class="section">
        <p class="panel-title">
          主题颜色
        </p>
        <div class="swatches">
          <button
            v-for="item in brands"
            :key="item.id"
            type="button"
            class="swatch-btn"
            role="radio"
            :aria-checked="brand === item.id"
            :aria-label="item.label"
            :title="item.label"
            :class="{ active: brand === item.id }"
            @click="setBrand(item.id)"
          >
            <span class="dot" :style="{ backgroundColor: item.color }" />
          </button>
        </div>
      </section>
    </div>
  </div>
</template>

<style scoped>
.theme-settings {
  position: relative;
  display: flex;
  align-items: center;
  margin-left: 8px;
}

.trigger {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  height: 36px;
  padding: 0 8px;
  color: var(--vp-c-text-2);
  cursor: pointer;
  background: transparent;
  border: none;
  border-radius: 8px;
  transition:
    color var(--vp-t-color),
    background-color 0.2s;
}

.trigger:hover {
  color: var(--vp-c-text-1);
  background-color: var(--vp-c-bg-soft);
}

.swatch {
  width: 14px;
  height: 14px;
  border: 1.5px solid rgba(255, 255, 255, 0.55);
  border-radius: 50%;
  box-shadow:
    0 0 0 1px rgba(0, 0, 0, 0.12),
    inset 0 0 0 1px rgba(0, 0, 0, 0.04);
}

.chevron {
  width: 12px;
  height: 12px;
  opacity: 0.7;
}

.panel {
  position: absolute;
  top: calc(100% + 8px);
  right: 0;
  z-index: 100;
  width: 220px;
  padding: 12px;
  background-color: var(--vp-c-bg-elv);
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  box-shadow: var(--vp-shadow-3);
}

.section + .section {
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid var(--vp-c-divider);
}

.panel-title {
  margin: 0 0 10px;
  font-size: 12px;
  font-weight: 600;
  line-height: 1;
  color: var(--vp-c-text-2);
}

.size-options {
  position: relative;
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  padding: 3px;
  background-color: var(--vp-c-bg-soft);
  border-radius: 8px;
}

.size-indicator {
  position: absolute;
  top: 3px;
  bottom: 3px;
  left: 3px;
  z-index: 0;
  width: calc((100% - 6px) / 4);
  background-color: var(--vp-c-brand-1);
  border-radius: 6px;
  box-shadow: 0 1px 4px color-mix(in srgb, var(--vp-c-brand-1) 45%, transparent);
  transition: transform 0.28s cubic-bezier(0.4, 0, 0.2, 1);
}

.size-btn {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  height: 28px;
  padding: 0 2px;
  font-size: 11px;
  font-weight: 600;
  line-height: 1;
  color: var(--vp-c-text-2);
  cursor: pointer;
  background: transparent;
  border: none;
  border-radius: 6px;
  transition: color 0.28s ease;
}

.size-btn:hover {
  color: var(--vp-c-text-1);
}

.size-btn.active,
.size-btn.active:hover {
  color: #fff;
}

.swatches {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
}

.swatch-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 32px;
  padding: 0;
  cursor: pointer;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 8px;
  transition:
    border-color 0.2s,
    background-color 0.2s;
}

.swatch-btn:hover {
  background-color: var(--vp-c-bg-soft);
}

.swatch-btn.active {
  border-color: var(--vp-c-brand-1);
  background-color: var(--vp-c-brand-soft);
}

.dot {
  width: 18px;
  height: 18px;
  border-radius: 50%;
  box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.1);
}

@media (max-width: 767px) {
  .theme-settings {
    margin-left: 0;
  }
}
</style>
