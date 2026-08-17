<script setup lang="ts">
import { computed } from 'vue'
import { footerBadges, footerCopyright, type FooterBadge } from '../../footer-badges'

function buildBadgeSrc(badge: FooterBadge): string {
  if (badge.src)
    return badge.src

  const params = new URLSearchParams()
  if (badge.label)
    params.set('label', badge.label)
  params.set('message', badge.message)
  if (badge.color)
    params.set('color', badge.color)
  if (badge.labelColor)
    params.set('labelColor', badge.labelColor)
  if (badge.logo)
    params.set('logo', badge.logo)
  if (badge.logoColor)
    params.set('logoColor', badge.logoColor)
  params.set('style', badge.style || 'flat')

  return `https://img.shields.io/static/v1?${params.toString()}`
}

const badges = computed(() =>
  footerBadges.map(badge => ({
    ...badge,
    src: buildBadgeSrc(badge),
    alt: badge.alt || [badge.label, badge.message].filter(Boolean).join(' '),
  })),
)
</script>

<template>
  <div class="footer-badges-container">
    <div v-if="badges.length" class="footer-badges">
      <component
        :is="badge.link ? 'a' : 'span'"
        v-for="(badge, index) in badges"
        :key="`${badge.src}-${index}`"
        class="footer-badge"
        v-bind="badge.link
          ? { href: badge.link, target: '_blank', rel: 'noopener noreferrer' }
          : {}"
      >
        <img :src="badge.src" :alt="badge.alt" loading="lazy" decoding="async">
      </component>
    </div>

    <div
      v-if="footerCopyright"
      class="footer-copyright"
      v-html="footerCopyright"
    />
  </div>
</template>
